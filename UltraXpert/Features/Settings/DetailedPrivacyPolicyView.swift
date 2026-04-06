import SwiftUI

struct DetailedPrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Privacy Policy")
                    .font(.largeTitle)
                    .bold()
                
                Text("Last updated: October 2025")
                    .foregroundColor(.secondary)
                
                Group {
                    Text("1. Data Collection")
                        .font(.headline)
                    Text("We collect information you provide directly to us, such as when you create an account, upload content, or communicate with us. This is strictly for medical enhancement purposes.")
                    
                    Text("2. Patient Data Security (HIPAA)")
                        .font(.headline)
                    Text("We adhere to HIPAA guidelines to ensure that all patient data is encrypted and stored securely. No data is shared with third parties without explicit consent.")
                    
                    Text("3. Usage of Data")
                        .font(.headline)
                    Text("We use the data strictly to provide the enhancement services. We may use anonymized data to improve our AI models if you opt-in.")
                    
                    Divider()
                    
                    Text("Official Policy")
                        .font(.headline)
                    Link("View Full Privacy Policy Online", destination: URL(string: "https://sanjayvirat18.github.io/Privacy_policy/")!)
                        .font(.body)
                        .foregroundColor(.blue)
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Privacy Policy")
    }
}
