import SwiftUI
 
// MARK: - LaunchView
// Splash screen automático: ilustración full screen + círculo de carga.
// Entra solo a la app sin que el usuario toque nada.
//
// SETUP:
// 1. Arrastra tu ilustración a Assets.xcassets
// 2. Nómbrala "launch_illustration"
// 3. Listo
 
struct LaunchView: View {
 
    @State private var showMain     = false
    @State private var opacity      : Double  = 0.0
    @State private var logoOpacity  : Double  = 0.0
    @State private var logoOffset   : CGFloat = 16
    @State private var progress     : Double  = 0.0
 
    var body: some View {
        ZStack {
            if showMain {
                ContentView()
                    .transition(.opacity)
            } else {
                splashContent
            }
        }
        .animation(.easeInOut(duration: 0.45), value: showMain)
    }
 
    // MARK: - Splash
 
    private var splashContent: some View {
        ZStack(alignment: .bottom) {
 
            // ── Ilustración full screen ───────────────────────────────
            if UIImage(named: "launch_illustration") != nil {
                Image("launch_illustration")
                    .resizable()
                    .ignoresSafeArea()
            } else {
                // Placeholder mientras agregas tu imagen
                ZStack {
                    Color(hex: "#FAD7D0").ignoresSafeArea()
                    VStack(spacing: 12) {
                        Text("🍽️").font(.system(size: 80))
                        Text("Agrega \"launch_illustration\"\nen Assets.xcassets")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundStyle(Color(hex: "#E05570").opacity(0.6))
                            .multilineTextAlignment(.center)
                    }
                }
            }
 
            // ── Degradado abajo para legibilidad ─────────────────────
            LinearGradient(
                colors: [
                    Color.black.opacity(0.0),
                    Color.black.opacity(0.38)
                ],
                startPoint: .center,
                endPoint: .bottom
            )
            .ignoresSafeArea()
 
            // ── Logo + loader abajo ───────────────────────────────────
            VStack(spacing: 20) {

                VStack(spacing: 4) {
                    Text("Bocado")
                        .font(.system(size: 36, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white)

                    Text("Come mejor, un bocado a la vez")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.white.opacity(0.75))
                }
                .opacity(logoOpacity)
                .offset(y: logoOffset)

                // ── Círculo de carga ──────────────────────────────────
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.25), lineWidth: 3)
                        .frame(width: 36, height: 36)

                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            Color.white,
                            style: StrokeStyle(lineWidth: 3, lineCap: .round)
                        )
                        .frame(width: 36, height: 36)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 2.0), value: progress)
                }
                .opacity(logoOpacity)

                // ── Aviso IA ──────────────────────────────────────────
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Color.white.opacity(0.7))
                        .padding(.top, 1)

                    Text("App de IA Generativa · No sustituye dietas médicas. Consulta siempre a un especialista — esta herramienta puede cometer errores.")
                        .font(.system(size: 11, weight: .regular, design: .rounded))
                        .foregroundStyle(Color.white.opacity(0.6))
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, 32)
                .opacity(logoOpacity)
            }
            .padding(.bottom, 40)
        }
        .opacity(opacity)
        .onAppear {
            startSplash()
        }
    }
 
    // MARK: - Animaciones + auto-dismiss
 
    private func startSplash() {
        // Fade in de toda la pantalla
        withAnimation(.easeIn(duration: 0.4)) {
            opacity = 1.0
        }
 
        // Logo aparece con delay
        withAnimation(.easeOut(duration: 0.5).delay(0.3)) {
            logoOpacity = 1.0
            logoOffset  = 0
        }
 
        // Círculo se llena durante 2s
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            progress = 1.0
        }
 
        // Auto-dismiss al terminar el círculo
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(.easeInOut(duration: 0.5)) {
                showMain = true
            }
        }
    }
}
 
#Preview {
    LaunchView()
}
