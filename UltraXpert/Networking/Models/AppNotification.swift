import Foundation

// MARK: - App Notification Model (local, mapped from backend)
struct AppNotification: Identifiable {
    let id = UUID()
    let backendID: String       // server-side UUID
    let title: String
    let message: String
    let icon: String
    let date: Date
    var isRead: Bool
    let fileURL: String?
    
    var timeText: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }

    // Map from backend response
    init(from response: NotificationResponse) {
        self.backendID = response.id
        self.title     = response.title
        self.message   = response.message
        self.icon      = response.icon
        self.isRead    = response.is_read
        self.fileURL   = response.file_url

        // Parse ISO8601 date from backend, fall back to now
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        self.date = isoFormatter.date(from: response.created_at) ?? Date()
    }
}
