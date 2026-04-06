import SwiftUI

struct EnhancementSelectionView: View {
    let image: UIImage
    @Environment(\.dismiss) private var dismiss
    @AppStorage("themeColor") private var themeColorName = "Blue"
    private var themeColor: Color { ThemeManager.shared.color(for: themeColorName) }
    
    @State private var navigateToManual = false
    @State private var navigateToSmart = false

    var body: some View {
        VStack(spacing: 24) {
            Text("Enhancement Options")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top)
            
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(height: 250)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(radius: 4)
            
            Text("Choose how you want to enhance this scan.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            VStack(spacing: 16) {
                Button {
                    // Manual enhancement action
                    navigateToManual = true
                } label: {
                    HStack {
                        Image(systemName: "slider.horizontal.3")
                            .font(.title2)
                            .foregroundStyle(.white)
                        VStack(alignment: .leading) {
                            Text("Manual Enhancement")
                                .font(.headline)
                                .foregroundStyle(.white)
                            Text("Enhancement for Manual Correction")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.8))
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.white)
                    }
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [themeColor, themeColor.opacity(0.75)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: themeColor.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .buttonStyle(.plain)
                
                Button {
                    // Smart enhancement action
                    navigateToSmart = true
                } label: {
                    HStack {
                        Image(systemName: "wand.and.stars")
                            .font(.title2)
                            .foregroundStyle(.white)
                        VStack(alignment: .leading) {
                            Text("Smart Enhancement")
                                .font(.headline)
                                .foregroundStyle(.white)
                            Text("AI-powered auto correction")
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.8))
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.white)
                    }
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [themeColor, themeColor.opacity(0.75)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: themeColor.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $navigateToManual) {
            ManualEnhancementView(originalImage: image)
        }
        .navigationDestination(isPresented: $navigateToSmart) {
            SmartEnhancementView(originalImage: image)
        }
    }
}

#Preview {
    EnhancementSelectionView(image: UIImage(systemName: "doc.text.image")!)
}
