import SwiftUI

struct ScanUploadScreen: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "square.and.arrow.up")
                .font(.system(size: 40, weight: .bold))
                .padding(.bottom, 6)

            Text("Scan Upload")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Upload ultrasound scan images here.")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

#Preview {
    ScanUploadScreen()
}
