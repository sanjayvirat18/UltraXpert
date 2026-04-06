import Foundation
import SwiftUI
import Combine

@MainActor
class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false
    
    private let authService: AuthServiceProtocol
    
    init(authService: AuthServiceProtocol = AuthService()) {
        self.authService = authService
    }
    
    func login(onSuccess: @escaping () -> Void) {
        guard !email.isEmpty, !password.isEmpty else {
            self.errorMessage = "Please enter both email and password."
            self.showError = true
            return
        }
        
        self.isLoading = true
        self.errorMessage = nil
        self.showError = false
        
        Task {
            do {
                // Often OAuth2 in FastAPI requires `username` and `password` field for token generation
                let parameters = [
                    "username": email,
                    "password": password
                ]
                
                let response = try await authService.login(parameters: parameters)
                
                // Store the access token securely (e.g., UserDefaults or Keychain)
                UserDefaults.standard.set(response.access_token, forKey: "access_token")
                
                self.isLoading = false
                onSuccess()
            } catch {
                self.isLoading = false
                self.errorMessage = error.localizedDescription
                self.showError = true
            }
        }
    }

    func biometricLogin(onSuccess: @escaping () -> Void) {
        SecurityManager.shared.authenticateUser { success, error in
            if success {
                // In a real app, you would retrieve stored credentials from Keychain here.
                // For now, we'll proceed if the device is authenticated.
                DispatchQueue.main.async {
                    onSuccess()
                }
            } else if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = error
                    self.showError = true
                }
            }
        }
    }
}
