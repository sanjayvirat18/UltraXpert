import SwiftUI

// MARK: - Dashboard View
struct DashboardView: View {

    @EnvironmentObject var appSettings: AppSettings
    @EnvironmentObject var appointmentStore: AppointmentStore
    @EnvironmentObject var reportStore: ReportStore
    @AppStorage("themeColor") private var themeColorName = "Blue"
    var onLogout: (() -> Void)? = nil

    @State private var navigationPath = NavigationPath()
    @State private var doctorName: String = "Doctor"
    @State private var profileImageUrl: String? = nil
    @AppStorage("unreadNotificationCount") private var unreadNotificationCount: Int = 0

    // Compute dynamic greeting based on time of day
    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        if hour < 12 { return "Good Morning" }
        if hour < 18 { return "Good Afternoon" }
        return "Good Evening"
    }
    
    // Dynamic Date
    private var currentDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: Date())
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {

                        headerSection
                        
                        systemStatusCard
                        
                        quickActionsGrid
                        
                        recentActivitySection
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .padding(.bottom, 30)
                }
            }
            .preferredColorScheme(appSettings.darkModeEnabled ? .dark : .light)
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("DismissScanSheet"))) { _ in
                DispatchQueue.main.async {
                    navigationPath = NavigationPath()
                }
            }
            .onAppear {
                fetchDoctorName()
                fetchUnreadNotifications()
            }
        }
    }
    
    // MARK: - API Call
    private func fetchDoctorName() {
        Task {
            do {
                let profile = try await APIClient.shared.request(endpoint: "/api/v1/users/me", method: "GET", responseType: UserProfileResponse.self)
                DispatchQueue.main.async {
                    if let fullName = profile.full_name, !fullName.isEmpty {
                        self.doctorName = fullName
                    }
                    self.profileImageUrl = profile.profile_image_url
                }
            } catch {
                print("Failed to fetch profile for dashboard: \(error.localizedDescription)")
            }
        }
    }

    private func fetchUnreadNotifications() {
        Task {
            do {
                let responses = try await NotificationService().getNotifications()
                let unread = responses.filter { !$0.is_read }.count
                DispatchQueue.main.async {
                    self.unreadNotificationCount = unread
                }
            } catch {
                print("Failed to sync notifications: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - UI Sections
extension DashboardView {

    // MARK: Header
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(currentDate.uppercased())
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
                    .tracking(1)

                Text("\(greeting), \(doctorName.hasPrefix("Dr.") ? "" : "Dr. ")\(doctorName)")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            
            Spacer()
            
            // Messages shortcut
            NavigationLink(destination: NotificationScreen()) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "bell.circle.fill")
                        .font(.system(size:35))
                        .foregroundColor(ThemeManager.shared.color(for: themeColorName))
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                        
                    if unreadNotificationCount > 0 {
                        Text("\(unreadNotificationCount)")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                            .padding(5)
                            .background(Color.red)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 1.5))
                            .offset(x: 2, y: -2)
                    }
                }
            }

            // Profile / Settings shortcut
            Menu {
                NavigationLink(destination: ProfileScreen()) {
                    Label("Profile", systemImage: "person.crop.circle")
                }
                
                Button(role: .destructive, action: { onLogout?() }) {
                    Label("Logout", systemImage: "rectangle.portrait.and.arrow.right")
                }
            } label: {
                if let imageUrlPath = profileImageUrl, let imageUrl = URL(string: AppConfig.backendURL + imageUrlPath) {
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 35, height: 35)
                            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                        
                        AsyncImage(url: imageUrl) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 31, height: 31)
                        .clipShape(Circle())
                    }
                } else {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 35))
                        .foregroundColor(ThemeManager.shared.color(for: themeColorName))
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                }
            }
        }
        .padding(.top, 10)
    }
    
    // MARK: System Status Card (Futuristic)
    private var systemStatusCard: some View {
        NavigationLink(destination: ScanUploadScreen()) {
            HStack(spacing: 20) {
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 8, height: 8)
                            .padding(4)
                            .background(Color.green.opacity(0.2))
                            .clipShape(Circle())
                        
                        Text("SYSTEM ONLINE")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.white.opacity(0.8))
                            .tracking(1)
                    }
                    
                    Text("UltraXpert AI Ready")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Scanner connected. AI Enhancement engine is active and ready for processing.")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                Image(systemName: "waveform.path.ecg")
                    .font(.system(size: 44))
                    .foregroundColor(.white.opacity(0.9))
                    .overlay(
                        Image(systemName: "sparkles")
                            .font(.system(size: 18))
                            .foregroundColor(.yellow)
                            .offset(x: 20, y: -20)
                    )
            }
            .padding(20)
            .background(
                LinearGradient(colors: [ThemeManager.shared.color(for: themeColorName), ThemeManager.shared.color(for: themeColorName).opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .cornerRadius(24)
            .shadow(color: ThemeManager.shared.color(for: themeColorName).opacity(0.3), radius: 10, x: 0, y: 5)
        }
    }

    // MARK: Quick Actions Grid
    private var quickActionsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {

            NavigationLink(destination: AppointmentsView()) {
                UXQuickActionCard(
                    title: "Appointments",
                    icon: "calendar.badge.clock",
                    color: ThemeManager.shared.color(for: themeColorName),
                    subtitle: "Manage Schedule"
                )
            }
            .buttonStyle(.plain)

            NavigationLink(destination: AnalyticsDetailView()) {
                UXQuickActionCard(
                    title: "Analytics",
                    icon: "chart.bar.xaxis",
                    color: .orange,
                    subtitle: "AI Insights"
                )
            }
            .buttonStyle(.plain)
        }
    }
    
    // MARK: Recent Activity
    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: 14) {
            
            HStack {
                Text("Recent Activity")
                    .font(.headline)
                    .fontWeight(.bold)
                Spacer()
                
                NavigationLink(destination: ReportView()) {
                    Text("View All")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(ThemeManager.shared.color(for: themeColorName))
                }
            }
            
            if reportStore.reports.isEmpty {
                Text("No recent activity.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
            } else {
                ForEach(reportStore.reports.prefix(3)) { report in
                    NavigationLink(destination: PatientReportDetailView(report: report)) {
                        UXActivityRow(
                            title: report.patientName,
                            subtitle: "Report Generated",
                            scanType: report.scanType,
                            time: report.date,
                            icon: "doc.text.fill",
                            color: ThemeManager.shared.color(for: themeColorName)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            

        }
    }
}

// MARK: - Components

struct UXQuickActionCard: View {
    let title: String
    let icon: String
    let color: Color
    var subtitle: String = ""

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // ── Top gradient accent bar ──────────────────────────
            LinearGradient(
                colors: [color, color.opacity(0.3)],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(height: 3)
            .clipShape(
                UnevenRoundedRectangle(
                    topLeadingRadius: 20,
                    bottomLeadingRadius: 0,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: 20
                )
            )

            VStack(alignment: .leading, spacing: 14) {

                // ── Gradient icon circle ─────────────────────────
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    color.opacity(colorScheme == .dark ? 0.30 : 0.15),
                                    color.opacity(colorScheme == .dark ? 0.12 : 0.06)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 54, height: 54)

                    Image(systemName: icon)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(color)
                }

                // ── Label block ──────────────────────────────────
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.primary)
                        .lineLimit(1)

                    if !subtitle.isEmpty {
                        Text(subtitle)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(color.opacity(0.8))
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(18)
        }
        .frame(maxWidth: .infinity, minHeight: 148)
        .background(
            colorScheme == .dark
                ? Color(white: 0.12)
                : Color(.systemBackground)
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    colorScheme == .dark
                        ? Color.white.opacity(0.08)
                        : Color.black.opacity(0.06),
                    lineWidth: 0.8
                )
        )
        .shadow(
            color: color.opacity(colorScheme == .dark ? 0.14 : 0.10),
            radius: 10, x: 0, y: 5
        )
    }
}



struct UXActivityRow: View {
    let title: String
    let subtitle: String
    let scanType: String
    let time: String
    let icon: String
    let color: Color

    @Environment(\.colorScheme) private var colorScheme

    // Pick an icon per modality keyword
    private var modalityIcon: String {
        let lower = scanType.lowercased()
        if lower.contains("ct")         { return "cpu.fill" }
        if lower.contains("mri")        { return "brain.head.profile" }
        if lower.contains("x-ray")      { return "rays" }
        if lower.contains("ultrasound") { return "waveform.path.ecg" }
        return "doc.text.fill"
    }

    var body: some View {
        HStack(spacing: 0) {

            // ── Left accent bar ──────────────────────────────────────
            LinearGradient(
                colors: [color, color.opacity(0.4)],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(width: 4)
            .clipShape(
                UnevenRoundedRectangle(
                    topLeadingRadius: 16,
                    bottomLeadingRadius: 16,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: 0
                )
            )

            HStack(spacing: 14) {

                // ── Icon circle ─────────────────────────────────────
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [color.opacity(colorScheme == .dark ? 0.30 : 0.15),
                                         color.opacity(colorScheme == .dark ? 0.12 : 0.06)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 48, height: 48)

                    Image(systemName: modalityIcon)
                        .font(.system(size: 19, weight: .semibold))
                        .foregroundStyle(color)
                }

                // ── Text block ──────────────────────────────────────
                VStack(alignment: .leading, spacing: 5) {

                    // Patient name
                    Text(title)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.primary)
                        .lineLimit(1)

                    // Scan type pill
                    Text(scanType)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(color)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(color.opacity(colorScheme == .dark ? 0.20 : 0.10))
                        .clipShape(Capsule())

                    // Subtitle
                    Text(subtitle)
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Spacer(minLength: 0)

                // ── Time chip ───────────────────────────────────────
                VStack(spacing: 2) {
                    Image(systemName: "clock")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(color.opacity(0.8))

                    Text(time)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, 9)
                .padding(.vertical, 7)
                .background(
                    colorScheme == .dark
                        ? Color.white.opacity(0.06)
                        : Color.black.opacity(0.04)
                )
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(color.opacity(0.20), lineWidth: 0.8)
                )
            }
            .padding(.vertical, 14)
            .padding(.leading, 14)
            .padding(.trailing, 12)
        }
        .background(
            colorScheme == .dark
                ? Color(white: 0.12)
                : Color(.systemBackground)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    colorScheme == .dark
                        ? Color.white.opacity(0.08)
                        : Color.black.opacity(0.06),
                    lineWidth: 0.8
                )
        )
        .shadow(
            color: color.opacity(colorScheme == .dark ? 0.12 : 0.08),
            radius: 8, x: 0, y: 4
        )
    }
}

// MARK: - Preview
#Preview {
    DashboardView()
        .environmentObject(AppSettings())
        .environmentObject(AppointmentStore())
        .environmentObject(ReportStore())
}
