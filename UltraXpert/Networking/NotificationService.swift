import Foundation

// MARK: - Protocol
protocol NotificationServiceProtocol {
    func getNotifications() async throws -> [NotificationResponse]
    func markAsRead(id: String) async throws -> NotificationResponse
    func markAllRead() async throws
    func deleteNotification(id: String) async throws
    func clearAllNotifications() async throws
    func createNotification(request: NotificationCreateRequest) async throws -> NotificationResponse
    func getDownloads() async throws -> [NotificationResponse]
}

// MARK: - Service
class NotificationService: NotificationServiceProtocol {

    private let base = "/api/v1/notifications"

    func getNotifications() async throws -> [NotificationResponse] {
        return try await APIClient.shared.request(
            endpoint: "\(base)/",
            method: "GET",
            responseType: [NotificationResponse].self
        )
    }

    func markAsRead(id: String) async throws -> NotificationResponse {
        return try await APIClient.shared.request(
            endpoint: "\(base)/\(id)/read",
            method: "PATCH",
            responseType: NotificationResponse.self
        )
    }

    func markAllRead() async throws {
        let _: [String: Int] = try await APIClient.shared.request(
            endpoint: "\(base)/read-all",
            method: "PATCH",
            responseType: [String: Int].self
        )
    }

    func deleteNotification(id: String) async throws {
        // DELETE returns 204 No Content — use a Void-safe wrapper
        let _: EmptyResponse = try await APIClient.shared.request(
            endpoint: "\(base)/\(id)",
            method: "DELETE",
            responseType: EmptyResponse.self
        )
    }

    func clearAllNotifications() async throws {
        let _: EmptyResponse = try await APIClient.shared.request(
            endpoint: "\(base)/",
            method: "DELETE",
            responseType: EmptyResponse.self
        )
    }

    func createNotification(request: NotificationCreateRequest) async throws -> NotificationResponse {
        return try await APIClient.shared.request(
            endpoint: "\(base)/",
            method: "POST",
            body: request,
            responseType: NotificationResponse.self
        )
    }

    func getDownloads() async throws -> [NotificationResponse] {
        return try await APIClient.shared.request(
            endpoint: "/api/v1/export/downloads",
            method: "GET",
            responseType: [NotificationResponse].self
        )
    }
}

// MARK: - Helper for 204 No-Content responses
struct EmptyResponse: Decodable {}
