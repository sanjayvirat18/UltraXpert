import SwiftUI

struct LearningDetailView: View {
    
    let title: String
    let description: String
    let icon: String
    let tips: [String]
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                
                // Header Icon
                HStack {
                    Spacer()
                    Image(systemName: icon)
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                        .frame(width: 100, height: 100)
                        .background(Color.blue.opacity(0.1))
                        .clipShape(Circle())
                    Spacer()
                }
                .padding(.top, 20)
                
                // Title
                Text(title)
                    .font(.title)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .multilineTextAlignment(.center)
                
                Divider()
                
                // Description
                VStack(alignment: .leading, spacing: 12) {
                    Text("Overview")
                        .font(.headline)
                    
                    Text(description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .lineSpacing(6)
                }
                
                // Tips
                if !tips.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Key Takeaways")
                            .font(.headline)
                        
                        ForEach(tips, id: \.self) { tip in
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                    .padding(.top, 2)
                                
                                Text(tip)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                
                Spacer()
            }
            .padding(20)
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        LearningDetailView(
            title: "Noise Reduction",
            description: "Ultrasound images often contain speckle noise, which is granular interference that degrades image quality. Noise reduction algorithms smooth out these grain patterns while preserving important structural edges.",
            icon: "waveform.path.ecg",
            tips: [
                "Reduces grainy appearance.",
                "Improves visibility of soft tissue boundaries.",
                "Essential for clearer diagnosis."
            ]
        )
    }
}
