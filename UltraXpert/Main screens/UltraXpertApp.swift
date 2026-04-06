import SwiftUI
import SwiftData

@main
struct UltraXpertApp: App {

    @StateObject private var appSettings = AppSettings()
    @StateObject private var flowManager = AppFlowManager()
    @StateObject private var patientStore = PatientStore()
    @StateObject private var appointmentStore = AppointmentStore()
    @StateObject private var reportStore = ReportStore()
    @StateObject private var analyticsStore = AnalyticsStore()
    
    @AppStorage("themeColor") private var themeColorName = "Blue"

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                AppFlowView()
            }
            .environmentObject(appSettings)
            .environmentObject(flowManager)
            .environmentObject(patientStore)
            .environmentObject(appointmentStore)
            .environmentObject(reportStore)
            .environmentObject(analyticsStore)
            .tint(ThemeManager.shared.color(for: themeColorName))
            .accentColor(ThemeManager.shared.color(for: themeColorName))
            // ✅ Apply dark mode globally — persists even after logout
            .preferredColorScheme(appSettings.darkModeEnabled ? .dark : .light)
        }
        // ✅ SwiftData container
//        .modelContainer(for:[
//            ScanRecord.self,
           // ScanReport.self
//        ])
    }
}
