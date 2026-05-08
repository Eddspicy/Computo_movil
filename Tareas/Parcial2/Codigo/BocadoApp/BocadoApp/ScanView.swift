import SwiftUI
import UIKit
import AVFoundation

// MARK: - ScanView
// Pantalla principal tipo Shazam: toca el círculo central para escanear.
// Para usar tu logo PNG: arrastra tu imagen a Assets.xcassets,
// nómbrala "bocado_logo" y se mostrará automáticamente en el círculo.
 
struct ScanView: View {
 
    // ── Estado del flujo ──────────────────────────────────────────────
    @State private var showCamera          = false
    @State private var capturedImage       : UIImage?
    @State private var analysisResult      : MealAnalysis?
    @State private var showResult          = false
    @State private var isAnalyzing         = false
    @State private var errorMessage  : String?
    @State private var lastError     : AIError?
    @State private var showError     = false

    private var errorAlertTitle: String { lastError?.alertTitle ?? "Algo salió mal 😅" }
    @State private var showPermissionAlert      = false

    private var isCameraAvailable: Bool { CameraPickerView.isCameraAvailable }
 
    // ── Animación ─────────────────────────────────────────────────────
    @State private var pulseScale  : CGFloat = 1.0
    @State private var glowOpacity : Double  = 0.4
    @State private var scanPressed : Bool    = false
    @State private var logoAppeared: Bool    = false
 
    private let profile = UserProfile()
 
    // Detecta si el usuario tiene su propio PNG en Assets
    private var hasCustomLogo: Bool {
        UIImage(named: "bocado_logo") != nil
    }
 
    var body: some View {
        ZStack {
            // ── Fondo gradiente ───────────────────────────────────────
            LinearGradient.bocadoScanGradient
                .ignoresSafeArea()
 
            // Orbes decorativos
            Circle()
                .fill(Color.white.opacity(0.12))
                .frame(width: 320, height: 320)
                .blur(radius: 60)
                .offset(x: 120, y: 260)
 
            Circle()
                .fill(Color.white.opacity(0.08))
                .frame(width: 200, height: 200)
                .blur(radius: 40)
                .offset(x: -100, y: -180)
 
            VStack(spacing: 0) {
 
                // ── Nav bar ───────────────────────────────────────────
                scanNavBar
                    .padding(.top, 56)
 
                Spacer()
 
                // ── Título ────────────────────────────────────────────
                Text("Tap your bocado")
                    .font(.system(size: 40, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
                    .padding(.bottom, 44)
                    .opacity(logoAppeared ? 1 : 0)
                    .offset(y: logoAppeared ? 0 : 12)
 
                // ── Círculo Shazam (botón principal) ──────────────────
                shazamCircle
                    .scaleEffect(logoAppeared ? 1 : 0.85)
                    .opacity(logoAppeared ? 1 : 0)
 
                // ── Hint ──────────────────────────────────────────────
                VStack(spacing: 6) {
                    Text("toca para escanear")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.white.opacity(0.6))
                        .kerning(1.2)

                    if !isCameraAvailable {
                        Label("usando galería de fotos", systemImage: "photo.on.rectangle")
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundStyle(Color.white.opacity(0.45))
                    }
                }
                .padding(.top, 16)
                .opacity(logoAppeared ? 1 : 0)
 
                Spacer()
 
                // ── Mini stats ────────────────────────────────────────
                miniStatsRow
                    .padding(.horizontal, 24)
                    .padding(.bottom, 100)   // espacio para tab bar
                    .opacity(logoAppeared ? 1 : 0)
            }
 
            // ── Overlay análisis ──────────────────────────────────────
            if isAnalyzing {
                analyzingOverlay
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.75).delay(0.1)) {
                logoAppeared = true
            }
            startPulse()
        }
        .sheet(isPresented: $showCamera) {
            CameraPickerView(
                capturedImage: $capturedImage,
                isPresented  : $showCamera
            )
            .ignoresSafeArea()
        }
        .sheet(isPresented: $showResult) {
            if let img = capturedImage, let analysis = analysisResult {
                ScanResultView(
                    image   : img,
                    analysis: analysis,
                    onSave  : { saveToMockDiary() },
                    onRescan: { resetScan() }
                )
            }
        }
        .alert(errorAlertTitle, isPresented: $showError) {
            Button("Reintentar") { if capturedImage != nil { triggerAnalysis() } }
            Button("Cancelar", role: .cancel) { resetScan() }
        } message: {
            Text(errorMessage ?? "Error desconocido")
        }
        .alert("Cámara no disponible", isPresented: $showPermissionAlert) {
            Button("Abrir Configuración") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancelar", role: .cancel) {}
        } message: {
            Text("Bocado necesita acceso a tu cámara para analizar tus comidas. Actívalo en Configuración > Bocado.")
        }
        .onChange(of: capturedImage) { _, newImage in
            if newImage != nil { triggerAnalysis() }
        }
    }
 
    // MARK: - Nav bar
 
    private var scanNavBar: some View {
        HStack {
            HStack(spacing: 8) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white.opacity(0.25))
                    .frame(width: 36, height: 36)
                    .overlay {
                        Text("🍽️")
                            .font(.system(size: 18))
                    }
                Text("Bocado")
                    .font(.system(size: 20, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
            }
 
            Spacer()
 
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 36, height: 36)
                Image(systemName: "bell.fill")
                    .font(.system(size: 15))
                    .foregroundStyle(.white)
            }
        }
        .padding(.horizontal, 20)
    }
 
    // MARK: - Shazam Circle (botón principal)
 
    private var shazamCircle: some View {
        Button {
            withAnimation(.spring(response: 0.18, dampingFraction: 0.7)) {
                scanPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                withAnimation { scanPressed = false }
                requestCameraAccess()
            }
        } label: {
            ZStack {
                // Anillo exterior pulsante
                Circle()
                    .fill(Color.white.opacity(0.10 * glowOpacity))
                    .frame(width: 290, height: 290)
                    .scaleEffect(pulseScale * 1.08)
                    .blur(radius: 2)
 
                // Anillo medio
                Circle()
                    .fill(Color.white.opacity(0.18))
                    .frame(width: 240, height: 240)
                    .overlay {
                        Circle()
                            .stroke(Color.white.opacity(0.30), lineWidth: 1.5)
                    }
                    .scaleEffect(pulseScale)
 
                // Círculo glassmorphism central
                Circle()
                    .fill(Color.white.opacity(0.32))
                    .frame(width: 185, height: 185)
                    .overlay {
                        Circle()
                            .stroke(Color.white.opacity(0.60), lineWidth: 2)
                    }
                    .shadow(color: .black.opacity(0.12), radius: 30, x: 0, y: 10)
 
                // ── Logo: PNG propio o fallback SVG ───────────────────
                logoContent
            }
        }
        .scaleEffect(scanPressed ? 0.95 : 1.0)
        .buttonStyle(.plain)
        .animation(.spring(response: 0.18, dampingFraction: 0.7), value: scanPressed)
    }
 
    // MARK: - Logo content
    // Si tienes "bocado_logo" en Assets.xcassets → muestra tu PNG.
    // Si no → muestra el logo SVG de respaldo.
 
    @ViewBuilder
    private var logoContent: some View {
        if hasCustomLogo {
            Image("bocado_logo")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 24))
        } else {
            // Fallback: cara Bocado con SwiftUI shapes
            VStack(spacing: 0) {
                HStack(spacing: 38) {
                    Capsule()
                        .fill(Color.bocadoOlive)
                        .frame(width: 18, height: 26)
                    Text("🍴")
                        .font(.system(size: 24))
                }
                .padding(.bottom, 12)
 
                SmileyArc()
                    .stroke(
                        Color.bocadoCoral,
                        style: StrokeStyle(lineWidth: 5, lineCap: .round)
                    )
                    .frame(width: 60, height: 26)
            }
            .offset(y: 4)
        }
    }
 
    // MARK: - Mini stats row
 
    private var miniStatsRow: some View {
        HStack(spacing: 10) {
            ScanStatBubble(emoji: "⚖️", value: "78%",  label: "Balance")
            ScanStatBubble(emoji: "🍽️", value: "3/5",  label: "Comidas")
            ScanStatBubble(emoji: "💧", value: "1.8L", label: "Agua")
        }
    }
 
    // MARK: - Analyzing overlay

    private var analyzingOverlay: some View {
        ZStack {
            // ── Blur sobre lo que hay detrás ──────────────────────────
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()

            VStack(spacing: 28) {

                // ── Spinner de arcos giratorios ───────────────────────
                BocadoSpinner()
                    .frame(width: 72, height: 72)

                VStack(spacing: 6) {
                    Text("Analizando tu plato…")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.bocadoTextDark)

                    Text("La IA está revisando tu comida")
                        .font(.bocadoBody(13))
                        .foregroundStyle(Color.bocadoTextMuted)
                        .multilineTextAlignment(.center)
                }
            }
        }
    }
 
    // MARK: - Logic

    private func requestCameraAccess() {
        guard isCameraAvailable else {
            showCamera = true   // no camera hardware → go straight to gallery picker
            return
        }
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            showCamera = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted { showCamera = true }
                }
            }
        case .denied, .restricted:
            showPermissionAlert = true
        @unknown default:
            showCamera = true
        }
    }

    private func triggerAnalysis() {
        guard let img = capturedImage else { return }
        isAnalyzing = true
        Task {
            do {
                let result = try await AIService.shared.analyzeMeal(image: img, profile: profile)
                analysisResult = result
                isAnalyzing    = false
                showResult     = true
            } catch {
                isAnalyzing  = false
                lastError    = error as? AIError
                errorMessage = error.localizedDescription
                showError    = true
            }
        }
    }
 
    private func resetScan() {
        capturedImage  = nil
        analysisResult = nil
    }
 
    private func saveToMockDiary() {
        print("✅ Guardado en diario:", analysisResult?.dishName ?? "sin nombre")
    }
 
    private func startPulse() {
        withAnimation(
            .easeInOut(duration: 2.2)
            .repeatForever(autoreverses: true)
        ) {
            pulseScale  = 1.06
            glowOpacity = 1.0
        }
    }
}
 
// MARK: - Smiley Arc Shape
 
struct SmileyArc: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addCurve(
            to: CGPoint(x: rect.maxX, y: rect.minY),
            control1: CGPoint(x: rect.minX, y: rect.maxY * 1.8),
            control2: CGPoint(x: rect.maxX, y: rect.maxY * 1.8)
        )
        return path
    }
}
 
// MARK: - ScanStatBubble
 
struct ScanStatBubble: View {
    let emoji: String
    let value: String
    let label: String
 
    var body: some View {
        VStack(spacing: 4) {
            Text(emoji)
                .font(.system(size: 22))
            Text(value)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            Text(label)
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundStyle(Color.white.opacity(0.75))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color.white.opacity(0.2))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
        )
    }
}
 
// MARK: - MiniStatCard (alias para compatibilidad con otros archivos)
 
struct MiniStatCard: View {
    let value : String
    let label : String
    let color : Color
    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(color)
            Text(label)
                .font(.system(size: 11, design: .rounded))
                .foregroundStyle(Color.bocadoTextMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.black.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
 
// MARK: - BocadoSpinner

struct BocadoSpinner: View {
    @State private var rotate = false

    private let colors: [Color] = [.bocadoCoral, .bocadoOrange, .bocadoOlive]

    var body: some View {
        ZStack {
            ForEach(0..<3, id: \.self) { i in
                Circle()
                    .trim(from: 0.05, to: 0.45)
                    .stroke(
                        colors[i],
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .rotationEffect(.degrees(rotate ? Double(i) * 120 + 360 : Double(i) * 120))
                    .animation(
                        .linear(duration: 1.1)
                        .repeatForever(autoreverses: false)
                        .delay(Double(i) * 0.15),
                        value: rotate
                    )
            }
        }
        .onAppear { rotate = true }
    }
}

#Preview {
    ScanView()
}
