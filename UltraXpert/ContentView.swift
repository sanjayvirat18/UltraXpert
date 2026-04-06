import SwiftUI

struct ContentView: View {

    @State private var appFlow: AppFlow = .splash

    // ✅ Global settings (Dark mode, notifications, biometric...)
    @StateObject private var appSettings = AppSettings()
    @StateObject private var patientStore = PatientStore()

    @Environment(\.scenePhase) private var scenePhase
    @State private var isLocked: Bool = false
    @State private var showAuthError: String? = nil

    var body: some View {

        Group {
            switch appFlow {

            case .splash:
                SplashScreen {
                    appFlow = .onboarding
                }

            case .onboarding:
                OnboardingScreens {
                    appFlow = .login
                }

            case .login:
                NavigationStack {
                    LoginScreen(
                        onLoginSuccess: {
                            appFlow = .main
                            if appSettings.biometricEnabled {
                                isLocked = false // Already authenticated via login
                            }
                        },
                        onForgotPassword: {
                            appFlow = .resetPassword
                        }
                    )
                }

            case .resetPassword:
                NavigationStack {
                    ResetPasswordScreen(
                        onResetComplete: {
                            appFlow = .login
                        },
                        onBack: {
                            appFlow = .login
                        }
                    )
                }

            case .main:
                RootTabView (onLogout: {
                    appFlow = .login
                })
            }
        }
        .overlay {
            if isLocked && appSettings.biometricEnabled && appFlow == .main {
                AppLockView(error: showAuthError) {
                    authenticate()
                }
                .transition(.opacity)
                .ignoresSafeArea()
            }
        }
        // ✅ Inject settings to ALL screens
        .environmentObject(appSettings)
        .environmentObject(patientStore)

        // ✅ Dark mode works globally (Dashboard + Settings + all pages)
        .preferredColorScheme(appSettings.darkModeEnabled ? .dark : .light)
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .background {
                if appSettings.biometricEnabled && appFlow == .main {
                    isLocked = true
                }
            } else if newPhase == .active {
                if isLocked && appSettings.biometricEnabled && appFlow == .main {
                    authenticate()
                }
            }
        }
        .onAppear {
            if appSettings.biometricEnabled && appFlow == .main {
                isLocked = true
                authenticate()
            }
        }
    }

    private func authenticate() {
        showAuthError = nil
        SecurityManager.shared.authenticateUser { success, errorMsg in
            if success {
                withAnimation {
                    isLocked = false
                }
            } else {
                showAuthError = errorMsg
            }
        }
    }
}

// MARK: - Dedicated App Lock View
struct AppLockView: View {
    @AppStorage("themeColor") private var themeColorName = "Blue"
    var error: String?
    var onUnlockTapped: () -> Void

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
            
            VStack(spacing: 24) {
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 80))
                    .foregroundColor(ThemeManager.shared.color(for: themeColorName))
                    .padding(.bottom, 20)
                
                Text("App Locked")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Unlock to access your secure data")
                    .foregroundColor(.gray)
                
                if let error = error {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.footnote)
                        .padding(.top, 10)
                }
                
                Button(action: onUnlockTapped) {
                    Text("Unlock with Biometrics")
                        .foregroundColor(.white)
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(ThemeManager.shared.color(for: themeColorName))
                        .cornerRadius(16)
                        .padding(.horizontal, 40)
                        .padding(.top, 30)
                }
            }
        }
    }
}
