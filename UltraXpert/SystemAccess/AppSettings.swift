import SwiftUI

final class AppSettings: ObservableObject {
    @Published var notificationsEnabled: Bool = true
    @Published var biometricEnabled: Bool = false
    @Published var darkModeEnabled: Bool = false
}
