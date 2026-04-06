import SwiftUI

struct AddPatientView: View {

    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var patientStore: PatientStore

    // MARK: - Form Fields
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var dateOfBirth = Date()
    @State private var gender = "Male"
    @State private var contactNumber = ""
    @State private var email = ""
    @State private var address = ""
    
    // MARK: - Medical Info
    @State private var referringDoctor = ""
    @State private var medicalCondition = ""
    @State private var insuranceProvider = ""
    @State private var insurancePolicyNumber = ""

    // MARK: - UI State
    @State private var showError = false
    @State private var errorMessage = ""

    // Gender Options
    let genderOptions = ["Male", "Female", "Other"]

    var body: some View {
        NavigationStack {
            Form {
                
                // MARK: - Personal Information
                Section(header: Text("Personal Information")) {
                    TextField("First Name", text: $firstName)
                    TextField("Last Name", text: $lastName)
                    
                    DatePicker("Date of Birth", selection: $dateOfBirth, displayedComponents: .date)
                    
                    Picker("Gender", selection: $gender) {
                        ForEach(genderOptions, id: \.self) { option in
                            Text(option)
                        }
                    }
                }

                // MARK: - Contact Details
                Section(header: Text("Contact Details")) {
                    TextField("Phone Number", text: $contactNumber)
                        .keyboardType(.phonePad)
                    
                    TextField("Email Address", text: $email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                    
                    TextField("Address", text: $address)
                }

                // MARK: - Medical Details
                Section(header: Text("Medical Information")) {
                    TextField("Referring Doctor", text: $referringDoctor)
                    TextField("Chief Complaint / Condition", text: $medicalCondition)
                }
                
                // MARK: - Insurance (Optional)
                Section(header: Text("Insurance (Optional)")) {
                    TextField("Insurance Provider", text: $insuranceProvider)
                    TextField("Policy Number", text: $insurancePolicyNumber)
                }
            }
            .navigationTitle("Add New Patient")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save Patient") {
                        savePatient()
                    }
                    .disabled(firstName.isEmpty || lastName.isEmpty)
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK") { }
            } message: {
                Text(errorMessage)
            }
        }
    }

    // MARK: - Save Logic
    private func savePatient() {
        // Basic Validation
        guard !firstName.isEmpty, !lastName.isEmpty else {
            errorMessage = "Please enter the patient's full name."
            showError = true
            return
        }

        guard !contactNumber.isEmpty else {
            errorMessage = "Contact number is required."
            showError = true
            return
        }

        // Create Patient Object
        let fullName = "\(firstName) \(lastName)"
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: dateOfBirth, to: Date())
        let age = String(ageComponents.year ?? 0)
        
        let newPatient = Patient(
            patientID: generatePatientID(),
            name: fullName,
            age: age,
            gender: gender
            // Note: Patient model in PatientStore might need update to support email, address, etc.
            // For now, we fit into the existing model.
        )
        
        // Save to Store
        patientStore.addPatient(newPatient)
        
        dismiss()
    }
    
    private func generatePatientID() -> String {
        return "PT-\(Int.random(in: 10000...99999))"
    }
}

#Preview {
    AddPatientView()
        .environmentObject(PatientStore())
}
