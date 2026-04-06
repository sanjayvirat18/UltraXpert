import SwiftUI

struct SignUpScreen: View {

    @Environment(\.dismiss) var dismiss
    @AppStorage("themeColor") private var themeColorName = "Blue"
    private var themeColor: Color { ThemeManager.shared.color(for: themeColorName) }

    @StateObject private var viewModel = SignUpViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                // MARK: - Title
                Text("Create Account")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Register for AI-powered ultrasound enhancement")
                    .foregroundColor(.gray)

                // MARK: - Full Name
                inputField(
                    title: "Full Name",
                    placeholder: "Dr. Jane Smith",
                    text: $viewModel.fullName
                )

                // MARK: - Email
                inputField(
                    title: "Email Address",
                    placeholder: "doctor@hospital.org",
                    text: $viewModel.email,
                    keyboard: .emailAddress
                )

                // MARK: - Medical License ID
                inputField(
                    title: "Medical License ID",
                    placeholder: "123456",
                    text: $viewModel.licenseID
                )

                Text("Your state medical license number")
                    .font(.caption)
                    .foregroundColor(.gray)

                // MARK: - Password
                secureField(
                    title: "Password",
                    placeholder: "Minimum 8 characters",
                    text: $viewModel.password
                )

                // MARK: - Confirm Password
                secureField(
                    title: "Confirm Password",
                    placeholder: "Re-enter password",
                    text: $viewModel.confirmPassword
                )

                // MARK: - Terms Checkbox
                HStack(alignment: .top, spacing: 12) {
                    Button {
                        viewModel.agreed.toggle()
                    } label: {
                        Image(systemName: viewModel.agreed ? "checkmark.square.fill" : "square")
                            .foregroundColor(viewModel.agreed ? themeColor : .gray)
                    }

                    Text("I agree to the Terms of Service, Privacy Policy, and HIPAA Business Associate Agreement. I confirm I am a licensed medical professional.")
                        .font(.footnote)
                        .foregroundColor(.gray)
                }

                // MARK: - Create Account Button (FIXED ✅)
                Button {
                    viewModel.signUp {
                        dismiss()
                    }
                } label: {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else if viewModel.showSuccess {
                        Image(systemName: "checkmark")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else {
                        Text("Create Account")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                }
                .disabled(!viewModel.agreed || viewModel.isLoading)
                .background(viewModel.agreed ? themeColor : themeColor.opacity(0.4))
                .cornerRadius(14)
                .padding(.top, 10)

                // MARK: - Already Have Account
                HStack {
                    Spacer()
                    Text("Already have an account?")
                        .foregroundColor(.gray)

                    Button("Sign In") {
                        dismiss()
                    }
                    .foregroundColor(themeColor)

                    Spacer()
                }
                .padding(.top, 10)
            }
            .padding(.horizontal, 24)
        }
        .alert(isPresented: $viewModel.showError) {
            Alert(
                title: Text("Sign Up Failed"),
                message: Text(viewModel.errorMessage ?? "An unknown error occurred."),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    // MARK: - Reusable Fields
    func inputField(
        title: String,
        placeholder: String,
        text: Binding<String>,
        keyboard: UIKeyboardType = .default
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .foregroundColor(.gray)

            TextField(placeholder, text: text)
                .keyboardType(keyboard)
                .autocapitalization(.none)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.3))
                )
        }
    }

    func secureField(
        title: String,
        placeholder: String,
        text: Binding<String>
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .foregroundColor(.gray)

            SecureField(placeholder, text: text)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.3))
                )
        }
    }
}

#Preview {
    NavigationStack {
        SignUpScreen()
    }
}
