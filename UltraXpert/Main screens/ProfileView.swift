import SwiftUI

struct UserProfileResponse: Codable {
    var id: String?
    var full_name: String?
    var email: String?
    var medical_license_id: String?
    var role: String?
    var phone_number: String?
    var hospital_name: String?
    var specialization: String?
    var enable_notifications: Bool?
    var scan_updates: Bool?
    var profile_image_url: String?
}

struct UserProfileUpdate: Codable {
    var full_name: String?
    var email: String?
    var medical_license_id: String?
    var phone_number: String?
    var hospital_name: String?
    var specialization: String?
    var enable_notifications: Bool?
    var scan_updates: Bool?
}

struct ProfileScreen: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("themeColor") private var themeColorName = "Blue"
    private var themeColor: Color { ThemeManager.shared.color(for: themeColorName) }

    // MARK: - Basic Info
    @State private var fullName = ""
    @State private var email = ""
    @State private var phone = ""
    @State private var licenseID = ""
    @State private var hospitalName = ""

    // MARK: - Doctor Specialization
    @State private var specialization = "Radiologist"
    private let specializationOptions = [
        "Radiologist",
        "Sonologist",
        "Gynecologist",
        "General Physician",
        "Other"
    ]

    // MARK: - Settings
    @State private var enableNotifications = true
    @State private var enableScanUpdates = true

    // MARK: - Profile Image
    @State private var profileImage: UIImage? = nil
    @State private var profileImageUrl: String? = nil
    @State private var showImagePicker = false

    // MARK: - Alerts
    @State private var showSaveAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    
                    // Profile Header
                    profileHeader
                    
                    // Personal Information
                    VStack(alignment: .leading, spacing: 20) {
                        sectionTitle("Personal Information")
                        
                        UXProfileInputField(title: "Full Name", text: $fullName, icon: "person.fill")
                        UXProfileInputField(title: "Email Address", text: $email, icon: "envelope.fill", keyboardType: .emailAddress)
                        UXProfileInputField(title: "Phone Number", text: $phone, icon: "phone.fill", keyboardType: .phonePad)
                    }
                    .padding(20)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(20)
                    
                    // Professional Details
                    VStack(alignment: .leading, spacing: 20) {
                        sectionTitle("Professional Information")
                        
                        UXProfileInputField(title: "Hospital Name", text: $hospitalName, icon: "building.2.fill")
                        UXProfileInputField(title: "Medical License ID", text: $licenseID, icon: "lanyard.card.fill")
                        
                        // Specialization Picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Specialization")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                            
                            Menu {
                                ForEach(specializationOptions, id: \.self) { option in
                                    Button(option) {
                                        specialization = option
                                    }
                                }
                            } label: {
                                HStack {
                                    Image(systemName: "stethoscope")
                                        .foregroundColor(themeColor)
                                        .frame(width: 24)
                                    
                                    Text(specialization)
                                        .foregroundColor(.primary)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                                .padding()
                                .background(Color(.systemBackground))
                                .cornerRadius(12)
                            }
                        }
                    }
                    .padding(20)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(20)
                    
                    // Settings
                    VStack(alignment: .leading, spacing: 20) {
                        sectionTitle("Preferences")
                        
                        UXToggleRow(title: "Enable Notifications", isOn: $enableNotifications, icon: "bell.fill", color: .orange)
                        UXToggleRow(title: "Scan Updates", isOn: $enableScanUpdates, icon: "waveform.path.ecg", color: .green)
                    }
                    .padding(20)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(20)
                    
                    // Save Button
                    Button(action: saveProfile) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("Save Changes")
                            }
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [themeColor, themeColor.opacity(0.75)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(color: themeColor.opacity(0.3), radius: 5, x: 0, y: 3)
                    }
                    .disabled(isLoading)
                    .padding(.top, 10)
                    
                    Spacer(minLength: 40)
                }
                .padding(20)
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showImagePicker) {
            PhotoPicker(image: $profileImage)
        }
        .alert("Profile Update", isPresented: $showSaveAlert) {
            Button("OK", role: .cancel) { 
                if alertMessage.contains("successfully") {
                    dismiss()
                }
            }
        } message: {
            Text(alertMessage)
        }
        .onAppear {
            fetchProfile()
        }
    }

    // MARK: - Header View
    private var profileHeader: some View {
        VStack(spacing: 16) {
            Button {
                showImagePicker = true
            } label: {
                ZStack {
                    Circle()
                        .fill(themeColor.opacity(0.1))
                        .frame(width: 110, height: 110)
                        .overlay(
                            Circle().stroke(themeColor.opacity(0.3), lineWidth: 1)
                        )
                    
                    if let image = profileImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                    } else if let imageUrlPath = profileImageUrl, let imageUrl = URL(string: AppConfig.backendURL + imageUrlPath) {
                        AsyncImage(url: imageUrl) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                    } else {
                        Image(systemName: "person.fill")
                            .font(.system(size: 40))
                            .foregroundColor(themeColor)
                    }
                    
                    // Edit Badge
                    Circle()
                        .fill(themeColor)
                        .frame(width: 32, height: 32)
                        .overlay(
                            Image(systemName: "camera.fill")
                                .font(.caption)
                                .foregroundColor(.white)
                        )
                        .offset(x: 36, y: 36)
                        .shadow(radius: 2)
                }
            }
            .buttonStyle(.plain)
            
            VStack(spacing: 4) {
                Text(fullName.isEmpty ? "Doctor Name" : fullName)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(specialization)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(themeColor.opacity(0.1))
                    .clipShape(Capsule())
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }
    
    // MARK: - UI Helpers
    
    private func sectionTitle(_ title: String) -> some View {
        Text(title)
            .font(.headline)
            .fontWeight(.semibold)
            .foregroundColor(.primary)
    }
    
    // MARK: - API Calls
    private func fetchProfile() {
        Task {
            do {
                let profile = try await APIClient.shared.request(endpoint: "/api/v1/users/me", method: "GET", responseType: UserProfileResponse.self)
                DispatchQueue.main.async {
                    self.fullName = profile.full_name ?? ""
                    self.email = profile.email ?? ""
                    self.phone = profile.phone_number ?? ""
                    self.hospitalName = profile.hospital_name ?? ""
                    self.licenseID = profile.medical_license_id ?? ""
                    self.specialization = profile.specialization ?? "Radiologist"
                    self.enableNotifications = profile.enable_notifications ?? true
                    self.enableScanUpdates = profile.scan_updates ?? true
                    self.profileImageUrl = profile.profile_image_url
                }
            } catch {
                print("Failed to fetch profile: \(error.localizedDescription)")
            }
        }
    }
    
    private func saveProfile() {
        guard !fullName.trimmingCharacters(in: .whitespaces).isEmpty else {
            alertMessage = "Full name is required."
            showSaveAlert = true
            return
        }
        
        isLoading = true
        
        let updateData = UserProfileUpdate(
            full_name: fullName.isEmpty ? nil : fullName,
            email: email.isEmpty ? nil : email,
            medical_license_id: licenseID.isEmpty ? nil : licenseID,
            phone_number: phone.isEmpty ? nil : phone,
            hospital_name: hospitalName.isEmpty ? nil : hospitalName,
            specialization: specialization,
            enable_notifications: enableNotifications,
            scan_updates: enableScanUpdates
        )
        
        Task {
            do {
                if let imageToUpload = profileImage {
                    try await uploadProfileImageAPI(image: imageToUpload)
                }
                
                _ = try await APIClient.shared.request(endpoint: "/api/v1/users/me", method: "PUT", body: updateData, responseType: UserProfileResponse.self)
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.alertMessage = "Your profile has been updated successfully!"
                    self.profileImage = nil // Reset so it doesn't upload again unless changed
                    self.showSaveAlert = true
                    // Will also trigger dismiss via the OK button
                }
            } catch {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.alertMessage = "Failed to update profile: \(error.localizedDescription)"
                    self.showSaveAlert = true
                }
            }
        }
    }
    
    // Custom Multipart Image Upload
    private func uploadProfileImageAPI(image: UIImage) async throws {
        guard let url = URL(string: AppConfig.backendURL + "/api/v1/users/me/image") else { throw APIError.invalidURL }
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { throw APIError.requestFailed }
        
        let boundary = UUID().uuidString
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        if let token = UserDefaults.standard.string(forKey: "access_token") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        var body = Data()
        let filename = "profile_\(UUID().uuidString).jpg"
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        let (_, response) = try await URLSession.shared.upload(for: request, from: body)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw APIError.requestFailed
        }
    }
}

// MARK: - Custom Input Component
struct UXProfileInputField: View {
    let title: String
    @Binding var text: String
    let icon: String
    var keyboardType: UIKeyboardType = .default
    @AppStorage("themeColor") private var themeColorName = "Blue"
    private var themeColor: Color { ThemeManager.shared.color(for: themeColorName) }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(themeColor)
                    .frame(width: 24)
                
                TextField(title, text: $text)
                    .keyboardType(keyboardType)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
        }
    }
}

// MARK: - Custom Toggle Row
struct UXToggleRow: View {
    let title: String
    @Binding var isOn: Bool
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)
                .font(.system(size: 20))
            
            Text(title)
                .font(.body)
                .fontWeight(.medium)
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .labelsHidden()
        }
    }
}

#Preview {
    NavigationStack {
        ProfileScreen()
    }
}
