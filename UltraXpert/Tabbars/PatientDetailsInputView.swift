import SwiftUI

struct PatientDetailsInputView: View {
    let image: UIImage
    let imageUrl: String?
    @EnvironmentObject var patientStore: PatientStore
    @EnvironmentObject var reportStore: ReportStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""
    @State private var age: String = ""
    @State private var gender: String = "Male"
    @State private var showSaveAlert = false
    
    let genderOptions = ["Male", "Female", "Other"]
    
    @State private var showSuccessOverlay = false
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("Report Details")
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Enter patient information to generate report")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 20)
                
                // Form Card
                VStack(spacing: 20) {
                    UXInputRow(title: "Patient Name", icon: "person.fill", text: $name)
                    
                    HStack(spacing: 16) {
                        UXInputRow(title: "Age", icon: "number.circle", text: $age, keyboardType: .numberPad)
                        
                        // Gender Picker
                        HStack {
                            Image(systemName: "figure.stand")
                                .foregroundColor(ThemeManager.shared.color(for: (UserDefaults.standard.string(forKey: "themeColor") ?? "Blue")))
                            Picker("Gender", selection: $gender) {
                                ForEach(genderOptions, id: \.self) { option in
                                    Text(option)
                                }
                            }
                            .tint(.primary)
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(12)
                    }
                }
                .padding(20)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(20)
                .padding(.horizontal)
                
                Spacer()
                
                // Save Button
                Button {
                    saveReport()
                } label: {
                    HStack {
                        Text("Generate & Save Report")
                            .fontWeight(.semibold)
                        Image(systemName: "checkmark.circle.fill")
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background((name.isEmpty || age.isEmpty) ? Color.gray : ThemeManager.shared.color(for: (UserDefaults.standard.string(forKey: "themeColor") ?? "Blue")))
                    .cornerRadius(16)
                    .shadow(color: ThemeManager.shared.color(for: (UserDefaults.standard.string(forKey: "themeColor") ?? "Blue")).opacity(0.3), radius: 10, x: 0, y: 5)
                }
                .disabled(name.isEmpty || age.isEmpty)
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
            .blur(radius: showSuccessOverlay ? 10 : 0)
            .animation(.easeInOut, value: showSuccessOverlay)
            
            // Success Overlay
            if showSuccessOverlay {
                SuccessPopup()
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func saveReport() {
        // Create Data
        let newReport = PatientReport(
            patientName: name,
            patientID: "P-\(Int.random(in: 1000...9999))",
            age: Int(age) ?? 0,
            gender: gender,
            scanType: "Ultrasound Scan",
            modality: "Ultrasound",
            bodyPart: "Unknown",
            referringDoctor: "Self-Referred",
            date: "Today, \(Date().formatted(date: .omitted, time: .shortened))",
            status: "Completed",
            statusColor: .green,
            findings: "Scan enhanced and processed successfully.",
            impression: "Enhanced scan available.",
            recommendations: "Clinical correlation recommended.",
            image: image,
            imageUrl: imageUrl
        )
        
        reportStore.addReport(newReport)
        
        // Save to Patient Store
        let newPatient = Patient(
            patientID: newReport.patientID,
            name: name,
            age: age,
            gender: gender,
            ultrasoundImages: [image]
        )
        patientStore.addPatient(newPatient)

        // Trigger Animation
        withAnimation(.spring()) {
            showSuccessOverlay = true
        }
        
        // Delay and Dismiss to Home
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            NotificationCenter.default.post(name: NSNotification.Name("DismissScanSheet"), object: nil)
        }
    }
}

// MARK: - Input Row Component
struct UXInputRow: View {
    let title: String
    let icon: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(ThemeManager.shared.color(for: (UserDefaults.standard.string(forKey: "themeColor") ?? "Blue")))
                .frame(width: 24)
            
            TextField(title, text: $text)
                .keyboardType(keyboardType)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Success Popup
struct SuccessPopup: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Circle()
                    .fill(Color.green)
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(systemName: "checkmark")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.white)
                    )
                    .scaleEffect(1.1)
                    .shadow(color: .green.opacity(0.5), radius: 20)
                
                VStack(spacing: 8) {
                    Text("Report Saved!")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Redirecting to Home...")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
            }
            .padding(40)
            .background(Color(.systemBackground))
            .cornerRadius(24)
            .shadow(radius: 20)
            .transition(.scale.combined(with: .opacity))
        }
    }
}

#Preview {
    NavigationStack {
        PatientDetailsInputView(image: UIImage(systemName: "person")!, imageUrl: nil)
            .environmentObject(PatientStore())
            .environmentObject(ReportStore())
    }
}
