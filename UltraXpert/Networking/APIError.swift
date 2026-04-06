import Foundation
import SwiftUI


enum APIError: Error, LocalizedError {
    case invalidURL
    case requestFailed
    case decodingError
    case serverError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL: return "The endpoint URL is invalid."
        case .requestFailed: return "The network request failed."
        case .decodingError: return "Failed to decode the response."
        case .serverError(let message): return message
        }
    }
}
