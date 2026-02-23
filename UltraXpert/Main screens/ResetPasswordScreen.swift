import SwiftUI

struct ResetPasswordScreen: View {

    @Environment(\.dismiss) var dismiss
    @State private var email = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // MARK: - App Icon & Name
                HStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                LinearGradient(
                                    colors: [.blue, .cyan],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 56, height: 56)

                        Image(systemName: "lock.fill")
                            .foregroundColor(.white)
                            .font(.system(size: 24))
                    }

                    Text("UltraXpert")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                .padding(.top, 10)

                // MARK: - Title
                Text("Reset Password")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Enter your email to receive reset instructions")
                    .foregroundColor(.gray)

                // MARK: - Email Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Email Address")
                        .foregroundColor(.gray)

                    TextField("doctor@hospital.org", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.gray.opacity(0.3))
                        )
                }

                // MARK: - Send Reset Link
                Button {
                    // API call later
                } label: {
                    Text("Send Reset Link")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(14)
                }
                .padding(.top, 10)

                // MARK: - Secure Info Box
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "shield.checkmark")
                        .foregroundColor(.blue)

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Secure Reset Process")
                            .fontWeight(.semibold)

                        Text("For security, password reset links expire after 1 hour. The link can only be used once.")
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(Color.blue.opacity(0.05))
                .cornerRadius(14)
                .padding(.top, 10)

                Spacer(minLength: 40)

                // MARK: - Bottom Sign In
                HStack {
                    Spacer()
                    Text("Remember your password?")
                        .foregroundColor(.gray)

                    Button("Sign In") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                    Spacer()
                }
            }
            .padding(.horizontal, 24)
        }
    }
}

#Preview {
    NavigationStack {
        ResetPasswordScreen()
    }
}
