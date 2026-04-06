import SwiftUI

struct LoginScreen: View {

    @StateObject private var viewModel = LoginViewModel()
    @AppStorage("themeColor") private var themeColorName = "Blue"

    let onLoginSuccess: () -> Void
    let onForgotPassword: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 30) {

                // MARK: Logo & Title
                VStack(spacing: 1) {
                    Image("Applogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 380, height: 180)
                        .padding(.top, 5)
                    Text("UltraXpert")
                        .font(.title)
                        .fontWeight(.bold)

                }
                VStack(spacing:10) {
                    
                    Text("Enhance your ultrasound images")
                        .foregroundColor(.gray)
                        .font(.subheadline)
                }

                // MARK: Login Card
                VStack(spacing: 16) {

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Email Address")
                            .foregroundColor(.gray)

                        TextField("Enter Your Email", text: $viewModel.email)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled(true)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                    }

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Password")
                            .foregroundColor(.gray)

                        SecureField("Enter your password", text: $viewModel.password)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(12)
                    }



                    // Forgot Password
                    Button {
                        onForgotPassword()
                    } label: {
                        Text("Forgot Password?")
                            .foregroundColor(ThemeManager.shared.color(for: themeColorName))
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }

                    // Login & Biometric Row
                    HStack(spacing: 12) {
                        // Login Button
                        Button {
                            viewModel.login(onSuccess: onLoginSuccess)
                        } label: {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .frame(maxWidth: .infinity)
                                    .padding()
                            } else {
                                Text("Log In")
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                            }
                        }
                        .disabled(viewModel.isLoading)
                        .background(ThemeManager.shared.color(for: themeColorName))
                        .cornerRadius(14)

                        // Biometric Button
                        if UserDefaults.standard.bool(forKey: "biometricEnabled") {
                            Button {
                                viewModel.biometricLogin(onSuccess: onLoginSuccess)
                            } label: {
                                Image(systemName: SecurityManager.shared.biometricsType() == "Face ID" ? "faceid" : "touchid")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .frame(width: 54, height: 54)
                                    .background(ThemeManager.shared.color(for: themeColorName).opacity(0.8))
                                    .cornerRadius(14)
                            }
                        }
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(.secondarySystemBackground))
                        .shadow(color: .black.opacity(0.1), radius: 8)
                )
                .padding(.horizontal)

                // Footer
                VStack(spacing: 12) {
                    HStack {
                        Text("Don't have an account?")
                            .foregroundColor(.gray)

                        NavigationLink(destination: SignUpScreen()) {
                            Text("Create Account")
                                .foregroundColor(ThemeManager.shared.color(for: themeColorName))
                                .fontWeight(.semibold)
                        }
                    }

                    Text("Protected under HIPAA regulations")
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .background(Color(.systemGroupedBackground))
        .alert(isPresented: $viewModel.showError) {
            Alert(
                title: Text(viewModel.errorMessage == "This account has been deleted" ? "Account Deleted" : "Login Failed"),
                message: Text(viewModel.errorMessage ?? "An unknown error occurred."),
                dismissButton: .default(Text("OK"))
            )
        }
    }


}

#Preview {
    NavigationStack {
        LoginScreen(
            onLoginSuccess: {},
            onForgotPassword: {}
        )
    }
}
