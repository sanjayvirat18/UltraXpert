import SwiftUI
import UIKit

// MARK: - Help & Support Main Screen
struct HelpAndSupport: View {

    @State private var showReportBugSheet = false

    var body: some View {
        List {

            // MARK: Quick Help
            Section(header: Text("Quick Help").fontWeight(.bold)) {

                NavigationLink(destination: HowToUseScreen()) {
                    Label("How to Use the App", systemImage: "book.fill")
                }

                NavigationLink(destination: FAQScreen()) {
                    Label("FAQs", systemImage: "questionmark.circle.fill")
                }

                NavigationLink(destination: TroubleshootingScreen()) {
                    Label("Troubleshooting", systemImage: "wrench.and.screwdriver.fill")
                }
            }

            // MARK: Contact
            Section(header: Text("Contact").fontWeight(.bold)) {

                Button {
                    contactSupportEmail()
                } label: {
                    Label("Email Support", systemImage: "envelope.fill")
                }

                Button {
                    callSupport()
                } label: {
                    Label("Call Support", systemImage: "phone.fill")
                }
            }

            // MARK: Feedback
            Section(header: Text("Feedback").fontWeight(.bold)) {

                Button {
                    showReportBugSheet = true
                } label: {
                    Label("Report a Bug", systemImage: "exclamationmark.bubble.fill")
                        .foregroundColor(.primary)
                }

                Button {
                    rateApp()
                } label: {
                    Label("Rate This App", systemImage: "star.fill")
                        .foregroundColor(.primary)
                }
            }

            // MARK: App Info
            Section(header: Text("App Info").fontWeight(.bold)) {

                NavigationLink(destination: AboutScreen()) {
                    Label("About UltraVision AI", systemImage: "info.circle.fill")
                }

                HStack {
                    Label("Version", systemImage: "number.circle.fill")
                    Spacer()
                    Text(appVersion)
                        .foregroundColor(.secondary)
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Help & Support")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showReportBugSheet) {
            ReportBugScreen()
        }
    }

    // MARK: - App Version
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    // MARK: - Actions
    private func contactSupportEmail() {
        let email = "support@ultravision.ai" // change this
        let subject = "Support Request - UltraVision AI"
        let body = "Hello Support Team,\n\nI need help with...\n\nDevice: iPhone\nApp Version: \(appVersion)\n\nThanks."

        let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let encodedBody = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""

        if let url = URL(string: "mailto:\(email)?subject=\(encodedSubject)&body=\(encodedBody)") {
            UIApplication.shared.open(url)
        }
    }

    private func callSupport() {
        let phoneNumber = "1800123456" // change this
        if let url = URL(string: "tel://\(phoneNumber)") {
            UIApplication.shared.open(url)
        }
    }

    private func rateApp() {
        // Later you can link AppStore rating URL
        if let url = URL(string: "https://apps.apple.com") {
            UIApplication.shared.open(url)
        }
    }
}


// MARK: - How To Use Screen
struct HowToUseScreen: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                Text("How to Use the App")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("""
1. Login to your account.
2. Upload or capture an ultrasound image.
3. Tap 'Enhance' to improve clarity using AI.
4. Save the enhanced image securely.
5. Use enhanced images for better diagnosis support.
""")
                .font(.body)
                .foregroundColor(.primary)

                Spacer()
            }
            .padding()
        }
        .navigationTitle("How to Use")
        .navigationBarTitleDisplayMode(.inline)
    }
}


// MARK: - FAQ Screen
struct FAQScreen: View {

    let faqs: [(String, String)] = [
        ("What does this app do?",
         "It enhances ultrasound images using AI to improve clarity and reduce noise."),

        ("Is patient data safe?",
         "Yes. The app is designed with privacy protection and secure handling of patient information."),

        ("Does it work offline?",
         "Some features may work offline, but AI enhancement may require internet depending on your setup."),

        ("Who can use this app?",
         "Doctors, healthcare workers, rural clinics, and NGOs can use it for better ultrasound visibility.")
    ]

    var body: some View {
        List {
            Section(header: Text("Frequently Asked Questions").fontWeight(.bold)) {
                ForEach(faqs.indices, id: \.self) { index in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(faqs[index].0)
                            .font(.headline)

                        Text(faqs[index].1)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 6)
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("FAQs")
        .navigationBarTitleDisplayMode(.inline)
    }
}


// MARK: - Troubleshooting Screen
struct TroubleshootingScreen: View {
    var body: some View {
        List {
            Section(header: Text("Common Issues").fontWeight(.bold)) {

                VStack(alignment: .leading, spacing: 6) {
                    Text("Image not uploading?")
                        .font(.headline)
                    Text("Check internet connection and try again. Make sure the image size is supported.")
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 6)

                VStack(alignment: .leading, spacing: 6) {
                    Text("Enhancement taking too long?")
                        .font(.headline)
                    Text("AI enhancement may take time depending on network speed and image resolution.")
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 6)

                VStack(alignment: .leading, spacing: 6) {
                    Text("App crashing?")
                        .font(.headline)
                    Text("Restart the app. If issue continues, report the bug from Help & Support.")
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 6)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Troubleshooting")
        .navigationBarTitleDisplayMode(.inline)
    }
}


// MARK: - Report Bug Screen
struct ReportBugScreen: View {

    @Environment(\.dismiss) var dismiss
    @State private var title = ""
    @State private var description = ""

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Bug Details")) {

                    TextField("Bug Title", text: $title)

                    TextEditor(text: $description)
                        .frame(height: 150)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.2))
                        )
                }

                Section {
                    Button("Submit Report") {
                        // Later connect to backend / email sending
                        dismiss()
                    }
                    .disabled(title.isEmpty || description.isEmpty)
                }
            }
            .navigationTitle("Report a Bug")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}
