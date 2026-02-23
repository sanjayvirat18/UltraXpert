import SwiftUI

// MARK: - MODEL
struct Appointment: Identifiable {
    let id = UUID()
    let patientName: String
    let patientID: String
    let date: String
    let time: String
    let type: String
    let status: String
    let statusColor: Color
}

// MARK: - DASHBOARD (UPDATED NAVIGATION)
struct DashboardView: View {

    @EnvironmentObject var appSettings: AppSettings
    var onLogout: (() -> Void)? = nil

    var body: some View {
        NavigationStack {
            ZStack {

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
                    .padding(.top, 12)
                    .padding(.bottom, 28)
                }

                floatingAddButton
            }
            .preferredColorScheme(appSettings.darkModeEnabled ? .dark : .light)
        }
    }
}

// MARK: - DASHBOARD UI
extension DashboardView {

    private var headerSection: some View {
        HStack(spacing: 14) {

            NavigationLink {
                ProfileScreen()
            } label: {
                HStack(spacing: 12) {
                    Circle()
                        .fill(Color.blue.opacity(0.18))
                        .frame(width: 46, height: 46)
                        .overlay(
                            Image(systemName: "person.fill")
                                .foregroundColor(.blue)
                        )

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Welcome Back")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text("Dr. Smith")
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                }
            }
            .buttonStyle(.plain)

            Spacer()

            NavigationLink {
                NotificationScreen()
            } label: {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "bell.fill")
                        .foregroundColor(.orange)
                        .frame(width: 42, height: 42)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 14))

                    Circle()
                        .fill(Color.red)
                        .frame(width: 8, height: 8)
                        .offset(x: -4, y: 4)
                }
            }
        }
    }

    // ✅ UPDATED — Appointments Navigation
    private var actionButtons: some View {
        HStack(spacing: 14) {

            NavigationLink {
                AppointmentsView()
            } label: {
                UXDashboardActionButton(
                    title: "Appointments",
                    icon: "calendar",
                    tint: .blue,
                    bg: Color.blue.opacity(appSettings.darkModeEnabled ? 0.22 : 0.14)
                )
            }
            .buttonStyle(.plain)

            UXDashboardActionButton(
                title: "All Scans",
                icon: "photo.on.rectangle",
                tint: .green,
                bg: Color.green.opacity(appSettings.darkModeEnabled ? 0.22 : 0.14)
            )
        }
    }

    private var statsCards: some View {
        HStack(spacing: 14) {
            UXMetricCard(icon: "photo", tint: .blue, value: "156", title: "Total Scans")
            UXMetricCard(icon: "waveform.path.ecg", tint: .green, value: "142", title: "Enhanced")
            UXMetricCard(icon: "doc.text", tint: .orange, value: "10", title: "Pending")
        }
    }

    private var recentPatientsSection: some View {
        VStack(alignment: .leading, spacing: 14) {

            Text("Today Patients")
                .font(.headline)
                .fontWeight(.semibold)
                .padding(.top, 6)

            VStack(spacing: 14) {
                UXPatientRow(initial: "S", name: "Sarah Johnson", id: "P-001", time: "Today, 09:41 AM", status: "Completed", statusTint: .green)
                UXPatientRow(initial: "M", name: "Michael Chen", id: "P-002", time: "Today, 04:30 PM", status: "Pending", statusTint: .orange)
                UXPatientRow(initial: "E", name: "Emma Wilson", id: "P-003", time: "Today, 11:20 AM", status: "Completed", statusTint: .green)
                UXPatientRow(initial: "J", name: "James Rod", id: "P-004", time: "Today 23, 09:15 AM", status: "Processing", statusTint: .blue)
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
                .padding(.bottom, 24)
            }
        }
    }
}

// MARK: - APPOINTMENTS LIST SCREEN
struct AppointmentsView: View {

    @Environment(\.dismiss) private var dismiss

    private let appointments: [Appointment] = [
        Appointment(patientName: "Sarah Johnson", patientID: "P-001", date: "Today", time: "09:40 AM", type: "Ultrasound Scan", status: "Completed", statusColor: .green),
        Appointment(patientName: "Michael Chen", patientID: "P-002", date: "Today", time: "11:10 AM", type: "MRI Scan", status: "Pending", statusColor: .orange),
        Appointment(patientName: "Emma Wilson", patientID: "P-003", date: "Tomorrow", time: "01:30 PM", type: "CT Scan", status: "Processing", statusColor: .blue),
        Appointment(patientName: "James Rod", patientID: "P-004", date: "Tomorrow", time: "03:00 PM", type: "X-Ray", status: "Scheduled", statusColor: .purple)
    ]

    var body: some View {
        ZStack {

            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    ForEach(appointments) { appointment in
                        NavigationLink {
                            AppointmentDetailView(appointment: appointment)
                        } label: {
                            AppointmentCard(appointment: appointment)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 18)
                .padding(.top, 12)
                .padding(.bottom, 24)
            }
        }
        .navigationTitle("Appointments")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                }
            }
        }
    }
}

// MARK: - APPOINTMENT CARD
struct AppointmentCard: View {

    let appointment: Appointment

    var body: some View {
        HStack(spacing: 14) {

            Circle()
                .fill(Color.blue.opacity(0.15))
                .frame(width: 48, height: 48)
                .overlay(
                    Text(String(appointment.patientName.prefix(1)))
                        .font(.headline)
                        .foregroundColor(.blue)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(appointment.patientName)
                    .font(.headline)

                Text("\(appointment.type) • \(appointment.time)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text("ID: \(appointment.patientID)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 6) {
                Text(appointment.status)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(appointment.statusColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(appointment.statusColor.opacity(0.12))
                    .clipShape(Capsule())

                Text(appointment.date)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

// MARK: - APPOINTMENT DETAIL SCREEN
struct AppointmentDetailView: View {

    let appointment: Appointment
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {

            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {

                    patientHeader
                    infoSection
                    actionButtons
                }
                .padding(.horizontal, 18)
                .padding(.top, 12)
                .padding(.bottom, 28)
            }
        }
        .navigationTitle("Appointment")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                }
            }
        }
    }

    private var patientHeader: some View {
        VStack(spacing: 12) {

            Circle()
                .fill(Color.blue.opacity(0.18))
                .frame(width: 70, height: 70)
                .overlay(
                    Text(String(appointment.patientName.prefix(1)))
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                )

            Text(appointment.patientName)
                .font(.title2)
                .fontWeight(.semibold)

            Text("Patient ID: \(appointment.patientID)")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Text(appointment.status)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(appointment.statusColor)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(appointment.statusColor.opacity(0.15))
                .clipShape(Capsule())
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 22))
    }

    private var infoSection: some View {
        VStack(spacing: 14) {

            AppointmentInfoRow(icon: "calendar", title: "Date", value: appointment.date)
            AppointmentInfoRow(icon: "clock", title: "Time", value: appointment.time)
            AppointmentInfoRow(icon: "stethoscope", title: "Scan Type", value: appointment.type)
            AppointmentInfoRow(icon: "doc.text", title: "Status", value: appointment.status)
        }
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 22))
    }

    private var actionButtons: some View {
        VStack(spacing: 14) {

            Button(action: {}) {
                Label("Start Scan", systemImage: "camera.viewfinder")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }

            Button(action: {}) {
                Label("View Reports", systemImage: "doc.text.magnifyingglass")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
        }
    }
}

// MARK: - INFO ROW
struct AppointmentInfoRow: View {

    let icon: String
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 12) {

            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 32)

            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)

            Spacer()

            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}

// MARK: - PREVIEW
#Preview {
    NavigationStack {
        AppointmentsView()
    }
}
