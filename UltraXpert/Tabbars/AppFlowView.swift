import SwiftUI

struct AppFlowView: View {

    @EnvironmentObject var flowManager: AppFlowManager

    var body: some View {
        switch flowManager.flow {

        case .splash:
            SplashScreen {
                flowManager.goToOnboarding()
            }

        case .onboarding:
            OnboardingScreens {
                flowManager.goToLogin()
            }

        case .login:
            LoginScreen(
                onLoginSuccess: {
                    flowManager.goToMain()
                },
                onForgotPassword: {
                    flowManager.goToResetPassword()
                }
            )

        case .resetPassword:
            ResetPasswordScreen {
                flowManager.goToLogin()
            }

        case .main:
            RootTabView(onLogout: {
                flowManager.goToLogin()
            })
        }
    }
}
