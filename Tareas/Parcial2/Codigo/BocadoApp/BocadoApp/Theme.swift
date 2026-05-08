import SwiftUI

// MARK: - Bocado Design System v2

extension Color {
    // ── Core Palette ──────────────────────────────────────────────────────────
    static let bocadoCoral      = Color(hex: "#E05570")   // rosa coral · color principal
    static let bocadoOlive      = Color(hex: "#6B8C3E")   // verde oliva
    static let bocadoOrange     = Color(hex: "#E87043")   // naranja cálido
    static let bocadoCream      = Color(hex: "#F5EDE0")   // crema suave · acentos

    // Alias para compatibilidad (MealStatus, etc.)
    static let bocadoGreen      = Color(hex: "#6B8C3E")   // → bocadoOlive

    // ── Backgrounds ───────────────────────────────────────────────────────────
    // Scan screen gradient se define en ScanView con LinearGradient
    static let bocadoBackground = Color.white

    // ── Text ──────────────────────────────────────────────────────────────────
    static let bocadoTextMuted  = Color(hex: "#A0A0A0")
    static let bocadoTextDark   = Color(hex: "#1A1A1A")

    // ── Category colors Papers ─────────────────────────────────────────────────
    static let catNutricion     = Color(hex: "#6B8C3E")   // verde oliva
    static let catHabitos       = Color(hex: "#E87043")   // naranja
    static let catCiencia       = Color(hex: "#8B5CF6")   // morado

    // ── Scan screen gradient stops ────────────────────────────────────────────
    static let gradientStart    = Color(hex: "#E05570")   // coral
    static let gradientEnd      = Color(hex: "#F09050")   // durazno-naranja

    // ── Legacy (dark scan era — se puede eliminar en el futuro) ───────────────
    static let bocadoDark       = Color(hex: "#182818")
    static let bocadoCardDark   = Color(hex: "#253525")
    static let bocadoStatBg     = Color(hex: "#1E301E")
    static let bocadoTextCream  = Color(hex: "#F2E8D5")
    static let profileHeader    = Color(hex: "#1E2B1E")

    // MARK: - Hex initializer
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:  (a,r,g,b) = (255,(int>>8)*17,(int>>4 & 0xF)*17,(int & 0xF)*17)
        case 6:  (a,r,g,b) = (255,int>>16,int>>8 & 0xFF,int & 0xFF)
        case 8:  (a,r,g,b) = (int>>24,int>>16 & 0xFF,int>>8 & 0xFF,int & 0xFF)
        default: (a,r,g,b) = (255,0,0,0)
        }
        self.init(.sRGB,
                  red:     Double(r)/255,
                  green:   Double(g)/255,
                  blue:    Double(b)/255,
                  opacity: Double(a)/255)
    }
}

// MARK: - Typography
extension Font {
    static func bocadoTitle(_ size: CGFloat = 34) -> Font {
        .system(size: size, weight: .heavy, design: .rounded)
    }
    static func bocadoBody(_ size: CGFloat = 15) -> Font {
        .system(size: size, weight: .regular, design: .rounded)
    }
    static func bocadoLabel(_ size: CGFloat = 12) -> Font {
        .system(size: size, weight: .semibold, design: .rounded)
    }
}

// MARK: - Scan Gradient helper
extension LinearGradient {
    static var bocadoScanGradient: LinearGradient {
        LinearGradient(
            colors: [.gradientStart, .gradientEnd],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

