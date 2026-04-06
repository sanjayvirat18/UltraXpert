import Foundation

// MARK: - Notification Response (from backend)
struct NotificationResponse: Decodable, Identifiable {
    let id: String
    let user_id: String
    let title: String
    let message: String
    let icon: String
    let type: String
    let is_read: Bool
    let file_url: String?    // Optional link to exported file
    let created_at: String   // ISO8601 date string from backend
}

// MARK: - Notification Create Request
struct NotificationCreateRequest: Encodable {
    let title: String
    let message: String
    let icon: String
    let type: String
}
