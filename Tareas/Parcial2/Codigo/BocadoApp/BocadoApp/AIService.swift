import UIKit
import Foundation

// MARK: - MealAnalysis Model

struct MealAnalysis: Decodable, Identifiable {
    let id              = UUID()
    let dishName        : String?
    let calories        : Int?
    let protein         : Double?
    let carbohydrates   : Double?
    let fat             : Double?
    let fiber           : Double?
    let sodium          : Double?
    let sugar           : Double?
    let recommendations : [String]
    let warnings        : [String]

    enum CodingKeys: String, CodingKey {
        case dishName, calories, protein, carbohydrates, fat, fiber, sodium, sugar, recommendations, warnings
    }
}

// MARK: - AI Errors

enum AIError: Error, LocalizedError, Equatable {
    case invalidImage
    case networkError(Int, String)
    case parseError(String)
    case missingAPIKey
    case serviceUnavailable
    case unexpectedResponse
    case quotaExceeded

    var errorDescription: String? {
        switch self {
        case .invalidImage:               return "No se pudo procesar la imagen."
        case .networkError(let c, let m): return "Error de red \(c): \(m)"
        case .parseError(let m):          return "Error al decodificar respuesta: \(m)"
        case .missingAPIKey:              return "Agrega tu Gemini API key en BocadoConfig.swift"
        case .serviceUnavailable:         return "El servicio de IA está temporalmente no disponible en tu región debido a alta demanda. Intenta de nuevo en unos minutos."
        case .quotaExceeded:               return "¡Ups! Tuvimos un problema de nuestra parte. Por favor intenta de nuevo.λ"
        case .unexpectedResponse:         return "¡Ups! Tuvimos un problema de nuestra parte. Por favor intenta de nuevo."
        }
    }

    var alertTitle: String {
        switch self {
        case .serviceUnavailable:  return "Servicio no disponible"
        case .unexpectedResponse:  return "No pudimos analizar tu plato"
        default:                   return "Algo salió mal 😅"
        }
    }
}

// MARK: - AIService  (powered by Gemini 2.5 Flash)

@MainActor
final class AIService {
    static let shared = AIService()
    private init() {}

    // Endpoint de Gemini generateContent
    private var endpoint: URL {
        URL(string: "https://generativelanguage.googleapis.com/v1beta/models/\(BocadoConfig.geminiModel):generateContent?key=\(BocadoConfig.geminiAPIKey)")!
    }

    // MARK: - analyzeMeal

    /// Manda la foto del plato + perfil del usuario → regresa análisis nutricional
    func analyzeMeal(image: UIImage, profile: UserProfile) async throws -> MealAnalysis {

        // ── Mock para desarrollo (sin gastar quota) ───────────────────
        if BocadoConfig.useMockData {
            try await Task.sleep(for: .seconds(2.0))
            return mockAnalysis()
        }

        guard !BocadoConfig.geminiAPIKey.hasPrefix("YOUR_") else {
            throw AIError.missingAPIKey
        }

        // ── Imagen → base64 JPEG ──────────────────────────────────────
        guard let imageData = image.jpegData(compressionQuality: 0.72) else {
            throw AIError.invalidImage
        }
        let base64 = imageData.base64EncodedString()

        // ── Prompt ───────────────────────────────────────────────────
        let bmi    = Double(profile.weightKg) / pow(Double(profile.heightCm) / 100.0, 2)
        let prompt = buildPrompt(profile: profile, bmi: bmi)

        // ── Gemini request body ───────────────────────────────────────
        let body: [String: Any] = [
            "systemInstruction": [
                "parts": [["text": BocadoConfig.systemInstruction]]
            ],
            "contents": [[
                "parts": [
                    [
                        "inline_data": [
                            "mime_type": "image/jpeg",
                            "data"     : base64
                        ]
                    ],
                    ["text": prompt]
                ]
            ]],
            "generationConfig": [
                "temperature"    : 0.2,
                "maxOutputTokens": 1024
            ]
        ]

        // ── URLRequest ────────────────────────────────────────────────
        var request        = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody   = try JSONSerialization.data(withJSONObject: body)

        // ── Network call ──────────────────────────────────────────────
        let (data, response) = try await URLSession.shared.data(for: request)

        if let http = response as? HTTPURLResponse, http.statusCode != 200 {
            switch http.statusCode {
            case 429: throw AIError.quotaExceeded
            case 503: throw AIError.serviceUnavailable
            default:
                let body = String(data: data, encoding: .utf8) ?? "sin cuerpo"
                throw AIError.networkError(http.statusCode, body)
            }
        }

        // ── Parse Gemini envelope ─────────────────────────────────────
        // Estructura: { candidates: [{ content: { parts: [{ text }] } }] }
        struct GeminiResponse: Decodable {
            struct Candidate: Decodable {
                struct Content: Decodable {
                    struct Part: Decodable { let text: String? }
                    let parts: [Part]
                }
                let content: Content
            }
            let candidates: [Candidate]
        }

        let gemini  = try JSONDecoder().decode(GeminiResponse.self, from: data)
        let rawText = gemini.candidates
            .first?.content.parts
            .compactMap(\.text)
            .joined() ?? ""

        print("🤖 Gemini raw response:\n\(rawText)")

        guard !rawText.isEmpty else {
            throw AIError.parseError("Gemini no regresó texto")
        }

        // ── Extraer JSON ──────────────────────────────────────────────
        guard let jsonData = extractJSON(from: rawText) else {
            throw AIError.unexpectedResponse
        }

        return try JSONDecoder().decode(MealAnalysis.self, from: jsonData)
    }

    // MARK: - Prompt

    private func buildPrompt(profile: UserProfile, bmi: Double) -> String {
        """
        Datos del usuario:
        - Edad: \(profile.ageYears) años
        - Peso: \(profile.weightKg) kg
        - Estatura: \(profile.heightCm) cm
        - IMC estimado: \(String(format: "%.1f", bmi))

        Analiza el plato de la imagen.
        """
    }

    // MARK: - Helpers

    /// Extrae JSON de texto plano o bloques markdown
    private func extractJSON(from text: String) -> Data? {
        // 1. Texto directo (Gemini a veces responde limpio)
        if let d = text.data(using: .utf8),
           (try? JSONSerialization.jsonObject(with: d)) != nil { return d }

        // 2. Bloque ```json ... ``` o ``` ... ```
        for fence in ["```json\n", "```json", "```\n", "```"] {
            if let start = text.range(of: fence),
               let end   = text.range(of: "```", range: start.upperBound..<text.endIndex) {
                let candidate = String(text[start.upperBound..<end.lowerBound]).trimmingCharacters(in: .whitespacesAndNewlines)
                if let d = candidate.data(using: .utf8),
                   (try? JSONSerialization.jsonObject(with: d)) != nil { return d }
            }
        }

        // 3. Buscar el { ... } más externo
        if let first = text.firstIndex(of: "{"),
           let last  = text.lastIndex(of: "}") {
            let candidate = String(text[first...last])
            if let d = candidate.data(using: .utf8),
               (try? JSONSerialization.jsonObject(with: d)) != nil { return d }
        }

        return nil
    }

    // MARK: - Mock

    private func mockAnalysis() -> MealAnalysis {
        MealAnalysis(
            dishName       : "Arroz con pollo y chile poblano",
            calories       : 480,
            protein        : 32.0,
            carbohydrates  : 45.0,
            fat            : 14.0,
            fiber          : 2.5,
            sodium         : 540.0,
            sugar          : 3.0,
            recommendations: ["Add a handful of spinach or sliced tomato for more fiber."],
            warnings       : ["High sodium content due to seasoning."]
        )
    }
}
