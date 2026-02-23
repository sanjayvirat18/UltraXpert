import SwiftUI

struct OnboardingScreens: View {

    @State private var currentPage = 0
    @State private var goToLogin = false

    let pages = [
        OnboardingPage(
            image: "waveform.path.ecg",
            title: "Enhance Ultrasound Images",
            subtitle: "Improve clarity and reduce noise using AI technology."
        ),
        OnboardingPage(
            image: "lock.shield",
            title: "HIPAA Compliant",
            subtitle: "Your medical data is secure and protected."
        ),
        OnboardingPage(
            image: "sparkles",
            title: "Fast & Accurate",
            subtitle: "Get enhanced results within seconds."
        )
    ]

    var body: some View {
        VStack {

            // MARK: - Skip Button (Top Right)
            HStack {
                Spacer()
                Button("Skip") {
                    goToLogin = true
                }
                .foregroundColor(.blue)
                .padding()
            }

            TabView(selection: $currentPage) {
                ForEach(0..<pages.count, id: \.self) { index in
                    VStack(spacing: 24) {

                        Image(systemName: pages[index].image)
                            .font(.system(size: 80))
                            .foregroundColor(.blue)

                        Text(pages[index].title)
                            .font(.title2)
                            .fontWeight(.bold)

                        Text(pages[index].subtitle)
                            .font(.body)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)

                    }
                    .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))

            Spacer()

            // MARK: - Next / Get Started Button
            Button(action: {
                if currentPage < pages.count - 1 {
                    currentPage += 1
                } else {
                    goToLogin = true
                }
            }) {
                Text(currentPage == pages.count - 1 ? "Get Started" : "Next")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(14)
                    .padding(.horizontal, 24)
            }
            .padding(.bottom, 30)

            // Hidden Navigation
            NavigationLink(destination: LoginScreen(), isActive: $goToLogin) {
                EmptyView()
            }
        }
    }
}

struct OnboardingPage {
    let image: String
    let title: String
    let subtitle: String
}

#Preview {
    NavigationStack {
        OnboardingScreens()
    }
}
