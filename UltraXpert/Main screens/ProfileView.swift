import SwiftUI
import PhotosUI

struct ProfileScreen: View {

    // MARK: - Basic Info
    @State private var fullName = "Dr. Jane Smith"
    @State private var email = "doctor@hospital.org"
    @State private var phone = "+91 98765 43210"
    @State private var licenseID = "ML-123456789"
    @State private var hospitalName = "City Hospital"

    // MARK: - Doctor Specialization
    @State private var specialization = "Radiologist"
    private let specializationOptions = [
        "Radiologist",
        "Sonologist",
        "Gynecologist",
        "General Physician",
        "Other"
    ]

    // MARK: - Password
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isEditingPassword = false

    // MARK: - Settings
    @State private var enableNotifications = true
    @State private var enableScanUpdates = true

    // MARK: - Profile Image
    @State private var profileImage: UIImage? = nil
    @State private var showImagePicker = false

    // MARK: - Alerts
    @State private var showSaveAlert = false
    @State private var alertMessage = ""


    var body: some View {
        ScrollView {
            VStack(spacing: 24) {

                // MARK: - Profile Image Upload
                VStack(spacing: 12) {
                    Button {
                        showImagePicker = true
                    } label: {
                        ZStack(alignment: .bottomTrailing) {
                            if let image = profileImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 120, height: 120)
                                    .clipShape(Circle())
                            } else {
                                Circle()
                                    .fill(Color.gray.opacity(0.15))
                                    .frame(width: 120, height: 120)
                                    .overlay(
                                        Image(systemName: "person.fill")
                                            .font(.system(size: 50))
                                            .foregroundColor(.gray)
                                    )
                            }

                            Circle()
                                .fill(Color.blue)
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 14))
                                        .foregroundColor(.white)
                                )
                        }
                    }

                    Text("Tap to change profile photo")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding(.top, 16)

                // MARK: - Title
                VStack(alignment: .leading, spacing: 4) {
                    Text("Profile")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Update your information and account settings")
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                // MARK: - Doctor Info Section
                sectionHeader("Doctor Information")

                inputField(title: "Full Name", placeholder: "Enter Your Name", text: $fullName)

                inputField(
                    title: "Email Address",
                    placeholder: "Enter Your Email",
                    text: $email,
                    keyboard: .emailAddress
                )

                inputField(
                    title: "Phone Number",
                    placeholder: "+91 XXXXX XXXXX",
                    text: $phone,
                    keyboard: .phonePad
                )

                // Specialization Picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("Specialization")
                        .foregroundColor(.gray)

                    Menu {
                        ForEach(specializationOptions, id: \.self) { option in
                            Button(option) {
                                specialization = option
                            }
                        }
                    } label: {
                        HStack {
                            Text(specialization)
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(.gray)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.3))
                        )
                    }
                }

                inputField(
                    title: "Hospital / Clinic Name",
                    placeholder: "Enter Hospital Name",
                    text: $hospitalName
                )

                inputField(
                    title: "Medical License ID",
                    placeholder: "License Number",
                    text: $licenseID
                )

                Text("Your state medical license number")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .leading)

                // MARK: - Preferences Section
                sectionHeader("Preferences")

                Toggle("Enable Notifications", isOn: $enableNotifications)
                Toggle("Scan Enhancement Updates", isOn: $enableScanUpdates)

            }
            .padding(.horizontal, 24)
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)

        // Image Picker
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(selectedImage: $profileImage)
        }

        // Save Alert
        .alert("Profile", isPresented: $showSaveAlert) {
            Button("OK") { }
        } message: {
            Text(alertMessage)
        }
    }

    // MARK: - Save Profile with Validation
    private func saveProfile() {

        // Basic validations
        guard !fullName.trimmingCharacters(in: .whitespaces).isEmpty else {
            alertMessage = "Full name is required."
            showSaveAlert = true
            return
        }

        guard email.contains("@") else {
            alertMessage = "Please enter a valid email address."
            showSaveAlert = true
            return
        }

        guard !licenseID.trimmingCharacters(in: .whitespaces).isEmpty else {
            alertMessage = "Medical License ID is required."
            showSaveAlert = true
            return
        }

        if isEditingPassword {
            guard password.count >= 8 else {
                alertMessage = "Password must be at least 8 characters."
                showSaveAlert = true
                return
            }

            guard password == confirmPassword else {
                alertMessage = "Passwords do not match."
                showSaveAlert = true
                return
            }
        }

        // Success
        alertMessage = "Your profile has been updated successfully!"
        showSaveAlert = true
    }

    // MARK: - UI Helpers
    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.headline)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 8)
    }

    private func inputField(
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
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.3))
                )
        }
    }

    private func secureField(
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
        ProfileScreen()
    }
}
