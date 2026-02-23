import SwiftUI

struct ManualEnhancementView: View {

    let originalImage: UIImage

    @State private var noise: Double = 0.2
    @State private var contrast: Double = 1.0
    @State private var sharpness: Double = 0.4

    @State private var goResult = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 18) {

                Text("Manual Enhancement")
                    .font(.title2).bold()
                    .frame(maxWidth: .infinity, alignment: .leading)

                // Preview (for now same image)
                Image(uiImage: originalImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 260)
                    .clipShape(RoundedRectangle(cornerRadius: 18))

                VStack(spacing: 16) {
                    sliderRow("Noise Reduction", value: $noise, range: 0...1)
                    sliderRow("Contrast", value: $contrast, range: 0.5...2)
                    sliderRow("Edge Sharpness", value: $sharpness, range: 0...2)
                }
                .padding(14)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 18))

                HStack(spacing: 12) {
                    Button {
                        noise = 0.2
                        contrast = 1.0
                        sharpness = 0.4
                    } label: {
                        Text("Reset")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color(.systemGray5))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }

                    Button {
                        goResult = true
                    } label: {
                        Text("Apply")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.black)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                }
            }
            .padding()
        }
        .navigationDestination(isPresented: $goResult) {
            EnhancedResultView(originalImage: originalImage, enhancedImage: originalImage)
        }
    }

    private func sliderRow(_ title: String, value: Binding<Double>, range: ClosedRange<Double>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title).font(.headline)
                Spacer()
                Text(String(format: "%.2f", value.wrappedValue))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Slider(value: value, in: range)
        }
    }
}
