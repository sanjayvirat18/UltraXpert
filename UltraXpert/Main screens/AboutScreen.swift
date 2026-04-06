import SwiftUI

struct AboutScreen: View {

    @AppStorage("themeColor") private var themeColorName = "Blue"

    var body: some View {
        ScrollView {
            VStack(spacing: 34) {

                // MARK: App Header
                VStack(spacing: 10) {
                    Image("Applogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300, height: 150)
                        .clipShape(RoundedRectangle(cornerRadius: 20))

                    Text("UltraXpert 2.0")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("AI-powered ultrasound image enhancement for faster and clearer diagnosis.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                // MARK: About App
                VStack(alignment: .leading, spacing: 12) {
                    Text("About the App")
                        .font(.headline)

                    Text("""
UltraVision AI is designed to support doctors and healthcare providers by enhancing ultrasound images using AI. The goal is to improve visibility, reduce noise, and help in better interpretation—especially in rural clinics and NGO setups.
""")
                        .font(.body)
                        .foregroundColor(.primary)
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemBackground)))

                // MARK: Key Features
                VStack(alignment: .leading, spacing: 12) {
                    Text("Key Features")
                        .font(.headline)

                    FeatureRow(icon: "sparkles", title: "AI Enhancement", subtitle: "Automatically improves ultrasound image quality.")
                    FeatureRow(icon: "shield.lefthalf.filled", title: "Privacy Protection", subtitle: "Patient data is handled securely and safely.")
                    FeatureRow(icon: "iphone", title: "Mobile Friendly", subtitle: "Simple and accessible interface for clinics.")
                    FeatureRow(icon: "stethoscope", title: "Healthcare Support", subtitle: "Made for doctors, NGOs and rural healthcare use.")
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemBackground)))

                // MARK: App Info
                VStack(alignment: .leading, spacing: 10) {
                    Text("App Information")
                        .font(.headline)

                    HStack {
                        Text("Version")
                        Spacer()
                        Text(appVersion)
                            .foregroundColor(.secondary)
                    }

                    Divider()

                    HStack {
                        Text("Build")
                        Spacer()
                        Text(appBuild)
                            .foregroundColor(.secondary)
                    }

                    Divider()

                    HStack {
                        Text("Developed By")
                        Spacer()
                        Text("UltraVision Team")
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 16).fill(Color(.secondarySystemBackground)))

                // MARK: Links / Actions
                VStack(spacing: 12) {
                    Button {
                        sendEmail()
                    } label: {
                        Label("Contact Support", systemImage: "envelope.fill")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundColor(ThemeManager.shared.color(for: themeColorName))
                            .background(ThemeManager.shared.color(for: themeColorName).opacity(0.12))
                            .cornerRadius(14)
                    }

                    Button {
                        openPrivacyPolicy()
                    } label: {
                        Label("Privacy Policy", systemImage: "doc.text.fill")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundColor(ThemeManager.shared.color(for: themeColorName))
                            .background(ThemeManager.shared.color(for: themeColorName).opacity(0.12))
                            .cornerRadius(14)
                    }
                }
                .padding(.bottom, 30)
            }
            .padding()
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: App Version Info
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    private var appBuild: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }

    // MARK: Actions
    private func sendEmail() {
        // Replace with your support email
        let email = "support@ultravision.ai"
        if let url = URL(string: "mailto:\(email)") {
            UIApplication.shared.open(url)
        }
    }

    private func openPrivacyPolicy() {
        // Replace with your privacy policy link
        let link = "https://example.com/privacy-policy"
        if let url = URL(string: link) {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - Feature Row Component
struct FeatureRow: View {
    let icon: String
    let title: String
    let subtitle: String
    @AppStorage("themeColor") private var themeColorName = "Blue"

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .frame(width: 28)
                .foregroundColor(ThemeManager.shared.color(for: themeColorName))

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        AboutScreen()
    }
}
