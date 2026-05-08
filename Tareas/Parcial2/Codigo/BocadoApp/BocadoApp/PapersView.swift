import SwiftUI

// MARK: - PapersView

struct PapersView: View {
    @State private var selectedCategory: PaperCategory = .todo
    let papers = SampleData.papers

    var filteredPapers: [Paper] {
        guard selectedCategory != .todo else { return papers }
        return papers.filter { $0.category == selectedCategory }
    }

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                // Header
                papersHeader
                    .padding(.top, 60)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)

                // Category pills
                categoryFilter
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)

                // Lista
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 12) {
                        ForEach(filteredPapers) { paper in
                            PaperCard(paper: paper)
                                .padding(.horizontal, 20)
                        }
                    }
                    .padding(.bottom, 100)
                }
            }
        }
    }

    // MARK: - Header

    private var papersHeader: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 0) {
                    Text("Apren")
                        .font(.system(size: 32, weight: .heavy, design: .rounded))
                        .foregroundStyle(.black)
                    Text("de")
                        .font(.system(size: 32, weight: .heavy, design: .rounded))
                        .foregroundStyle(Color.bocadoCoral)
                }
                Text("Papers por nutriólogos 🧪")
                    .font(.system(size: 13, design: .rounded))
                    .foregroundStyle(Color.bocadoTextMuted)
            }

            Spacer()

            // PRO badge
            Text("✨ PRO")
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(
                    LinearGradient(
                        colors: [Color.bocadoCoral, Color.bocadoOrange],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(Capsule())
        }
    }

    // MARK: - Category Filter

    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach([PaperCategory.todo, .habitos, .nutricion, .ciencia], id: \.self) { cat in
                    CategoryPill(category: cat, isSelected: selectedCategory == cat) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                            selectedCategory = cat
                        }
                    }
                }
            }
        }
    }
}

// MARK: - CategoryPill

struct CategoryPill: View {
    let category: PaperCategory
    let isSelected: Bool
    let action: () -> Void

    private var pillColor: Color {
        switch category {
        case .todo:      return Color.black
        case .habitos:   return Color.bocadoOrange
        case .nutricion: return Color.bocadoOlive
        case .ciencia:   return Color(hex: "#8B5CF6")
        }
    }

    var body: some View {
        Button(action: action) {
            Text(category.rawValue)
                .font(.system(size: 14, weight: isSelected ? .bold : .medium, design: .rounded))
                .foregroundStyle(isSelected ? .white : pillColor)
                .padding(.horizontal, 18)
                .padding(.vertical, 9)
                .background(
                    Capsule()
                        .fill(isSelected ? pillColor : pillColor.opacity(0.1))
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - PaperCard

struct PaperCard: View {
    let paper: Paper

    var body: some View {
        HStack(spacing: 14) {
            // Barra de color lateral
            RoundedRectangle(cornerRadius: 3)
                .fill(paper.category.color)
                .frame(width: 4)
                .frame(height: 64)

            VStack(alignment: .leading, spacing: 6) {
                // Badge de categoría
                HStack(spacing: 6) {
                    Text(paper.category.label)
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundStyle(paper.category.color)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(paper.category.color.opacity(0.10))
                        .clipShape(Capsule())

                    if paper.isPro {
                        Text("🔒 PRO")
                            .font(.system(size: 10, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.bocadoCoral)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(Color.bocadoCoral.opacity(0.10))
                            .clipShape(Capsule())
                    }
                }

                Text(paper.title)
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(.black)
                    .lineLimit(2)
            }

            Spacer()

            // Tiempo de lectura
            VStack(spacing: 3) {
                Text("📖")
                    .font(.system(size: 16))
                Text("\(paper.readTime)m")
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.bocadoTextMuted)
            }
        }
        .padding(16)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: .black.opacity(0.07), radius: 10, x: 0, y: 3)
    }
}

// MARK: - PaperCategory color update
extension PaperCategory {
    var displayColor: Color {
        switch self {
        case .todo:      return Color.black
        case .habitos:   return Color.bocadoOrange
        case .nutricion: return Color.bocadoOlive
        case .ciencia:   return Color(hex: "#8B5CF6")
        }
    }
}

#Preview {
    PapersView()
}

