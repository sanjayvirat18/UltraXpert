import SwiftUI
import LocalAuthentication

// MARK: - Security & Privacy Screen
struct SecurityPrivacyScreen: View {

    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appSettings: AppSettings

    @State private var showClearCacheAlert = false
    @State private var showExportAlert = false
    @State private var showLogoutAllAlert = false

    @State private var selectedTimeout: LockTimeout = .oneMinute

    var body: some View {
        List {

            // MARK: Security
            Section(header: Text("Security").fontWeight(.bold)) {

                Toggle(isOn: $appSettings.biometricEnabled) {
                    Label("Biometric Lock", systemImage: "faceid")
                }
                .onChange(of: appSettings.biometricEnabled) { newValue in
                    if newValue {
                        validateBiometricBeforeEnabling()
                    }
                }

                Picker("Auto Lock", selection: $selectedTimeout) {
                    ForEach(LockTimeout.allCases, id: \.self) { timeout in
                        Text(timeout.title).tag(timeout)
                    }
                }

                NavigationLink(destination: ResetPasswordScreen(onResetComplete: {
                    print("Password reset complete")
                })) {
                    Label("Change Password", systemImage: "key.fill")
                }

                Button(role: .destructive) {
                    showLogoutAllAlert = true
                } label: {
                    Label("Logout From All Devices", systemImage: "rectangle.portrait.and.arrow.right")
                }
                .alert("Logout from all devices?", isPresented: $showLogoutAllAlert) {
                    Button("Cancel", role: .cancel) { }
                    Button("Logout", role: .destructive) {
                        print("Logout from all devices tapped")
                    }
                } message: {
                    Text("This will sign out your account from all devices where you are logged in.")
                }
            }

            // MARK: Privacy
            Section(header: Text("Privacy").fontWeight(.bold)) {

                Toggle(isOn: $appSettings.patientDataProtectionEnabled) {
                    Label("Patient Data Protection", systemImage: "shield.lefthalf.filled")
                }

                Toggle(isOn: $appSettings.allowAnalytics) {
                    Label("Allow Analytics", systemImage: "chart.bar.fill")
                }

                Toggle(isOn: $appSettings.allowCrashReports) {
                    Label("Allow Crash Reports", systemImage: "exclamationmark.triangle.fill")
                }
            }

            // MARK: Data Management
            Section(header: Text("Data Management").fontWeight(.bold)) {

                Button {
                    showExportAlert = true
                } label: {
                    Label("Export Data", systemImage: "square.and.arrow.up")
                }
                .alert("Export Data", isPresented: $showExportAlert) {
                    Button("OK") {
                        print("Export requested")
                    }
                } message: {
                    Text("Your reports and app data will be prepared for export.")
                }

                Button(role: .destructive) {
                    showClearCacheAlert = true
                } label: {
                    Label("Clear Cache", systemImage: "trash.fill")
                }
                .alert("Clear cache?", isPresented: $showClearCacheAlert) {
                    Button("Cancel", role: .cancel) { }
                    Button("Clear", role: .destructive) {
                        clearCache()
                    }
                } message: {
                    Text("This removes temporary stored files. It will not delete your reports.")
                }
            }

            // MARK: Policy
            Section(header: Text("Policy").fontWeight(.bold)) {

                NavigationLink(destination: PrivacyPolicyScreen()) {
                    Label("Privacy Policy", systemImage: "doc.text.fill")
                }

                NavigationLink(destination: TermsConditionsScreen()) {
                    Label("Terms & Conditions", systemImage: "doc.plaintext")
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Security & Privacy")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Biometric Validation
    private func validateBiometricBeforeEnabling() {
        let context = LAContext()
        var error: NSError?

        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            appSettings.biometricEnabled = false
            return
        }

        context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                               localizedReason: "Enable biometric lock for extra security.") { success, _ in
            DispatchQueue.main.async {
                if !success {
                    appSettings.biometricEnabled = false
                }
            }
        }
    }

    // MARK: - Clear Cache
    private func clearCache() {
        // Here you can clear temp files if you store enhanced images locally.
        print("Cache cleared successfully")
    }
}


// MARK: - Lock Timeout Enum
enum LockTimeout: CaseIterable {
    case immediate
    case thirtySeconds
    case oneMinute
    case fiveMinutes

    var title: String {
        switch self {
        case .immediate: return "Immediately"
        case .thirtySeconds: return "30 Seconds"
        case .oneMinute: return "1 Minute"
        case .fiveMinutes: return "5 Minutes"
        }
    }
}


// MARK: - Privacy Policy Screen
struct PrivacyPolicyScreen: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                Text("Privacy Policy")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("""
We respect your privacy. This application is designed for healthcare use and patient data protection is a priority.

• Patient information is securely handled.
• No data is shared without permission.
• Images and reports remain protected.

You can view our full, legally compliant policy online at:
""")
                .font(.body)
                .foregroundColor(.primary)

                Link("https://sanjayvirat18.github.io/Privacy_policy/", 
                     destination: URL(string: "https://sanjayvirat18.github.io/Privacy_policy/")!)
                    .font(.subheadline)
                    .foregroundColor(.blue)

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Privacy Policy")
        .navigationBarTitleDisplayMode(.inline)
    }
}


// MARK: - Terms & Conditions Screen
struct TermsConditionsScreen: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                Text("Terms & Conditions")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("""
By using this application you agree to the following:

• This app supports diagnosis but does not replace medical professionals.
• Users are responsible for verifying patient information.
• Misuse of the app is not allowed.

(Replace this text with your official Terms & Conditions.)
""")
                .font(.body)
                .foregroundColor(.primary)

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Terms & Conditions")
        .navigationBarTitleDisplayMode(.inline)
    }
}


// MARK: - Preview
#Preview {
    NavigationStack {
        SecurityPrivacyScreen()
            .environmentObject(AppSettings())
    }
}
