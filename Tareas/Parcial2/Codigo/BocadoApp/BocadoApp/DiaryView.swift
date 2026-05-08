import SwiftUI

// MARK: - DiaryView

struct DiaryView: View {
    let meals = SampleData.meals
    let balanceScore: Int = 78

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    diaryHeader
                        .padding(.top, 60)
                        .padding(.horizontal, 20)

                    // Balance card
                    BalanceCard(score: balanceScore)
                        .padding(.horizontal, 20)

                    // Comidas
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("COMIDAS DE HOY")
                                .font(.system(size: 11, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.black.opacity(0.35))
                                .kerning(1.5)
                            Spacer()
                            Text("Dom 20 Abr")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundStyle(Color.bocadoTextMuted)
                        }
                        .padding(.horizontal, 20)

                        ForEach(meals) { meal in
                            MealCard(meal: meal)
                                .padding(.horizontal, 20)
                        }
                    }

                    Spacer(minLength: 100)
                }
            }
        }
    }

    // MARK: - Header

    private var diaryHeader: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 0) {
                    Text("Mi ")
                        .font(.system(size: 32, weight: .heavy, design: .rounded))
                        .foregroundStyle(.black)
                    Text("diario")
                        .font(.system(size: 32, weight: .heavy, design: .rounded))
                        .foregroundStyle(Color.bocadoCoral)
                }
                Text(formattedDate)
                    .font(.system(size: 13, design: .rounded))
                    .foregroundStyle(Color.bocadoTextMuted)
            }

            Spacer()

            // Semana badge
            Text("Semana 3")
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(Color.bocadoCoral)
                .clipShape(Capsule())
        }
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE d MMM · yyyy"
        formatter.locale = Locale(identifier: "es_MX")
        return formatter.string(from: Date()).capitalized
    }
}

// MARK: - BalanceCard

struct BalanceCard: View {
    let score: Int
    @State private var animatedScore: Int = 0

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Label("Balance del día", systemImage: "chart.bar.fill")
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.bocadoOlive.opacity(0.8))

                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("\(animatedScore)")
                        .font(.system(size: 52, weight: .heavy, design: .rounded))
                        .foregroundStyle(Color.bocadoOlive)
                    Text("%")
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.bocadoOlive.opacity(0.7))
                }

                Text("🌿 Buen progreso")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.bocadoOlive.opacity(0.75))
            }

            Spacer()

            // Ring
            ZStack {
                Circle()
                    .stroke(Color.bocadoOlive.opacity(0.12), lineWidth: 10)
                    .frame(width: 72, height: 72)

                Circle()
                    .trim(from: 0, to: CGFloat(animatedScore) / 100)
                    .stroke(
                        Color.bocadoOlive,
                        style: StrokeStyle(lineWidth: 10, lineCap: .round)
                    )
                    .frame(width: 72, height: 72)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut(duration: 1.2), value: animatedScore)

                Text("\(animatedScore)")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.bocadoOlive)
            }
        }
        .padding(20)
        .background(Color.bocadoOlive.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.bocadoOlive.opacity(0.15), lineWidth: 1)
        )
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation { animatedScore = score }
            }
        }
    }
}

// MARK: - MealCard

struct MealCard: View {
    let meal: Meal

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                // Thumbnail emoji en cuadro redondeado
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(meal.status.bgColor)
                        .frame(width: 54, height: 54)
                    Text(meal.thumbnail)
                        .font(.system(size: 30))
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(meal.name)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(.black)
                    Text(meal.time)
                        .font(.system(size: 13, design: .rounded))
                        .foregroundStyle(Color.bocadoTextMuted)
                }

                Spacer()

                // Status badge
                Text(meal.status.label)
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(meal.status.color)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(meal.status.color.opacity(0.1))
                    .clipShape(Capsule())
            }

            // Emojis ingredientes
            if !meal.emojis.isEmpty {
                HStack(spacing: 2) {
                    ForEach(meal.emojis, id: \.self) { emoji in
                        Text(emoji)
                            .font(.system(size: 26))
                    }
                }
                .padding(.horizontal, 4)
            }

            // Le faltó
            if !meal.missingEmojis.isEmpty {
                HStack(spacing: 8) {
                    Label("Le faltó:", systemImage: "exclamationmark.circle.fill")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.bocadoCoral)
                    ForEach(meal.missingEmojis, id: \.self) { emoji in
                        Text(emoji)
                            .font(.system(size: 24))
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 7)
                .background(Color.bocadoCoral.opacity(0.07))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding(16)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.07), radius: 12, x: 0, y: 3)
    }
}

// MARK: - MealStatus background color
extension MealStatus {
    var bgColor: Color {
        switch self {
        case .complete: return Color.bocadoOlive.opacity(0.12)
        case .missing:  return Color.bocadoCoral.opacity(0.10)
        case .pending:  return Color.bocadoTextMuted.opacity(0.10)
        }
    }
}

#Preview {
    DiaryView()
}

