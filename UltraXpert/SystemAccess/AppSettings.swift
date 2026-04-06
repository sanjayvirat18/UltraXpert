import SwiftUI
import Combine

final class AppSettings: ObservableObject {

    @Published var notificationsEnabled: Bool = true
    @Published var biometricEnabled: Bool {
        didSet {
            UserDefaults.standard.set(biometricEnabled, forKey: "biometricEnabled")
        }
    }

    // ✅ Persisted in UserDefaults — survives logout & app restart
    @Published var darkModeEnabled: Bool {
        didSet {
            UserDefaults.standard.set(darkModeEnabled, forKey: "darkModeEnabled")
        }
    }

    @Published var patientDataProtectionEnabled: Bool = true
    @Published var allowAnalytics: Bool = false
    @Published var allowCrashReports: Bool = true

    init() {
        // Load the saved preferences on startup
        self.biometricEnabled = UserDefaults.standard.bool(forKey: "biometricEnabled")
        self.darkModeEnabled = UserDefaults.standard.bool(forKey: "darkModeEnabled")
    }

}
