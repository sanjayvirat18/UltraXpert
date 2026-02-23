import SwiftUI

struct PracticeModeView: View {
    
    @State private var noiseReduction: Double = 0.5
    @State private var contrast: Double = 0.5
    @State private var sharpness: Double = 0.5
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                
                // Instructions
                VStack(spacing: 8) {
                    Text("Practice Lab")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Adjust sliders to see how each parameter affects the image simulation.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top)
                
                // Simulated Image View
                ZStack {
                    Image("sample_ultrasound")
                        .resizable()
                        .scaledToFill()
                        .frame(height: 280)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                    
                    // Simulated Effects Overlay
                    Color.white
                        .opacity(0.1 + (contrast * 0.2)) // Visualize contrast
                        .blur(radius: (1.0 - noiseReduction) * 5) // Visualize smoothing
                        .mask(RoundedRectangle(cornerRadius: 18))
                }
                .padding(.horizontal)
                
                // Sliders
                VStack(spacing: 20) {
                    practiceSlider(title: "Noise Reduction", value: $noiseReduction, icon: "waveform.path.ecg")
                    practiceSlider(title: "Contrast", value: $contrast, icon: "circle.lefthalf.filled")
                    practiceSlider(title: "Sharpness", value: $sharpness, icon: "viewfinder")
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(.horizontal)
                
                // Feedback
                VStack(alignment: .leading, spacing: 10) {
                    Text("Real-time Feedback")
                        .font(.headline)
                    
                    if contrast > 0.8 {
                        feedbackRow(text: "High contrast may lose details in shadow areas.", color: .orange)
                    } else if noiseReduction > 0.8 {
                        feedbackRow(text: "High smoothing might blur fine edges.", color: .orange)
                    } else {
                        feedbackRow(text: "Settings look balanced.", color: .green)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                
                Spacer(minLength: 40)
            }
        }
        .navigationTitle("Practice")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func practiceSlider(title: String, value: Binding<Double>, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label(title, systemImage: icon)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                Text("\(Int(value.wrappedValue * 100))%")
                    .font(.caption)
                    .monospacedDigit()
                    .foregroundColor(.secondary)
            }
            
            Slider(value: value, in: 0...1)
        }
    }
    
    private func feedbackRow(text: String, color: Color) -> some View {
        HStack(spacing: 10) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(text)
                .font(.subheadline)
                .foregroundColor(.primary)
        }
    }
}

#Preview {
    NavigationStack {
        PracticeModeView()
    }
}
