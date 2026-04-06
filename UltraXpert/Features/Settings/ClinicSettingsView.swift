import SwiftUI

struct ClinicSettingsView: View {
    @State private var clinicName = "City Health Clinic"
    @State private var address = "123 Medical Drive"
    @State private var contactEmail = "contact@cityhealth.com"
    @State private var logo: UIImage? = nil
    
    var body: some View {
        Form {
            Section(header: Text("Clinic Details")) {
                TextField("Clinic Name", text: $clinicName)
                TextField("Address", text: $address)
                TextField("Contact Email", text: $contactEmail)
            }
            
            Section(header: Text("Branding")) {
                HStack {
                    Text("Logo")
                    Spacer()
                    if logo != nil {
                        Image(systemName: "checkmark.circle.fill")
                    } else {
                        Button("Upload Logo") {
                            // Mock upload
                        }
                    }
                }
            }
            
            Section {
                Button("Save Changes") {
                    // Save
                }
            }
        }
        .navigationTitle("Clinic Settings")
    }
}
