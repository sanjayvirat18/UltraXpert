import SwiftUI

struct RootTabView: View {

    let onLogout: () -> Void
    @EnvironmentObject var appSettings: AppSettings
    @EnvironmentObject var patientStore: PatientStore
    @AppStorage("themeColor") private var themeColorName = "Blue"
    @State private var selectedTab: Tab = .home

    enum Tab {
        case home, reports, scan, settings
    }

    var body: some View {
        TabView(selection: $selectedTab) {

            DashboardView(onLogout: onLogout)
                .tag(Tab.home)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }

            ReportView()
                .tag(Tab.reports)
                .tabItem {
                    Label("Patients", systemImage: "list.clipboard.fill")
                }

            NavigationStack {
                ScanUploadScreen()
            }
            .tag(Tab.scan)
            .tabItem {
                Label("Scan", systemImage: "camera.viewfinder")
            }


            NavigationStack {
                SettingsScreen(onLogout: onLogout)
            }
            .tag(Tab.settings)
            .tabItem {
                Label("Settings", systemImage: "gear.circle.fill")
            }
        }
        .tint(ThemeManager.shared.color(for: themeColorName))
        .preferredColorScheme(appSettings.darkModeEnabled ? .dark : .light)
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("DismissScanSheet"))) { _ in
            DispatchQueue.main.async {
                selectedTab = .home
            }
        }
    }
}

#Preview {
    RootTabView(onLogout: {})
        .environmentObject(AppSettings())
        .environmentObject(PatientStore())
}
