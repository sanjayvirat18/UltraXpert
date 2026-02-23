import SwiftUI

struct SettingsScreen: View {

    let onLogout: () -> Void

    @State private var notificationsEnabled = true
    @State private var biometricEnabled = false
    @State private var darkModeEnabled = true

    @State private var showLogoutAlert = false
    @State private var showDeleteAlert = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 22) {

                    Text("Settings")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 10)

                    // Preferences
                    sectionTitle("Preferences")

                    settingsCard {
                        toggleRow(icon: "bell", title: "Notifications", isOn: $notificationsEnabled)
                        divider()
                        toggleRow(icon: "faceid", title: "Biometric Login", isOn: $biometricEnabled)
                        divider()
                        toggleRow(icon: "moon.fill", title: "Dark Mode", isOn: $darkModeEnabled)
                    }

                    // Security & Privacy
                    sectionTitle("Security & Privacy")

                    settingsCard {
                        navRow(icon: "lock.shield", title: "Security & Privacy")
                        divider()
                        navRow(icon: "key.fill", title: "Change Password")
                    }

                    // Help & Support
                    sectionTitle("Help & Support")

                    settingsCard {
                        navRow(icon: "questionmark.circle", title: "Help & Support")
                        divider()
                        navRow(icon: "info.circle", title: "About")
                    }

                    // Danger Zone (Logout / Delete)
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

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 18)
                .padding(.bottom, 30)
            }
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
                // TODO: delete account logic
            }
        } message: {
            Text("This action cannot be undone.")
        }
    }

    // MARK: - Components

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.headline)
            .foregroundColor(.gray)
            .padding(.top, 8)
    }

    private func settingsCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(spacing: 0) {
            content()
        }
        .background(Color.white.opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: 22))
    }

    private func divider() -> some View {
        Rectangle()
            .fill(Color.white.opacity(0.12))
            .frame(height: 1)
            .padding(.leading, 60)
    }

    private func toggleRow(icon: String, title: String, isOn: Binding<Bool>) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 34)

            Text(title)
                .foregroundColor(.white)
                .font(.system(size: 18, weight: .medium))

            Spacer()

            Toggle("", isOn: isOn)
                .labelsHidden()
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 18)
    }

    private func navRow(icon: String, title: String) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 34)

            Text(title)
                .foregroundColor(.white)
                .font(.system(size: 18, weight: .medium))

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 18)
    }

    private func dangerRow(icon: String, title: String, tint: Color) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .foregroundColor(tint)
                .frame(width: 34)

            Text(title)
                .foregroundColor(tint)
                .font(.system(size: 18, weight: .semibold))

            Spacer()
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 18)
    }
}

#Preview {
    SettingsScreen(onLogout: {})
}
