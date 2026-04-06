import SwiftUI

struct GuidelineDetailView: View {
    let title: String
    let date: String
    @AppStorage("themeColor") private var themeColorName = "Blue"
    private var themeColor: Color { ThemeManager.shared.color(for: themeColorName) }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                // Header Group
                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.leading)
                    
                    HStack {
                        Image(systemName: "calendar")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("Published: \(date)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.top)
                
                Divider()
                
                // Abstract / Summary
                VStack(alignment: .leading, spacing: 12) {
                    Text("Executive Summary")
                        .font(.headline)
                    
                    Text("This guideline provides updated recommendations for clinical practice, focusing on diagnostic accuracy and patient safety. It incorporates the latest evidence-based research and expert consensus opinions.")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .lineSpacing(6)
                }
                
                // Key Points
                VStack(alignment: .leading, spacing: 16) {
                    Text("Key Updates")
                        .font(.headline)
                    
                    VStack(spacing: 12) {
                        KeyPointRow(text: "Revised diagnostic criteria for early-stage detection.")
                        KeyPointRow(text: "Updated safety protocols for contrast-enhanced imaging.")
                        KeyPointRow(text: "New standardized reporting templates.")
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
                
                // Full Text Placeholder
                VStack(alignment: .leading, spacing: 12) {
                    Text("Full Recommendations")
                        .font(.headline)
                    
                    Text("1. Introduction\nThe clinical utility of ultrasound has expanded significantly... \n\n2. Methodology\nA systematic review of literature was conducted...\n\n3. Recommendations\nClinicians should facilitate...")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .lineSpacing(4)
                }
                
            }
            .padding(20)
        }
        .navigationTitle("Guideline Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct KeyPointRow: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
                .font(.subheadline)
            Text(text)
                .font(.subheadline)
            Spacer()
        }
    }
}
