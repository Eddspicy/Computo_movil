import Foundation

// MARK: - Configuración Global de Bocado

enum BocadoConfig {

    // ─── API Key ──────────────────────────────────────────────────────
    static let geminiAPIKey = Secrets.geminiAPIKey

    // ─── Modelo ───────────────────────────────────────────────────────
    static let geminiModel  = "gemini-2.5-flash-lite"

    // ─── System Instruction ───────────────────────────────────────────
    static let systemInstruction = """
    You are a nutritionist who will receive an image of a food dish in any form. \
    If you receive an image of anything else, including beverages, you must respond with a JSON message stating that it is not possible to provide information. \
    Also, if you receive a photo of a menu, you can provide recommendations based on the nutritional value of the dishes. \
    Try to be as brief as possible with the information you return, as it is for a mobile app and should not contain too much text to display correctly on the screen. \
    Write it as a single sentence and do not exceed 100 characters.

    Always respond with this exact JSON structure, using these exact key names:
    {
      "dishName": "Name of the dish or null if unrecognized",
      "calories": 450,
      "protein": 28.5,
      "carbohydrates": 42.0,
      "fat": 18.0,
      "fiber": 3.5,
      "sodium": 620.0,
      "sugar": 4.0,
      "recommendations": ["brief recommendation"],
      "warnings": ["brief warning if any"]
    }
    Always give the reponse in spanish
    """

    // ─── Dev mode ─────────────────────────────────────────────────────
    // true  → usa datos mock (sin internet, sin key, sin costo)
    // false → llama a Gemini de verdad
    static let useMockData = false
}
