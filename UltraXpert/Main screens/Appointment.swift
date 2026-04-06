import SwiftUI

// MARK: - MODEL
// MARK: - APPOINTMENTS LIST SCREEN
struct AppointmentsView: View {

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appointmentStore: AppointmentStore
    @AppStorage("themeColor") private var themeColorName = "Blue"
    @State private var showSchedule = false

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                topBar

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 18) {

                        dateHeader

                        if appointmentStore.appointments.isEmpty {
                            // Empty State
                            VStack(spacing: 20) {
                                Image(systemName: "calendar.badge.exclamationmark")
                                    .font(.system(size: 60))
                                    .foregroundColor(.secondary.opacity(0.4))
                                    .padding(.top, 40)
                                
                                Text("No Appointments")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                                
                                Text("You have no scheduled appointments. Tap the + icon to add one.")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 30)
                            }
                            .frame(maxWidth: .infinity)
                        } else {
                            VStack(spacing: 14) {
                                ForEach(appointmentStore.appointments) { appt in
                                    NavigationLink {
                                        AppointmentDetailView(appointment: appt)
                                    } label: {
                                        AppointmentCardView(appointment: appt)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 16)
                    .padding(.bottom, 28)
                }
            }
        }
        .navigationBarBackButtonHidden()
        .navigationDestination(isPresented: $showSchedule) {
            ScheduleAppointmentView()
        }
    }
}

// MARK: - TOP BAR
extension AppointmentsView {

    private var topBar: some View {
        HStack {

            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)
                .frame(width: 40, height: 40)
            }

            Spacer()

            HStack(spacing: 6) {
                Text("Appointments")
                    .font(.title3)
                    .fontWeight(.semibold)

                Image(systemName: "calendar")
                    .foregroundColor(.secondary)
            }

            Spacer()

            Button(action: {
                showSchedule = true
            }) {
                Image(systemName: "plus")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(ThemeManager.shared.color(for: themeColorName))
                    .frame(width: 40, height: 40)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color(.systemBackground))
    }

    private var dateHeader: some View {
        HStack {

            let today = DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .none)
            Text("Today, \(today)")
                .font(.title3)
                .fontWeight(.semibold)

            Spacer()

            Text("\(appointmentStore.appointments.count) Appointments")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - APPOINTMENT CARD
struct AppointmentCardView: View {

    let appointment: Appointment
    @AppStorage("themeColor") private var themeColorName = "Blue"
    @Environment(\.colorScheme) private var colorScheme

    private var themeColor: Color { ThemeManager.shared.color(for: themeColorName) }

    // Appointment type icon
    private var typeIcon: String {
        let lower = appointment.type.lowercased()
        if lower.contains("ultrasound") { return "waveform.path.ecg" }
        if lower.contains("consult")    { return "person.2.fill" }
        if lower.contains("follow")     { return "arrow.clockwise.circle.fill" }
        if lower.contains("ct")         { return "cpu.fill" }
        if lower.contains("mri")        { return "brain.head.profile" }
        return "stethoscope"
    }

    var body: some View {
        HStack(spacing: 0) {

            // ── Gradient left accent bar ─────────────────────────
            LinearGradient(
                colors: [themeColor, themeColor.opacity(0.35)],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(width: 4)
            .clipShape(
                UnevenRoundedRectangle(
                    topLeadingRadius: 18,
                    bottomLeadingRadius: 18,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: 0
                )
            )

            HStack(spacing: 14) {

                // ── Icon circle ──────────────────────────────────
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    themeColor.opacity(colorScheme == .dark ? 0.30 : 0.15),
                                    themeColor.opacity(colorScheme == .dark ? 0.12 : 0.06)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 50, height: 50)

                    Image(systemName: typeIcon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(themeColor)
                }

                // ── Text block ───────────────────────────────────
                VStack(alignment: .leading, spacing: 5) {

                    // Patient name
                    Text(appointment.name)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.primary)
                        .lineLimit(1)

                    // Appointment type pill
                    Text(appointment.type)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(themeColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(themeColor.opacity(colorScheme == .dark ? 0.20 : 0.10))
                        .clipShape(Capsule())

                    // Time + Room row
                    HStack(spacing: 12) {
                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                                .font(.system(size: 10))
                                .foregroundStyle(.secondary)
                            Text(appointment.time)
                                .font(.system(size: 11))
                                .foregroundStyle(.secondary)
                        }
                        HStack(spacing: 4) {
                            Image(systemName: "mappin.circle")
                                .font(.system(size: 10))
                                .foregroundStyle(.secondary)
                            Text(appointment.room)
                                .font(.system(size: 11))
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Spacer(minLength: 0)

                // ── Status badge ─────────────────────────────────
                Text(appointment.status)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(appointment.statusColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(appointment.statusColor.opacity(colorScheme == .dark ? 0.20 : 0.12))
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .stroke(appointment.statusColor.opacity(0.30), lineWidth: 0.8)
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
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(
                    colorScheme == .dark
                        ? Color.white.opacity(0.08)
                        : Color.black.opacity(0.06),
                    lineWidth: 0.8
                )
        )
        .shadow(
            color: themeColor.opacity(colorScheme == .dark ? 0.12 : 0.08),
            radius: 10, x: 0, y: 4
        )
    }
}

// MARK: - APPOINTMENT DETAIL SCREEN
struct AppointmentDetailView: View {

    let appointment: Appointment
    @Environment(\.dismiss) private var dismiss
    @AppStorage("themeColor") private var themeColorName = "Blue"

    var body: some View {
        ZStack {

            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            VStack(spacing: 0) {

                detailTopBar

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {

                        patientCard
                        infoCard
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 16)
                    .padding(.bottom, 28)
                }
            }
        }
        .navigationBarBackButtonHidden()
    }
}

// MARK: - DETAIL UI
extension AppointmentDetailView {

    private var detailTopBar: some View {
        HStack {

            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                    .frame(width: 40, height: 40)
            }

            Spacer()

            Text("Appointment Details")
                .font(.title3)
                .fontWeight(.semibold)

            Spacer()

            Spacer()
                .frame(width: 40)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color(.systemBackground))
    }

    private var patientCard: some View {
        VStack(spacing: 0) {

            // ── Hero gradient banner ─────────────────────────────
            ZStack {
                LinearGradient(
                    colors: [
                        ThemeManager.shared.color(for: themeColorName),
                        ThemeManager.shared.color(for: themeColorName).opacity(0.6)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .frame(height: 110)

                // Large icon circle with patient initial badge
                ZStack(alignment: .bottomTrailing) {
                    Circle()
                        .fill(Color.white.opacity(0.18))
                        .frame(width: 80, height: 80)
                        .overlay(
                            Circle().stroke(Color.white.opacity(0.35), lineWidth: 2)
                        )
                        .overlay(
                            Text(String(appointment.name.prefix(1)))
                                .font(.system(size: 34, weight: .bold))
                                .foregroundStyle(.white)
                        )

                    // Status pip
                    Circle()
                        .fill(appointment.statusColor)
                        .frame(width: 20, height: 20)
                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                        .offset(x: 4, y: 4)
                }
            }
            .clipShape(
                UnevenRoundedRectangle(
                    topLeadingRadius: 20,
                    bottomLeadingRadius: 0,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: 20
                )
            )

            // ── Patient info below banner ────────────────────────
            VStack(spacing: 10) {

                Text(appointment.name)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.primary)

                // Type + Status pills in one row
                HStack(spacing: 10) {
                    Text(appointment.type)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(ThemeManager.shared.color(for: themeColorName))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(ThemeManager.shared.color(for: themeColorName).opacity(0.12))
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(ThemeManager.shared.color(for: themeColorName).opacity(0.25), lineWidth: 0.8))

                    Text(appointment.status)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(appointment.statusColor)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(appointment.statusColor.opacity(0.12))
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(appointment.statusColor.opacity(0.30), lineWidth: 0.8))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .padding(.horizontal, 20)
            .background(Color(.systemBackground))
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.primary.opacity(0.07), lineWidth: 0.8)
        )
        .shadow(
            color: ThemeManager.shared.color(for: themeColorName).opacity(0.15),
            radius: 12, x: 0, y: 6
        )
    }

    private var infoCard: some View {
        VStack(spacing: 0) {

            // ── Section header ───────────────────────────────────
            HStack(spacing: 8) {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                ThemeManager.shared.color(for: themeColorName),
                                ThemeManager.shared.color(for: themeColorName).opacity(0.4)
                            ],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                    .frame(width: 3, height: 16)
                    .clipShape(Capsule())

                Text("Appointment Info")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                    .tracking(0.5)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 12)

            VStack(spacing: 0) {
                AppointmentInfoRow(icon: "calendar",  label: "Date",     value: "Monday, Oct 24, 2023",  themeColorName: themeColorName)
                Divider().padding(.leading, 62)
                AppointmentInfoRow(icon: "clock",     label: "Time",     value: appointment.time,        themeColorName: themeColorName)
                Divider().padding(.leading, 62)
                AppointmentInfoRow(icon: "mappin.circle", label: "Location", value: appointment.room,   themeColorName: themeColorName)
            }
            .padding(.bottom, 8)
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.primary.opacity(0.07), lineWidth: 0.8)
        )
        .shadow(
            color: ThemeManager.shared.color(for: themeColorName).opacity(0.08),
            radius: 8, x: 0, y: 4
        )
    }

    private var actionButtons: some View {
        VStack(spacing: 0) {

            // ── Section header ───────────────────────────────────
            HStack(spacing: 8) {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                ThemeManager.shared.color(for: themeColorName),
                                ThemeManager.shared.color(for: themeColorName).opacity(0.4)
                            ],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                    .frame(width: 3, height: 16)
                    .clipShape(Capsule())

                Text("Quick Actions")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                    .tracking(0.5)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 16)

            HStack(spacing: 14) {

                NavigationLink { ConsultationView() } label: {
                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            ThemeManager.shared.color(for: themeColorName).opacity(0.20),
                                            ThemeManager.shared.color(for: themeColorName).opacity(0.08)
                                        ],
                                        startPoint: .topLeading, endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 56, height: 56)
                            Image(systemName: "message.fill")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundStyle(ThemeManager.shared.color(for: themeColorName))
                        }
                        Text("Chat")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(ThemeManager.shared.color(for: themeColorName))
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)

                Button(action: {}) {
                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            ThemeManager.shared.color(for: themeColorName).opacity(0.20),
                                            ThemeManager.shared.color(for: themeColorName).opacity(0.08)
                                        ],
                                        startPoint: .topLeading, endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 56, height: 56)
                            Image(systemName: "phone.fill")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundStyle(ThemeManager.shared.color(for: themeColorName))
                        }
                        Text("Call")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(ThemeManager.shared.color(for: themeColorName))
                    }
                    .frame(maxWidth: .infinity)
                }

                Button(action: {}) {
                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            ThemeManager.shared.color(for: themeColorName).opacity(0.20),
                                            ThemeManager.shared.color(for: themeColorName).opacity(0.08)
                                        ],
                                        startPoint: .topLeading, endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 56, height: 56)
                            Image(systemName: "doc.text.fill")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundStyle(ThemeManager.shared.color(for: themeColorName))
                        }
                        Text("Report")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundStyle(ThemeManager.shared.color(for: themeColorName))
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 20)
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.primary.opacity(0.07), lineWidth: 0.8)
        )
        .shadow(
            color: ThemeManager.shared.color(for: themeColorName).opacity(0.08),
            radius: 8, x: 0, y: 4
        )
    }
}

// MARK: - SCHEDULE APPOINTMENT SCREEN
struct ScheduleAppointmentView: View {

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appointmentStore: AppointmentStore
    @State private var patient = ""
    @State private var date = Date()
    @State private var time = Date()
    @State private var type = "Ultrasound Scan"
    @State private var notes = ""

    var body: some View {
        ZStack {

            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            VStack(spacing: 0) {

                topBar

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {

                        inputCard
                        confirmButton
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 20)
                    .padding(.bottom, 28)
                }
            }
        }
        .navigationBarBackButtonHidden()
    }
}

// MARK: - SCHEDULE UI
extension ScheduleAppointmentView {

    private var topBar: some View {
        HStack {

            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
                    .frame(width: 40, height: 40)
            }

            Spacer()

            Text("Schedule Appointment")
                .font(.title3)
                .fontWeight(.semibold)

            Spacer()

            Spacer()
                .frame(width: 40)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color(.systemBackground))
    }

    private var inputCard: some View {
        VStack(alignment: .leading, spacing: 18) {

            // Patient
            VStack(alignment: .leading, spacing: 6) {
                Text("Select Patient")
                    .font(.caption)
                    .foregroundColor(.secondary)

                TextField("Search patient...", text: $patient)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            // Date & Time
            HStack(spacing: 14) {

                VStack(alignment: .leading, spacing: 6) {
                    Text("Date")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    DatePicker("", selection: $date, displayedComponents: .date)
                        .labelsHidden()
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("Time")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    DatePicker("", selection: $time, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }

            // Type
            VStack(alignment: .leading, spacing: 6) {
                Text("Appointment Type")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Menu {
                    Button("Ultrasound Scan") { type = "Ultrasound Scan" }
                    Button("Consultation") { type = "Consultation" }
                    Button("Follow-up") { type = "Follow-up" }
                } label: {
                    HStack {
                        Text(type)
                        Spacer()
                        Image(systemName: "chevron.down")
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }

            // Notes
            VStack(alignment: .leading, spacing: 6) {
                Text("Notes")
                    .font(.caption)
                    .foregroundColor(.secondary)

                TextEditor(text: $notes)
                    .frame(height: 100)
                    .padding(8)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(18)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 22))
    }

    private var confirmButton: some View {
        Button(action: {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            let timeString = formatter.string(from: time)
            
            let newAppointment = Appointment(
                name: patient.isEmpty ? "Unknown Patient" : patient,
                type: type,
                time: timeString,
                room: "Room 101", // Default room
                status: "Upcoming",
                notes: notes
            )
            
            appointmentStore.addAppointment(newAppointment)
            dismiss()
        }) {
            Text("Confirm Schedule")
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding()
                .background(ThemeManager.shared.color(for: (UserDefaults.standard.string(forKey: "themeColor") ?? "Blue")))
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .padding(.top, 10)
    }
}

// MARK: - INFO ROW
struct AppointmentInfoRow: View {

    let icon: String
    let label: String
    let value: String
    let themeColorName: String

    private var themeColor: Color { ThemeManager.shared.color(for: themeColorName) }

    var body: some View {
        HStack(spacing: 14) {

            // Gradient icon circle
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                themeColor.opacity(0.18),
                                themeColor.opacity(0.07)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 38, height: 38)

                Image(systemName: icon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(themeColor)
            }

            Text(label)
                .font(.system(size: 14))
                .foregroundStyle(.secondary)

            Spacer()

            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.primary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

// MARK: - PREVIEW
#Preview {
    NavigationStack {
        AppointmentsView()
    }
}
