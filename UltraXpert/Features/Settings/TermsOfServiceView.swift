import SwiftUI

struct TermsOfServiceView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Terms of Service")
                    .font(.largeTitle)
                    .bold()
                
                Text("Last updated: October 2025")
                    .foregroundColor(.secondary)
                
                Group {
                    Text("1. Acceptance of Terms")
                        .font(.headline)
                    Text("By accessing and using UltraXpert, you accept and agree to be bound by the terms and provision of this agreement.")
                    
                    Text("2. Use License")
                        .font(.headline)
                    Text("Permission is granted to temporarily download one copy of the materials (information or software) on UltraXpert's website for personal, non-commercial transitory viewing only.")
                    
                    Text("3. Disclaimer")
                        .font(.headline)
                    Text("The materials on UltraXpert's website are provided 'as is'. UltraXpert makes no warranties, expressed or implied, and hereby disclaims and negates all other warranties including, without limitation, implied warranties or conditions of merchantability, fitness for a particular purpose, or non-infringement of intellectual property or other violation of rights.")
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Terms")
    }
}
