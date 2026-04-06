import SwiftUI

struct SplashScreen: View {

    @State private var logoScale: CGFloat = 0.5  // For pop effect
    @State private var isPulsing: Bool = false
    @State private var glowOpacity: Double = 0.3

    // Read saved dark mode preference directly from UserDefaults
    @AppStorage("darkModeEnabled") private var darkModeEnabled: Bool = false
    @AppStorage("themeColor") private var themeColorName: String = "Blue"

    private var themeColor: Color { ThemeManager.shared.color(for: themeColorName) }

    // Closure to notify when splash finishes
    var onFinish: () -> Void

    var body: some View {
        ZStack {
            (darkModeEnabled ? Color.black : Color.white)
                .ignoresSafeArea()

            VStack(spacing: 24) {

                // Logo with professional pulse and glow effects
                ZStack {
                    // Outer pulsing glow
                    Circle()
                        .fill(themeColor.opacity(0.15))
                        .frame(width: 260, height: 260)
                        .scaleEffect(isPulsing ? 1.4 : 0.8)
                        .opacity(isPulsing ? 0 : 1)
                    
                    // Inner dynamic glow
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [themeColor.opacity(glowOpacity), Color.clear]),
                                center: .center,
                                startRadius: 10,
                                endRadius: 120
                            )
                        )
                        .frame(width: 240, height: 240)
                    
                    Image("Applogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 380, height: 180)
                        .shadow(color: themeColor.opacity(0.7), radius: 25, x: 0, y: 8)
                        .shadow(color: Color.white.opacity(darkModeEnabled ? 0.1 : 0.5), radius: 5, x: 0, y: -2)
                }
                .scaleEffect(logoScale)
                .animation(.spring(response: 0.6, dampingFraction: 0.6, blendDuration: 0), value: logoScale)

                Text("UltraXpert")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(themeColor)

                Text("AI-powered Ultrasound Enhancement")
                    .font(.system(size: 18))
                    .foregroundColor(darkModeEnabled ? .gray : .gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
        }
        .preferredColorScheme(darkModeEnabled ? .dark : .light)
        .onAppear {
            // Pop-in animation
            withAnimation {
                logoScale = 1.0
            }
            
            // Continuous pulse and glow effect
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: false)) {
                isPulsing = true
            }
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                glowOpacity = 0.6
            }

            // Call onFinish closure after 2.5 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation {
                    onFinish()
                }
            }
        }
    }
}

#Preview {
    SplashScreen {
        // Example: Print or navigate to next screen in preview
        print("Splash finished!")
    }
}
