import Foundation

// MARK: - Appointment Request
struct AppointmentCreateRequest: Encodable {
    let patient_id: String
    let time: String
    let type: String?
    let room: String?
    let status: String
    let notes: String?
}

// MARK: - Appointment Response
struct AppointmentResponse: Decodable {
    let id: String
    let patient_id: String?
    let type: String?
    let time: String?
    let room: String?
    let status: String
    let notes: String?
    let patient_name: String?
}
