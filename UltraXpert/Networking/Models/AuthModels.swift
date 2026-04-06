import Foundation
import SwiftUI

// MARK: - Generic Response Wrapper
struct ErrorResponse: Decodable {
    let detail: String?
}

// MARK: - Authentication Models
struct LoginResponse: Decodable {
    let access_token: String
    let token_type: String
}

struct SignUpRequest: Encodable {
    let email: String
    let password: String
    let full_name: String
    let medical_license_id: String
    let role: String
}

struct User: Decodable {
    let id: String?
    let email: String
    let full_name: String?
    let medical_license_id: String?
    let role: String?
}
struct ResetPasswordRequest: Encodable {
    let email: String
    let otp: String
    let new_password: String
}
