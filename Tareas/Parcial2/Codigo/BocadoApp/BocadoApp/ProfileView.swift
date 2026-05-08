import SwiftUI

// MARK: - ProfileView

struct ProfileView: View {
    @State private var profile = UserProfile()

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Coral gradient header
                    profileHeader

                    // Contenido blanco
                    VStack(alignment: .leading, spacing: 20) {
                        nutritionistSection
                        weekSummarySection
                        configSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    .padding(.bottom, 100)
                }
            }
        }
    }

    // MARK: - Gradient Header

    private var profileHeader: some View {
        ZStack(alignment: .bottom) {
            LinearGradient(
                colors: [Color.bocadoCoral, Color.bocadoOrange],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea(edges: .top)

            VStack(spacing: 20) {
                // Avatar + name
                HStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.3))
                            .frame(width: 68, height: 68)
                        Text("👩🏻")
                            .font(.system(size: 36))
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Ana García")
                            .font(.system(size: 22, weight: .heavy, design: .rounded))
                            .foregroundStyle(.white)

                        HStack(spacing: 4) {
                            Image(systemName: "link")
                                .font(.system(size: 11))
                                .foregroundStyle(Color.white.opacity(0.8))
                            Text("Dr. Ramírez")
                                .font(.system(size: 13, design: .rounded))
                                .foregroundStyle(Color.white.opacity(0.85))
                        }
                    }

                    Spacer()

                    // Edit button
                    Button {
                    } label: {
                        Image(systemName: "pencil")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.white)
                            .padding(10)
                            .background(Color.white.opacity(0.25))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 20)

                // Stats row
                HStack(spacing: 10) {
                    ProfileStatBubble(emoji: "📏", value: "\(profile.heightCm)", unit: "cm",   label: "Estatura")
                    ProfileStatBubble(emoji: "⚖️", value: "\(profile.weightKg)", unit: "kg",   label: "Peso")
                    ProfileStatBubble(emoji: "🎂", value: "\(profile.ageYears)", unit: "años", label: "Edad")
                }
                .padding(.horizontal, 20)

                // Código paciente
                patientCodeCard
                    .padding(.horizontal, 20)
            }
            .padding(.top, 60)
            .padding(.bottom, 28)
        }
    }

    // MARK: - Patient Code

    private var patientCodeCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("CÓDIGO PACIENTE")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.white.opacity(0.7))
                    .kerning(1.5)
                Text(profile.patientCode)
                    .font(.system(size: 24, weight: .bold, design: .monospaced))
                    .foregroundStyle(.white)
                    .kerning(4)
            }

            Spacer()

            Image(systemName: "doc.on.doc")
                .font(.system(size: 18))
                .foregroundStyle(Color.white.opacity(0.6))
        }
        .padding(16)
        .background(Color.white.opacity(0.2))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
        )
    }

    // MARK: - Nutritionist Section

    private var nutritionistSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("MI NUTRIÓLOGO")

            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(Color.bocadoOlive.opacity(0.15))
                        .frame(width: 54, height: 54)
                    Text("👨🏻‍⚕️")
                        .font(.system(size: 28))
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(profile.nutritionistName)
                        .font(.system(size: 15, weight: .bold, design: .rounded))
                        .foregroundStyle(.black)
                    Text("Nutriólogo certificado")
                        .font(.system(size: 12, design: .rounded))
                        .foregroundStyle(Color.bocadoTextMuted)
                }

                Spacer()

                // Activo badge
                Label("Activo", systemImage: "circle.fill")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.bocadoOlive)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.bocadoOlive.opacity(0.10))
                    .clipShape(Capsule())
            }
            .padding(16)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 3)
        }
    }

    // MARK: - Week Summary

    private var weekSummarySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("RESUMEN DE LA SEMANA")

            HStack(spacing: 10) {
                WeekStatCard(emoji: "🍽️", value: "18", label: "Comidas")
                WeekStatCard(emoji: "🌿", value: "74%", label: "Balance")
                WeekStatCard(emoji: "💧", value: "12L", label: "Agua total")
            }
        }
    }

    // MARK: - Config Section

    private var configSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionTitle("CONFIGURACIÓN")

            VStack(spacing: 0) {
                ConfigRow(icon: "bell.badge.fill",        title: "Notificaciones",   iconColor: .bocadoOrange,  showDivider: true)
                ConfigRow(icon: "lock.shield.fill",       title: "Privacidad",       iconColor: .bocadoOlive,   showDivider: true)
                ConfigRow(icon: "questionmark.circle.fill",title: "Ayuda",           iconColor: Color(hex: "#8B5CF6"), showDivider: true)
                ConfigRow(icon: "arrow.right.square.fill",title: "Cerrar sesión",   iconColor: .bocadoCoral,   showDivider: false, isDestructive: true)
            }
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 3)
        }
    }

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .bold, design: .rounded))
            .foregroundStyle(Color.black.opacity(0.35))
            .kerning(1.5)
    }
}

// MARK: - ProfileStatBubble

struct ProfileStatBubble: View {
    let emoji: String
    let value: String
    let unit: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Text(emoji)
                .font(.system(size: 20))
            HStack(alignment: .firstTextBaseline, spacing: 1) {
                Text(value)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text(unit)
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.white.opacity(0.8))
            }
            Text(label)
                .font(.system(size: 10, design: .rounded))
                .foregroundStyle(Color.white.opacity(0.75))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.2))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

// MARK: - WeekStatCard

struct WeekStatCard: View {
    let emoji: String
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 6) {
            Text(emoji)
                .font(.system(size: 24))
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(.black)
            Text(label)
                .font(.system(size: 11, design: .rounded))
                .foregroundStyle(Color.bocadoTextMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
    }
}

// MARK: - ConfigRow

struct ConfigRow: View {
    let icon: String
    let title: String
    var iconColor: Color = .black
    var showDivider: Bool = true
    var isDestructive: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isDestructive ? Color.bocadoCoral.opacity(0.12) : iconColor.opacity(0.10))
                        .frame(width: 32, height: 32)
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(isDestructive ? Color.bocadoCoral : iconColor)
                }

                Text(title)
                    .font(.system(size: 15, design: .rounded))
                    .foregroundStyle(isDestructive ? Color.bocadoCoral : .black)

                Spacer()

                if !isDestructive {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color.black.opacity(0.2))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)

            if showDivider {
                Divider()
                    .padding(.leading, 62)
            }
        }
    }
}

// MARK: - ProfileStatCard legacy (para compatibilidad)
struct ProfileStatCard: View {
    let value: String
    let unit: String
    let label: String
    var body: some View {
        VStack(spacing: 2) {
            HStack(alignment: .firstTextBaseline, spacing: 1) {
                Text(value)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text(unit)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.white.opacity(0.8))
            }
            Text(label)
                .font(.system(size: 11, design: .rounded))
                .foregroundStyle(Color.white.opacity(0.75))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.2))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    ProfileView()
}

