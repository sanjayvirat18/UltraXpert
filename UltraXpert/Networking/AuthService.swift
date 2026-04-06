import Foundation
import SwiftUI

protocol AuthServiceProtocol {
    func login(parameters: [String: String]) async throws -> LoginResponse
    func signup(request: SignUpRequest) async throws -> User
    func forgotPassword(email: String) async throws -> String
    func verifyOTP(email: String, otp: String) async throws -> String
    func resetPassword(request: ResetPasswordRequest) async throws -> String
}

class AuthService: AuthServiceProtocol {
    func login(parameters: [String: String]) async throws -> LoginResponse {
        return try await APIClient.shared.request(
            endpoint: "/api/v1/auth/login", 
            method: "POST", 
            body: parameters, 
            responseType: LoginResponse.self,
            isFormURLEncoded: true
        )
    }
    
    func signup(request: SignUpRequest) async throws -> User {
        return try await APIClient.shared.request(
            endpoint: "/api/v1/auth/signup",
            method: "POST",
            body: request,
            responseType: User.self,
            isFormURLEncoded: false
        )
    }

    func forgotPassword(email: String) async throws -> String {
        let response: [String: String] = try await APIClient.shared.request(
            endpoint: "/api/v1/auth/forgot-password",
            method: "POST",
            body: ["email": email],
            responseType: [String: String].self
        )
        return response["message"] ?? "OTP sent"
    }

    func verifyOTP(email: String, otp: String) async throws -> String {
        let response: [String: String] = try await APIClient.shared.request(
            endpoint: "/api/v1/auth/verify-otp",
            method: "POST",
            body: ["email": email, "otp": otp],
            responseType: [String: String].self
        )
        return response["message"] ?? "OTP verified"
    }

    func resetPassword(request: ResetPasswordRequest) async throws -> String {
        let response: [String: String] = try await APIClient.shared.request(
            endpoint: "/api/v1/auth/reset-password",
            method: "POST",
            body: request,
            responseType: [String: String].self
        )
        return response["message"] ?? "Password reset successful"
    }
}
