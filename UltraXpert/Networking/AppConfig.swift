import Foundation

/// Single source of truth for backend configuration.
/// To change the server URL, update ONLY this file.
enum AppConfig {
    static let backendURL = "http://180.235.121.253:8163"
    static let apiV1URL   = "\(backendURL)/api/v1"
}
