import SwiftUI

struct SignUpScreen: View {

    @Environment(\.dismiss) var dismiss

    @State private var fullName = ""
    @State private var email = ""
    @State private var licenseID = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var agreed = false

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
                    text: $fullName
                )

                // MARK: - Email
                inputField(
                    title: "Email Address",
                    placeholder: "doctor@hospital.org",
                    text: $email,
                    keyboard: .emailAddress
                )

                // MARK: - Medical License ID
                inputField(
                    title: "Medical License ID",
                    placeholder: "ML-123456789",
                    text: $licenseID
                )

                Text("Your state medical license number")
                    .font(.caption)
                    .foregroundColor(.gray)

                // MARK: - Password
                secureField(
                    title: "Password",
                    placeholder: "Minimum 8 characters",
                    text: $password
                )

                // MARK: - Confirm Password
                secureField(
                    title: "Confirm Password",
                    placeholder: "Re-enter password",
                    text: $confirmPassword
                )

                // MARK: - Terms Checkbox
                HStack(alignment: .top, spacing: 12) {
                    Button {
                        agreed.toggle()
                    } label: {
                        Image(systemName: agreed ? "checkmark.square.fill" : "square")
                            .foregroundColor(agreed ? .blue : .gray)
                    }

                    Text("I agree to the Terms of Service, Privacy Policy, and HIPAA Business Associate Agreement. I confirm I am a licensed medical professional.")
                        .font(.footnote)
                        .foregroundColor(.gray)
                }

                // MARK: - Create Account Button (FIXED ✅)
                Button {
                    // later: validation + API
                    dismiss()   // 👈 THIS IS THE KEY FIX
                } label: {
                    Text("Create Account")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(agreed ? Color.blue : Color.blue.opacity(0.4))
                        .cornerRadius(14)
                }
                .disabled(!agreed)
                .padding(.top, 10)

                // MARK: - Already Have Account
                HStack {
                    Spacer()
                    Text("Already have an account?")
                        .foregroundColor(.gray)

                    Button("Sign In") {
                        dismiss()
                    }
                    .foregroundColor(.blue)

                    Spacer()
                }
                .padding(.top, 10)
            }
            .padding(.horizontal, 24)
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
