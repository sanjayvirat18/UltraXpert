import SwiftUI

struct DashboardView: View {

    @EnvironmentObject var appSettings: AppSettings

    var onLogout: (() -> Void)? = nil

    var body: some View {
        ZStack {

            // Background
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 22) {

                    headerSection
                    actionButtons
                    statsCards
                    recentPatientsSection
                }
                .padding(.horizontal, 18)
                .padding(.top, 18)
                .padding(.bottom, 20) // ✅ just natural spacing, no white gap
            }

            // Floating + button
            floatingAddButton
        }
        .preferredColorScheme(appSettings.darkModeEnabled ? .dark : .light)
    }
}

#Preview {
    NavigationStack {
        DashboardView()
            .environmentObject(AppSettings())
    }
}

// MARK: - UI Sections
extension DashboardView {

    private var headerSection: some View {
        HStack(alignment: .center, spacing: 12) {

            Circle()
                .fill(Color(.secondarySystemBackground))
                .frame(width: 46, height: 46)
                .overlay(
                    Image(systemName: "person.fill")
                        .foregroundColor(.secondary)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text("Good Morning,")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text("Dr. Smith")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }

            Spacer()

            Image(systemName: "bubble.left")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.primary)
                .frame(width: 40, height: 40)
                .background(Color(.secondarySystemBackground))
                .clipShape(Circle())

            ZStack(alignment: .topTrailing) {
                Image(systemName: "bell")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.primary)
                    .frame(width: 40, height: 40)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(Circle())

                Circle()
                    .fill(Color.red)
                    .frame(width: 8, height: 8)
                    .offset(x: -6, y: 6)
            }
        }
        .padding(.top, 8)
    }

    private var actionButtons: some View {
        HStack(spacing: 14) {

            UXDashboardActionButton(
                title: "Appointments",
                icon: "calendar",
                tint: .blue,
                bg: Color.blue.opacity(appSettings.darkModeEnabled ? 0.25 : 0.12)
            )

            UXDashboardActionButton(
                title: "All Scans",
                icon: "photo.on.rectangle",
                tint: .green,
                bg: Color.green.opacity(appSettings.darkModeEnabled ? 0.25 : 0.12)
            )
        }
    }

    private var statsCards: some View {
        HStack(spacing: 60) {

            UXStatCard(
                icon: "photo",
                iconBg: Color.blue.opacity(appSettings.darkModeEnabled ? 0.25 : 0.15),
                value: "156",
                title: "Total Scans"
            )

            UXStatCard(
                icon: "waveform.path.ecg",
                iconBg: Color.green.opacity(appSettings.darkModeEnabled ? 0.25 : 0.15),
                value: "142",
                title: "Enhanced"
            )

            UXStatCard(
                icon: "doc.text",
                iconBg: Color.orange.opacity(appSettings.darkModeEnabled ? 0.25 : 0.15),
                value: "10",
                title: "Pending"
            )
        }
    }

    private var recentPatientsSection: some View {
        VStack(alignment: .leading, spacing: 14) {

            HStack {
                Text("Recent Patients")
                    .font(.headline)
                    .fontWeight(.semibold)

                Spacer()

                Button(action: {}) {
                    Text("See All")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                }
            }
            .padding(.top, 6)

            VStack(spacing: 14) {

                UXPatientRow(
                    initial: "S",
                    name: "Sarah Johnson",
                    id: "P-001",
                    time: "Today, 09:41 AM",
                    status: "Completed",
                    statusTint: .green
                )

                UXPatientRow(
                    initial: "M",
                    name: "Michael Chen",
                    id: "P-002",
                    time: "Yesterday, 04:30 PM",
                    status: "Pending",
                    statusTint: .orange
                )

                UXPatientRow(
                    initial: "E",
                    name: "Emma Wilson",
                    id: "P-003",
                    time: "Oct 24, 11:20 AM",
                    status: "Completed",
                    statusTint: .green
                )

                UXPatientRow(
                    initial: "J",
                    name: "James Rod",
                    id: "P-004",
                    time: "Oct 23, 09:15 AM",
                    status: "Processing",
                    statusTint: .blue
                )
            }
        }
        .padding(.top, 10)
    }

    private var floatingAddButton: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: {}) {
                    Image(systemName: "plus")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 62, height: 62)
                        .background(Color.blue)
                        .clipShape(Circle())
                        .shadow(radius: 10)
                }
                .padding(.trailing, 22)
                .padding(.bottom, 20) // ✅ sits just above tab bar
            }
        }
    }
}

// MARK: - Components

struct UXDashboardActionButton: View {
    let title: String
    let icon: String
    let tint: Color
    let bg: Color

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundColor(tint)

            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(tint)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(bg)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct UXStatCard: View {
    let icon: String
    let iconBg: Color
    let value: String
    let title: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            Circle()
                .fill(iconBg)
                .frame(width: 42, height: 42)
                .overlay(
                    Image(systemName: icon)
                        .foregroundColor(.primary)
                        .font(.system(size: 16, weight: .semibold))
                )

            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)

            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 120, alignment: .topLeading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

struct UXPatientRow: View {
    let initial: String
    let name: String
    let id: String
    let time: String
    let status: String
    let statusTint: Color

    var body: some View {
        HStack(spacing: 14) {

            Circle()
                .fill(Color.blue.opacity(0.18))
                .frame(width: 46, height: 46)
                .overlay(
                    Text(initial)
                        .font(.headline)
                        .foregroundColor(.blue)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)

                HStack(spacing: 6) {
                    Text(id)
                    Text("•")
                    Text(time)
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }

            Spacer()

            Text(status)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(statusTint)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(statusTint.opacity(0.18))
                .clipShape(Capsule())
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 14)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}
