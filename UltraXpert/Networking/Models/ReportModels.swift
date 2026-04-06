import Foundation

// MARK: - Report Request
struct ReportCreateRequest: Encodable {
    let patient_id: String
    let scan_type: String
    let modality: String
    let body_part: String
    let status: String
    let findings: String?
    let impression: String?
    let recommendations: String?
    let image_url: String?
}

// MARK: - Report Response
struct ReportResponse: Decodable {
    let id: String
    let patient_id: String
    let scan_type: String?
    let modality: String?
    let body_part: String?
    let status: String
    let findings: String?
    let impression: String?
    let recommendations: String?
    let created_at: String?
    let patient_name: String?
    let age: String?
    let gender: String?
    let doctor_name: String?
    let image_url: String?
}
