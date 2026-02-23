import SwiftUI

struct EnhancementProcessingView: View {

    let originalImage: UIImage

    @State private var progress: Double = 0.0
    @State private var goResult = false

    var body: some View {
        VStack(spacing: 20) {

            Text("Enhancing Scan...")
                .font(.title2).bold()

            ProgressView(value: progress)
                .padding(.horizontal)

            Text(statusText)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer()
        }
        .padding()
        .onAppear {
            startFakeProgress()
        }
        .navigationDestination(isPresented: $goResult) {
            EnhancedResultView(originalImage: originalImage, enhancedImage: originalImage)
        }
    }

    private var statusText: String {
        if progress < 0.33 { return "Uploading scan..." }
        if progress < 0.66 { return "AI Enhancing..." }
        if progress < 0.95 { return "Finalizing output..." }
        return "Done!"
    }

    private func startFakeProgress() {
        progress = 0
        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            progress += 0.01
            if progress >= 1 {
                timer.invalidate()
                goResult = true
            }
        }
    }
}
