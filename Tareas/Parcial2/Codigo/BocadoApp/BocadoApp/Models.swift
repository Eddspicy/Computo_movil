import SwiftUI

// MARK: - Models

// ─── Meal (Diario) ────────────────────────────────────────────────────────────

struct Meal: Identifiable {
    let id            = UUID()
    let name          : String
    let time          : String
    let emojis        : [String]
    let status        : MealStatus
    let missingEmojis : [String]
    let thumbnail     : String
    var analysis      : MealAnalysis?
}

enum MealStatus {
    case complete, missing, pending

    var label: String {
        switch self {
        case .complete: return "Completo ✓"
        case .missing:  return "⚠️ Faltó"
        case .pending:  return "Pendiente"
        }
    }

    var color: Color {
        switch self {
        case .complete: return .bocadoOlive
        case .missing:  return .bocadoCoral
        case .pending:  return .bocadoTextMuted
        }
    }
}

// ─── Paper ────────────────────────────────────────────────────────────────────

struct Paper: Identifiable {
    let id       = UUID()
    let category : PaperCategory
    let title    : String
    let readTime : Int
    let isPro    : Bool
}

enum PaperCategory: String, CaseIterable {
    case todo      = "Todo"
    case habitos   = "Hábitos"
    case nutricion = "Nutrición"
    case ciencia   = "Ciencia"

    var color: Color {
        switch self {
        case .todo:      return Color.black
        case .habitos:   return Color.bocadoOrange
        case .nutricion: return Color.bocadoOlive
        case .ciencia:   return Color(hex: "#8B5CF6")
        }
    }

    var label: String { rawValue.uppercased() }
}

// ─── UserProfile ──────────────────────────────────────────────────────────────

struct UserProfile {
    var name                : String = "Ana García"
    var heightCm            : Int    = 164
    var weightKg            : Int    = 58
    var ageYears            : Int    = 28
    var patientCode         : String = "B · 4821"
    var nutritionistName    : String = "Dr. Carlos Ramírez"
    var nutritionistInitial : String = "R"
    var isLinked            : Bool   = true
}

// ─── Sample Data ──────────────────────────────────────────────────────────────

struct SampleData {
    static let meals: [Meal] = [
        Meal(name: "Desayuno",
             time: "8:00 AM",
             emojis: ["🥣","🍌","🥛"],
             status: .complete,
             missingEmojis: [],
             thumbnail: "🥣"),
        Meal(name: "Almuerzo",
             time: "1:15 PM",
             emojis: ["🥗","🌶️"],
             status: .missing,
             missingEmojis: ["🌽","🥑"],
             thumbnail: "🥗"),
        Meal(name: "Cena",
             time: "7:30 PM",
             emojis: [],
             status: .pending,
             missingEmojis: [],
             thumbnail: "🍽️")
    ]

    static let papers: [Paper] = [
        Paper(category: .nutricion,
              title: "Hidratación y rendimiento cognitivo",
              readTime: 4, isPro: false),
        Paper(category: .habitos,
              title: "Comer despacio: aliado metabólico",
              readTime: 3, isPro: false),
        Paper(category: .ciencia,
              title: "Fibra y microbioma intestinal",
              readTime: 6, isPro: true),
        Paper(category: .nutricion,
              title: "Proteína en cada comida",
              readTime: 5, isPro: false),
        Paper(category: .habitos,
              title: "Ritmo circadiano y digestión",
              readTime: 7, isPro: true)
    ]
}

