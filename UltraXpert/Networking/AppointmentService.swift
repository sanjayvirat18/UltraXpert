import Foundation

protocol AppointmentServiceProtocol {
    func getAppointments() async throws -> [AppointmentResponse]
    func addAppointment(request: AppointmentCreateRequest) async throws -> AppointmentResponse
}

class AppointmentService: AppointmentServiceProtocol {
    
    func getAppointments() async throws -> [AppointmentResponse] {
        return try await APIClient.shared.request(
            endpoint: "/api/v1/appointments/",
            method: "GET",
            responseType: [AppointmentResponse].self
        )
    }
    
    func addAppointment(request: AppointmentCreateRequest) async throws -> AppointmentResponse {
        return try await APIClient.shared.request(
            endpoint: "/api/v1/appointments/",
            method: "POST",
            body: request,
            responseType: AppointmentResponse.self
        )
    }
}
