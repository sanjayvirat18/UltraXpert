import SwiftUI

struct ResetPasswordScreen: View {

    var onResetComplete: () -> Void
    var onBack: (() -> Void)? = nil

    @Environment(\.dismiss) private var dismiss
    @AppStorage("themeColor") private var themeColorName = "Blue"

    @State private var step = 1
    @State private var email = ""
    @State private var otp = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""

    @State private var isLoading = false
    @State private var errorMessage: String? = nil
    @State private var showResetError = false
    @State private var showSuccessAlert = false

    private let authService = AuthService()

    var body: some View {
        VStack(spacing: 30) {

            // MARK: Header
            VStack(spacing: 12) {
                Image(systemName: "lock.rotation")
                    .font(.system(size: 60))
                    .foregroundColor(ThemeManager.shared.color(for: themeColorName))

                Text(stepTitle)
                    .font(.title)
                    .fontWeight(.bold)

                Text(stepSubtitle)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 40)

            // MARK: Step Content
            VStack(spacing: 16) {

                if step == 1 {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Email Address")
                            .foregroundColor(.gray)

                        TextField("Enter your email", text: $email)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled(true)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                    }

                } else if step == 2 {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("OTP")
                            .foregroundColor(.gray)

                        TextField("Enter OTP", text: $otp)
                            .keyboardType(.numberPad)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                    }

                } else if step == 3 {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("New Password")
                            .foregroundColor(.gray)

                        SecureField("Enter new password", text: $newPassword)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)

                        SecureField("Confirm new password", text: $confirmPassword)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                    }
                }

                // MARK: Next / Reset Button
                Button(action: handleNext) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else {
                        Text(step == 3 ? "Reset Password" : "Next")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                }
                .disabled(isLoading)
                .background(ThemeManager.shared.color(for: themeColorName))
                .cornerRadius(14)
                .padding(.top, 10)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.secondarySystemBackground))    
                    .shadow(color: .black.opacity(0.1), radius: 8)
            )
            .padding(.horizontal)

            Spacer()
        }
        .navigationTitle("Reset Password")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    if let onBack = onBack {
                        onBack()
                    } else {
                        dismiss()
                    }
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.primary)
                }
            }
        }
        .background(Color(.systemGroupedBackground))
        .padding(.top, 20)

        .alert("Password Reset Successfully!", isPresented: $showSuccessAlert) {
            Button("OK") {
                onResetComplete()
            }
        } message: {
            Text("Now you can login using your new password.")
        }
        .alert("Error", isPresented: $showResetError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage ?? "An unknown error occurred.")
        }
    }

    private var stepTitle: String {
        switch step {
        case 1: return "Verify Email"
        case 2: return "Enter OTP"
        case 3: return "Set New Password"
        default: return ""
        }
    }

    private var stepSubtitle: String {
        switch step {
        case 1: return "Enter your email to receive OTP"
        case 2: return "Enter the OTP sent to your email"
        case 3: return "Enter your new password"
        default: return ""
        }
    }

    private func handleNext() {
        switch step {
        case 1:
            guard !email.isEmpty else { return }
            sendOTP()

        case 2:
            guard !otp.isEmpty else { return }
            verifyOTP()

        case 3:
            guard !newPassword.isEmpty,
                  !confirmPassword.isEmpty,
                  newPassword == confirmPassword else {
                errorMessage = "Passwords do not match or are empty."
                showResetError = true
                return
            }
            performReset()

        default:
            break
        }
    }

    private func sendOTP() {
        isLoading = true
        Task {
            do {
                let _ = try await authService.forgotPassword(email: email)
                await MainActor.run {
                    isLoading = false
                    step = 2
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                    showResetError = true
                }
            }
        }
    }

    private func verifyOTP() {
        isLoading = true
        Task {
            do {
                let _ = try await authService.verifyOTP(email: email, otp: otp)
                await MainActor.run {
                    isLoading = false
                    step = 3
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = "Invalid or expired OTP."
                    showResetError = true
                }
            }
        }
    }

    private func performReset() {
        isLoading = true
        Task {
            do {
                let request = ResetPasswordRequest(email: email, otp: otp, new_password: newPassword)
                let _ = try await authService.resetPassword(request: request)
                await MainActor.run {
                    isLoading = false
                    showSuccessAlert = true
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                    showResetError = true
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ResetPasswordScreen(onResetComplete: {})
    }
}
