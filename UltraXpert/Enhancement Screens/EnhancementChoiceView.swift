import SwiftUI

struct EnhancementChoiceView: View {

    let scanImage: UIImage

    @State private var goManual = false
    @State private var goAI = false

    var body: some View {
        VStack(spacing: 18) {

            VStack(alignment: .leading, spacing: 6) {
                Text("Enhancement Mode")
                    .font(.title2).bold()
                Text("Choose how you want to enhance the scan")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Manual Card
            Button {
                goManual = true
            } label: {
                modeCard(
                    icon: "slider.horizontal.3",
                    title: "Manual Enhancement",
                    subtitle: "Adjust Noise, Contrast, Edge Sharpness"
                )
            }

            // AI Card
            Button {
                goAI = true
            } label: {
                modeCard(
                    icon: "sparkles",
                    title: "AI Enhancement",
                    subtitle: "Enhance automatically using presets"
                )
            }

            Spacer()
        }
        .padding()
        .navigationDestination(isPresented: $goManual) {
            ManualEnhancementView(originalImage: scanImage)
        }
        .navigationDestination(isPresented: $goAI) {
            AIEnhancementView(originalImage: scanImage)
        }
    }

    private func modeCard(icon: String, title: String, subtitle: String) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.blue.opacity(0.12))
                    .frame(width: 56, height: 56)

                Image(systemName: icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(.blue)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}
