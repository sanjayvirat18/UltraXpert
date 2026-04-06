import SwiftUI

struct SettingsScreen: View {

    let onLogout: () -> Void

    // ✅ Global app settings
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appSettings: AppSettings
    @AppStorage("themeColor") private var themeColorName = "Blue"

    @State private var notificationsEnabled = true
    @State private var biometricEnabled = false

    @State private var showLogoutAlert = false
    @State private var showDeleteAlert = false

    var body: some View {
        ZStack {

            Color(.systemBackground)
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {

                    // Header removed for navigationTitle usage
                    Color.clear.frame(height: 10)

                    // Preferences
                    sectionTitle("Preferences")

                    settingsCard {
                        toggleRow(icon: "bell", title: "Notifications", isOn: $notificationsEnabled)
                        divider()
                        toggleRow(icon: "faceid", title: "Biometric Login", isOn: $biometricEnabled)
                        divider()
                        toggleRow(icon: "moon.fill", title: "Dark Mode", isOn: $appSettings.darkModeEnabled)
                        divider()
                        NavigationLink {
                            ThemeSettingsView()
                        } label: {
                            navRow(icon: "paintpalette.fill", title: "Appearance")
                        }
                    }


                    // Clinic Management
                    sectionTitle("Clinic Management")

                    settingsCard {
                        NavigationLink {
                            ClinicSettingsView()
                        } label: {
                            navRow(icon: "cross.case.fill", title: "Clinic Details")
                        }

                        divider()

                        NavigationLink {
                             StorageManagementView()
                        } label: {
                             navRow(icon: "externaldrive.fill", title: "Storage")
                        }
                    }

                    // Security & Privacy
                    sectionTitle("Security & Privacy")

                    settingsCard {
                        NavigationLink {
                            SecurityPrivacyScreen()
                                .environmentObject(appSettings)
                        } label: {
                            navRow(icon: "lock.shield", title: "Security & Privacy")
                        }

                        divider()

                        NavigationLink {
                            ResetPasswordScreen(onResetComplete: {
                                print("Password reset complete")
                            })
                        } label: {
                            navRow(icon: "key.fill", title: "Change Password")
                        }
                    }

                    // Help & Support
                    sectionTitle("Help & Support")

                    settingsCard {
                        // ✅ FIXED
                        NavigationLink {
                            HelpAndSupport()
                        } label: {
                            navRow(icon: "questionmark.circle", title: "Help & Support")
                        }

                        divider()
                        
                        NavigationLink {
                            FeedbackFormView()
                        } label: {
                           navRow(icon: "envelope.fill", title: "Send Feedback")
                        }

                        divider()

                        NavigationLink {
                            AboutScreen()
                        } label: {
                            navRow(icon: "info.circle", title: "About")
                        }
                    }
                    
                    // Legal
                    sectionTitle("Legal")
                    
                    settingsCard {
                        NavigationLink {
                            TermsOfServiceView()
                        } label: {
                           navRow(icon: "doc.text", title: "Terms of Service")
                        }
                        
                        divider()
                        
                        NavigationLink {
                            DetailedPrivacyPolicyView()
                        } label: {
                           navRow(icon: "hand.raised.fill", title: "Privacy Policy")
                        }
                    }

                    // Account
                    sectionTitle("Account")

                    settingsCard {
                        Button {
                            showLogoutAlert = true
                        } label: {
                            dangerRow(icon: "rectangle.portrait.and.arrow.right", title: "Logout", tint: .red)
                        }

                        divider()

                        Button {
                            showDeleteAlert = true
                        } label: {
                            dangerRow(icon: "trash", title: "Delete Account", tint: .red)
                        }
                    }
                }
                .padding(.horizontal, 18)
                .padding(.bottom, 20)
            }
            .navigationTitle("Settings")
        }
        .alert("Logout", isPresented: $showLogoutAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Logout", role: .destructive) {
                onLogout()
            }
        } message: {
            Text("Are you sure you want to logout?")
        }
        .alert("Delete Account", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                Task {
                    do {
                        _ = try await APIClient.shared.request(
                            endpoint: "/api/v1/users/me",
                            method: "DELETE",
                            responseType: [String: String].self
                        )
                        DispatchQueue.main.async {
                            onLogout()
                        }
                    } catch {
                        print("Failed to delete account: \(error.localizedDescription)")
                    }
                }
            }
        } message: {
            Text("This action cannot be undone.")
        }
    }

    // MARK: - Components

    private func sectionTitle(_ text: String) -> some View {
        HStack(spacing: 8) {
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [ThemeManager.shared.color(for: themeColorName), ThemeManager.shared.color(for: themeColorName).opacity(0.4)],
                        startPoint: .top, endPoint: .bottom
                    )
                )
                .frame(width: 3, height: 16)
                .clipShape(Capsule())

            Text(text)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .tracking(0.6)
        }
        .padding(.top, 10)
    }

    private func settingsCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(spacing: 0) {
            content()
        }
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    Color.primary.opacity(0.06),
                    lineWidth: 0.8
                )
        )
        .shadow(
            color: ThemeManager.shared.color(for: themeColorName).opacity(0.07),
            radius: 8, x: 0, y: 4
        )
    }

    private func divider() -> some View {
        Rectangle()
            .fill(Color.primary.opacity(0.07))
            .frame(height: 0.8)
            .padding(.leading, 68)
    }

    private func toggleRow(icon: String, title: String, isOn: Binding<Bool>) -> some View {
        HStack(spacing: 14) {

            // Icon circle
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                ThemeManager.shared.color(for: themeColorName).opacity(0.18),
                                ThemeManager.shared.color(for: themeColorName).opacity(0.07)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 36, height: 36)

                Image(systemName: icon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(ThemeManager.shared.color(for: themeColorName))
            }

            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(ThemeManager.shared.color(for: themeColorName))

            Spacer()

            Toggle("", isOn: isOn)
                .labelsHidden()
                .tint(ThemeManager.shared.color(for: themeColorName))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    private func navRow(icon: String, title: String) -> some View {
        HStack(spacing: 14) {

            // Icon circle
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                ThemeManager.shared.color(for: themeColorName).opacity(0.18),
                                ThemeManager.shared.color(for: themeColorName).opacity(0.07)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 36, height: 36)

                Image(systemName: icon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(ThemeManager.shared.color(for: themeColorName))
            }

            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(ThemeManager.shared.color(for: themeColorName))

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(ThemeManager.shared.color(for: themeColorName).opacity(0.5))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    private func dangerRow(icon: String, title: String, tint: Color) -> some View {
        HStack(spacing: 14) {

            // Red tinted icon circle
            ZStack {
                Circle()
                    .fill(tint.opacity(0.12))
                    .frame(width: 36, height: 36)

                Image(systemName: icon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(tint)
            }

            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(tint)

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

#Preview {
    NavigationStack {
        SettingsScreen(onLogout: {})
            .environmentObject(AppSettings())
    }
}
