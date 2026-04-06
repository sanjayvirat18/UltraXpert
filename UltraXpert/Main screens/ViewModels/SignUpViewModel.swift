import Foundation
import SwiftUI
import Combine

@MainActor
class SignUpViewModel: ObservableObject {
    @Published var fullName = ""
    @Published var email = ""
    @Published var licenseID = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var agreed = false
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false
    @Published var showSuccess = false
    
    private let authService: AuthServiceProtocol
    
    init(authService: AuthServiceProtocol = AuthService()) {
        self.authService = authService
    }
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }

    /// Medical License must be at least 6 characters (letters optional)
    private func isValidLicenseID(_ license: String) -> Bool {
        let licenseRegEx = "^[A-Za-z0-9]{6,}$"
        let pred = NSPredicate(format: "SELF MATCHES %@", licenseRegEx)
        return pred.evaluate(with: license)
    }

    /// Password must have: min 8 chars, at least 1 digit, at least 1 special character
    private func isValidPassword(_ pwd: String) -> Bool {
        guard pwd.count >= 8 else { return false }
        let hasNumber = pwd.rangeOfCharacter(from: .decimalDigits) != nil
        let special = CharacterSet(charactersIn: "!@#$%^&*()_+-=[]{}|;':\",./<>?`~\\")
        let hasSpecial = pwd.unicodeScalars.contains { special.contains($0) }
        return hasNumber && hasSpecial
    }

    func signUp(onSuccess: @escaping () -> Void) {
        let trimmedName = fullName.trimmingCharacters(in: .whitespaces)
        let letterCount = trimmedName.filter { $0.isLetter }.count
        guard letterCount >= 3 else {
            self.errorMessage = "Full Name must contain at least 3 letters."
            self.showError = true
            return
        }
        
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedEmail.isEmpty else {
            self.errorMessage = "Email Address cannot be empty."
            self.showError = true
            return
        }
        
        guard isValidEmail(trimmedEmail) else {
            self.errorMessage = "Please enter a valid email address."
            self.showError = true
            return
        }
        
        let trimmedLicense = licenseID.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedLicense.isEmpty else {
            self.errorMessage = "Medical License ID cannot be empty."
            self.showError = true
            return
        }

        guard isValidLicenseID(trimmedLicense) else {
            self.errorMessage = "Medical License ID must be at least 6 characters long."
            self.showError = true
            return
        }
        
        guard isValidPassword(password) else {
            self.errorMessage = "Password must be at least 8 characters and include at least 1 number and 1 special character (e.g. @, #, !)."
            self.showError = true
            return
        }
        
        guard password == confirmPassword else {
            self.errorMessage = "Passwords do not match."
            self.showError = true
            return
        }
        
        self.isLoading = true
        self.errorMessage = nil
        self.showError = false
        
        Task {
            do {
                let request = SignUpRequest(
                    email: email,
                    password: password,
                    full_name: fullName,
                    medical_license_id: licenseID,
                    role: "Doctor"
                )
                
                let _ = try await authService.signup(request: request)
                
                self.isLoading = false
                self.showSuccess = true
                
                // Allow the user to read the success prompt, then callback
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    onSuccess()
                }
            } catch {
                self.isLoading = false
                self.errorMessage = error.localizedDescription
                self.showError = true
            }
        }
    }
}
