import SwiftUI

// MARK: - ScanResultView

struct ScanResultView: View {
    let image    : UIImage
    let analysis : MealAnalysis
    let onSave   : () -> Void
    let onRescan : () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {

                    plateImage
                        .padding(.top, 8)

                    dishNameSection
                        .padding(.top, 20)

                    caloriesSection
                        .padding(.top, 20)

                    Divider()
                        .padding(.horizontal, 24)
                        .padding(.top, 24)

                    macrosGrid
                        .padding(.top, 20)

                    if !analysis.recommendations.isEmpty {
                        Divider()
                            .padding(.horizontal, 24)
                            .padding(.top, 24)

                        listSection(
                            title   : "Recomendaciones ✨",
                            items   : analysis.recommendations,
                            icon    : "leaf.fill",
                            iconBg  : Color.bocadoGreen.opacity(0.15),
                            iconFg  : Color.bocadoGreen
                        )
                        .padding(.top, 20)
                    }

                    if !analysis.warnings.isEmpty {
                        listSection(
                            title   : "Advertencias ⚠️",
                            items   : analysis.warnings,
                            icon    : "exclamationmark.triangle.fill",
                            iconBg  : Color.bocadoCoral.opacity(0.12),
                            iconFg  : Color.bocadoCoral
                        )
                        .padding(.top, 16)
                    }

                    actionButtons
                        .padding(.top, 32)
                        .padding(.bottom, 40)
                }
            }
            .background(Color.bocadoCream.ignoresSafeArea())
            .navigationTitle("Tu análisis")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(Color.black.opacity(0.3))
                    }
                }
            }
        }
    }

    // MARK: - Plate Image

    private var plateImage: some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFill()
            .frame(height: 220)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white, lineWidth: 3))
            .shadow(color: .black.opacity(0.12), radius: 16, x: 0, y: 6)
            .padding(.horizontal, 24)
    }

    // MARK: - Dish Name

    private var dishNameSection: some View {
        Text(analysis.dishName ?? "Platillo no identificado")
            .font(.system(size: 22, weight: .heavy, design: .rounded))
            .foregroundStyle(Color.bocadoTextDark)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 24)
    }

    // MARK: - Calories

    private var caloriesSection: some View {
        VStack(spacing: 2) {
            Text(analysis.calories.map { "\($0)" } ?? "—")
                .font(.system(size: 48, weight: .heavy, design: .rounded))
                .foregroundStyle(Color.bocadoCoral)
            Text("kcal")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.bocadoTextMuted)
        }
    }

    // MARK: - Macros Grid

    private var macrosGrid: some View {
        LazyVGrid(
            columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())],
            spacing: 12
        ) {
            MacroCell(label: "Proteína",  value: analysis.protein,       unit: "g",  color: Color.bocadoOlive)
            MacroCell(label: "Carbos",    value: analysis.carbohydrates,  unit: "g",  color: Color.bocadoOrange)
            MacroCell(label: "Grasa",     value: analysis.fat,            unit: "g",  color: Color(hex: "#E07E35"))
            MacroCell(label: "Fibra",     value: analysis.fiber,          unit: "g",  color: Color(hex: "#6B9E5E"))
            MacroCell(label: "Sodio",     value: analysis.sodium,         unit: "mg", color: Color(hex: "#8B5CF6"))
            MacroCell(label: "Azúcar",    value: analysis.sugar,          unit: "g",  color: Color.bocadoCoral)
        }
        .padding(.horizontal, 24)
    }

    // MARK: - List Section (recommendations / warnings)

    @ViewBuilder
    private func listSection(
        title  : String,
        items  : [String],
        icon   : String,
        iconBg : Color,
        iconFg : Color
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .foregroundStyle(Color.black.opacity(0.75))
                .padding(.horizontal, 24)

            VStack(spacing: 10) {
                ForEach(Array(items.enumerated()), id: \.offset) { _, text in
                    HStack(alignment: .top, spacing: 12) {
                        ZStack {
                            Circle().fill(iconBg).frame(width: 32, height: 32)
                            Image(systemName: icon)
                                .font(.system(size: 14))
                                .foregroundStyle(iconFg)
                        }
                        Text(text)
                            .font(.bocadoBody(14))
                            .foregroundStyle(Color(hex: "#2E2E2E"))
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer()
                    }
                    .padding(14)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
                }
            }
            .padding(.horizontal, 24)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button {
                onSave()
                dismiss()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "square.and.arrow.down")
                    Text("Guardar en mi Diario")
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                }
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color.bocadoGreen)
                .clipShape(Capsule())
            }

            Button {
                onRescan()
                dismiss()
            } label: {
                Text("Escanear otro platillo")
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.black.opacity(0.5))
            }
        }
        .padding(.horizontal, 24)
    }
}

// MARK: - MacroCell

private struct MacroCell: View {
    let label : String
    let value : Double?
    let unit  : String
    let color : Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value.map { String(format: "%.1f", $0) } ?? "—")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(color)
            Text(unit)
                .font(.system(size: 11, weight: .medium, design: .rounded))
                .foregroundStyle(Color.bocadoTextMuted)
            Text(label)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.bocadoTextDark.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.04), radius: 6, x: 0, y: 2)
    }
}

// MARK: - FlowLayout

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var height: CGFloat = 0
        var x: CGFloat = 0
        var rowHeight: CGFloat = 0
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 { height += rowHeight + spacing; x = 0; rowHeight = 0 }
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
        return CGSize(width: maxWidth, height: height + rowHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX, x > bounds.minX { y += rowHeight + spacing; x = bounds.minX; rowHeight = 0 }
            view.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}

#Preview {
    ScanResultView(
        image: UIImage(systemName: "fork.knife.circle.fill")!,
        analysis: MealAnalysis(
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
        ),
        onSave  : {},
        onRescan: {}
    )
}
