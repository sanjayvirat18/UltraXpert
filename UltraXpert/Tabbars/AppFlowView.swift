import SwiftUI

struct AppFlowView: View {

    @EnvironmentObject var flowManager: AppFlowManager
    @EnvironmentObject var patientStore: PatientStore
    @EnvironmentObject var appointmentStore: AppointmentStore
    @EnvironmentObject var reportStore: ReportStore
    @EnvironmentObject var analyticsStore: AnalyticsStore

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
                    refreshAllStores()
                    flowManager.goToMain()
                },
                onForgotPassword: {
                    flowManager.goToResetPassword()
                }
            )

        case .resetPassword:
            ResetPasswordScreen(
                onResetComplete: {
                    flowManager.goToLogin()
                },
                onBack: {
                    flowManager.goToLogin()
                }
            )

        case .main:
            RootTabView(onLogout: {
                clearAllStores()
                flowManager.goToLogin()
            })
        }
    }
    
    private func refreshAllStores() {
        Task {
            await patientStore.fetchPatients()
            await appointmentStore.fetchAppointments()
            await reportStore.fetchReports()
            await analyticsStore.fetchHistory()
        }
    }
    
    private func clearAllStores() {
        patientStore.clear()
        appointmentStore.clear()
        reportStore.clear()
        analyticsStore.clear()
    }
}
