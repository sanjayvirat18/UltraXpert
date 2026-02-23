import SwiftUI
import Combine

final class AppFlowManager: ObservableObject {

    @Published var flow: AppFlow = .splash

    func goToOnboarding() {
        flow = .onboarding
    }

    func goToLogin() {
        flow = .login
    }

    func goToResetPassword() {
        flow = .resetPassword
    }

    func goToMain() {
        flow = .main
    }
}
