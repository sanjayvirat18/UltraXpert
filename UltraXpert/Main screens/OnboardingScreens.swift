import SwiftUI

// MARK: - Color Palette for Onboarding
fileprivate extension Color {
    static let onboardBg        = Color(red: 0.97, green: 0.98, blue: 1.0)   // near-white with cool tint
    static let onboardBlue      = Color(red: 0.08, green: 0.46, blue: 0.96)  // strong blue
    static let onboardCyan      = Color(red: 0.12, green: 0.72, blue: 0.95)  // soft cyan
    static let onboardCardBg    = Color(red: 0.93, green: 0.96, blue: 1.0)   // very light blue card
    static let onboardTextMain  = Color(red: 0.08, green: 0.10, blue: 0.18)  // near black
    static let onboardTextSub   = Color(red: 0.38, green: 0.42, blue: 0.52)  // medium gray-blue
}

struct OnboardingScreens: View {
    @State private var currentPage = 0
    let onFinish: () -> Void

    // Read saved dark mode preference
    @AppStorage("darkModeEnabled") private var darkModeEnabled: Bool = false

    let pages: [OnboardingPage] = [
        OnboardingPage(
            image: "waveform.path.ecg.rectangle.fill",
            title: "AI-Powered Analysis",
            subtitle: "Transform raw ultrasound scans into crystal-clear diagnostic images with our advanced AI engine."
        ),
        OnboardingPage(
            image: "shield.checkerboard",
            title: "Secure & Compliant",
            subtitle: "Bank-grade encryption ensures your patient data remains private and HIPAA compliant."
        ),
        OnboardingPage(
            image: "sparkles.rectangle.stack.fill",
            title: "Instant Clinical Insights",
            subtitle: "Get automated measurements and pathology detection in seconds, not minutes."
        )
    ]

    var body: some View {
        ZStack {
            // MARK: - Background
            (darkModeEnabled ? Color.black : Color.onboardBg)
                .ignoresSafeArea()

            // Soft decorative blobs
            Circle()
                .fill(Color.onboardBlue.opacity(darkModeEnabled ? 0.12 : 0.07))
                .frame(width: 350, height: 350)
                .blur(radius: 80)
                .offset(x: -120, y: -280)

            Circle()
                .fill(Color.onboardCyan.opacity(darkModeEnabled ? 0.10 : 0.08))
                .frame(width: 280, height: 280)
                .blur(radius: 60)
                .offset(x: 140, y: 200)

            VStack(spacing: 0) {
                // MARK: - Skip Button
                HStack {
                    Spacer()
                    Button(action: onFinish) {
                        Text("Skip")
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundColor(darkModeEnabled ? .white.opacity(0.6) : .onboardTextSub)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(Color.onboardBlue.opacity(0.10))
                            )
                    }
                    .padding(.top, 12)
                    .padding(.trailing, 20)
                }

                // MARK: - Paging Content
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut, value: currentPage)

                // MARK: - Bottom Controls
                VStack(spacing: 28) {

                    // Page dots
                    HStack(spacing: 8) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            if index == currentPage {
                                Capsule()
                                    .fill(LinearGradient(
                                        colors: [.onboardBlue, .onboardCyan],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ))
                                    .frame(width: 28, height: 8)
                                    .transition(.scale)
                            } else {
                                Circle()
                                    .fill(Color.onboardBlue.opacity(0.2))
                                    .frame(width: 8, height: 8)
                            }
                        }
                    }
                    .animation(.spring(), value: currentPage)

                    // Primary Button
                    Button(action: { handleNext() }) {
                        HStack(spacing: 8) {
                            Text(currentPage == pages.count - 1 ? "Get Started" : "Next")
                                .font(.system(size: 18, weight: .bold, design: .rounded))

                            if currentPage != pages.count - 1 {
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 16, weight: .bold))
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            LinearGradient(
                                colors: [.onboardBlue, .onboardCyan],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(color: .onboardBlue.opacity(0.25), radius: 12, x: 0, y: 6)
                    }
                    .padding(.horizontal, 24)
                }
                .padding(.bottom, 50)
            }
        }
        .preferredColorScheme(darkModeEnabled ? .dark : .light)
    }

    private func handleNext() {
        withAnimation {
            if currentPage < pages.count - 1 {
                currentPage += 1
            } else {
                onFinish()
            }
        }
    }
}

// MARK: - Subviews

struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Icon Card
            ZStack {
                // Outer soft glow
                Circle()
                    .fill(Color.onboardBlue.opacity(0.15))
                    .frame(width: 220, height: 220)
                    .blur(radius: 24)

                // Adaptive card circle — white in light, dark card in dark mode
                Circle()
                    .fill(Color(.secondarySystemBackground))
                    .frame(width: 180, height: 180)
                    .shadow(color: Color.onboardBlue.opacity(0.20), radius: 20, x: 0, y: 8)
                    .overlay(
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color.onboardBlue.opacity(0.4),
                                        Color.onboardCyan.opacity(0.15)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1.5
                            )
                    )

                // Icon
                Image(systemName: page.image)
                    .font(.system(size: 68))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.onboardBlue, .onboardCyan],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: .onboardBlue.opacity(0.25), radius: 6, x: 0, y: 3)
            }
            .padding(.bottom, 12)

            // Text Block
            VStack(spacing: 14) {
                Text(page.title)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)        // white in dark, near-black in light

                Text(page.subtitle)
                    .font(.system(size: 16, weight: .regular))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)     // light gray in dark, gray-blue in light
                    .padding(.horizontal, 36)
                    .lineSpacing(5)
            }

            Spacer()
        }
    }
}

// MARK: - Model
struct OnboardingPage {
    let image: String
    let title: String
    let subtitle: String
}

#Preview {
    OnboardingScreens(onFinish: {})
}
