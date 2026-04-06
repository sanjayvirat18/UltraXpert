import SwiftUI
import Combine

// MARK: - Appointment Model
struct Appointment: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var type: String
    var time: String // Display string for now to match UI, or could be Date
    var room: String
    var status: String
    var notes: String = ""
    
    // UI Helpers (Computed properties ok for models, but separating logic is better. 
    // Keeping simple for now as per previous struct)
    var statusColor: Color {
        switch status {
        case "Upcoming": return ThemeManager.shared.color(for: (UserDefaults.standard.string(forKey: "themeColor") ?? "Blue"))
        case "In Progress": return .green
        case "Pending": return .orange
        case "Completed": return .gray
        default: return ThemeManager.shared.color(for: (UserDefaults.standard.string(forKey: "themeColor") ?? "Blue"))
        }
    }
    
    var statusBg: Color {
        statusColor.opacity(0.15)
    }
}

// MARK: - Appointment ViewModel / Store
@MainActor
class AppointmentStore: ObservableObject {
    @Published var appointments: [Appointment] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let appointmentService: AppointmentServiceProtocol
    
    init(appointmentService: AppointmentServiceProtocol = AppointmentService()) {
        self.appointmentService = appointmentService
    }
    
    func clear() {
        self.appointments = []
        self.errorMessage = nil
    }
    
    func fetchAppointments() async {
        self.isLoading = true
        self.errorMessage = nil
        do {
            let responses = try await appointmentService.getAppointments()
            self.appointments = responses.map { res in
                Appointment(
                    name: res.patient_name ?? "Patient \(res.patient_id?.prefix(4) ?? "Unk")",
                    type: res.type ?? "General",
                    time: res.time ?? "TBD",
                    room: res.room ?? "TBD",
                    status: res.status,
                    notes: res.notes ?? ""
                )
            }
        } catch {
            self.errorMessage = "Failed to load appointments: \(error.localizedDescription)"
        }
        self.isLoading = false
    }
    
    func addAppointment(_ appointment: Appointment) {
        // Optimistic UI update
        appointments.insert(appointment, at: 0)
        
        let request = AppointmentCreateRequest(
            patient_id: "P-" + String(Int.random(in: 1000...9999)),
            time: appointment.time,
            type: appointment.type,
            room: appointment.room,
            status: appointment.status,
            notes: appointment.notes
        )
        
        Task {
            do {
                _ = try await appointmentService.addAppointment(request: request)
            } catch {
                self.errorMessage = "Failed to sync appointment: \(error.localizedDescription)"
            }
        }
    }
}
