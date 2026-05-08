import SwiftUI
 
// MARK: - Tab enum
 
enum BocadoTab: Int, CaseIterable {
    case scan, diary, papers, profile
 
    var title: String {
        switch self {
        case .scan:    return "Escanear"
        case .diary:   return "Diario"
        case .papers:  return "News"
        case .profile: return "Perfil"
        }
    }
 
    var icon: String {
        switch self {
        case .scan:    return ""
        case .diary:   return "fork.knife"
        case .papers:  return "newspaper.fill"
        case .profile: return "person.crop.circle.fill"
        }
    }
}
 
// MARK: - ContentView
 
struct ContentView: View {
    @State private var selectedTab: BocadoTab = .scan
 
    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                switch selectedTab {
                case .scan:    ScanView()
                case .diary:   DiaryView()
                case .papers:  PapersView()
                case .profile: ProfileView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
 
            BocadoTabBar(selected: $selectedTab)
        }
        .ignoresSafeArea(edges: .bottom)
    }
}
 
// MARK: - Custom Tab Bar
 
struct BocadoTabBar: View {
    @Binding var selected: BocadoTab
 
    private var isOnScan: Bool { selected == .scan }
 
    // Orden: scan (centro-izq elevado), diary, papers, profile
    private let leftTabs:  [BocadoTab] = []
    private let rightTabs: [BocadoTab] = [.diary, .papers, .profile]
 
    var body: some View {
        ZStack(alignment: .bottom) {
 
            // ── Fondo ─────────────────────────────────────────────────
            Rectangle()
                .fill(isOnScan ? Color.white.opacity(0.15) : Color.white)
                .frame(height: 82)
                .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: -4)
 
            // ── Tabs ──────────────────────────────────────────────────
            HStack(spacing: 0) {
 
                // Scan — primer lugar, elevado
                scanCenterButton
                    .frame(maxWidth: .infinity)
 
                // Diario
                sideTabButton(.diary)
 
                // News
                sideTabButton(.papers)
 
                // Perfil
                sideTabButton(.profile)
            }
            .padding(.bottom, 20)
        }
        .animation(.easeInOut(duration: 0.25), value: selected)
    }
 
    // MARK: - Botón Scan elevado
 
    private var scanCenterButton: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selected = .scan
            }
        } label: {
            VStack(spacing: 4) {
                ZStack {
                    Circle()
                        .fill(Color.bocadoCoral.opacity(0.18))
                        .frame(width: 62, height: 62)
 
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.gradientStart, Color.gradientEnd],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 52, height: 52)
                        .shadow(color: Color.bocadoCoral.opacity(0.4),
                                radius: 8, x: 0, y: 4)
 
                    if UIImage(named: "bocado_logo") != nil {
                        Image("bocado_logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                            .clipShape(RoundedRectangle(cornerRadius: 7))
                    } else {
                        Image(systemName: "viewfinder.circle.fill")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundStyle(.white)
                    }
                }
                .offset(y: -14)
 
                Text("Escanear")
                    .font(.system(size: 10,
                                  weight: selected == .scan ? .bold : .medium,
                                  design: .rounded))
                    .foregroundStyle(
                        isOnScan ? .white
                        : (selected == .scan ? Color.bocadoCoral : Color.black.opacity(0.3))
                    )
                    .offset(y: -10)
            }
        }
        .buttonStyle(.plain)
    }
 
    // MARK: - Botones laterales
 
    @ViewBuilder
    private func sideTabButton(_ tab: BocadoTab) -> some View {
        let isActive = selected == tab
 
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selected = tab
            }
        } label: {
            VStack(spacing: 4) {
                ZStack {
                    if isActive && !isOnScan {
                        Capsule()
                            .fill(Color.bocadoCoral.opacity(0.10))
                            .frame(width: 44, height: 26)
                    }
                    Image(systemName: tab.icon)
                        .font(.system(size: 19, weight: isActive ? .semibold : .regular))
                        .foregroundStyle(itemColor(for: tab, active: isActive))
                        .symbolEffect(.bounce, value: isActive)
                }
 
                Text(tab.title)
                    .font(.system(size: 10,
                                  weight: isActive ? .bold : .regular,
                                  design: .rounded))
                    .foregroundStyle(itemColor(for: tab, active: isActive))
            }
            .padding(.vertical, 4)
        }
        .frame(maxWidth: .infinity)
        .buttonStyle(.plain)
    }
 
    private func itemColor(for tab: BocadoTab, active: Bool) -> Color {
        if isOnScan { return active ? .white : Color.white.opacity(0.55) }
        return active ? .bocadoCoral : Color.black.opacity(0.3)
    }
}
 
#Preview {
    ContentView()
}
