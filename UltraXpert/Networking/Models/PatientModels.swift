import Foundation

// MARK: - Patient Request
struct PatientCreateRequest: Encodable {
    let patient_identifier: String
    let name: String
    let age: String
    let gender: String
}

// MARK: - Patient Response
struct PatientResponse: Decodable {
    let id: String
    let patient_identifier: String
    let name: String
    let age: String
    let gender: String
    let created_at: String?
}
