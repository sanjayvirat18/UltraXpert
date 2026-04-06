import SwiftUI

struct EnhancedResultView: View {
    let image: UIImage
    let originalImage: UIImage
    var response: EnhancementResponse? = nil
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appSettings: AppSettings
    @EnvironmentObject var patientStore: PatientStore
    @EnvironmentObject var analyticsStore: AnalyticsStore
    @AppStorage("themeColor") private var themeColorName = "Blue"
    private var themeColor: Color { ThemeManager.shared.color(for: themeColorName) }
    
    @State private var showSaveAlert = false
    @State private var navigateToReport = false

    var body: some View {
        VStack(spacing: 24) {
            
            // Header
            Text("Enhancement Complete")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top)
            
            // Result Image
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 350)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(radius: 5)
                .padding(.horizontal)
            
            Text("Your scan has been enhanced successfully.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Spacer()
            
            // Actions
            VStack(spacing: 16) {
                Button {
                    // Save to Analytics
                    analyticsStore.saveEnhancement(original: originalImage, enhanced: image, response: response)
                    showSaveAlert = true
                } label: {
                    Label("View Result", systemImage: "chart.bar.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .buttonStyle(.plain)
                
                Button {
                    navigateToReport = true
                } label: {
                    Label("Generate Report", systemImage: "doc.text.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [themeColor, themeColor.opacity(0.75)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            )
                        )
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .shadow(color: themeColor.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
        }
        .navigationBarTitleDisplayMode(.inline)
        .alert("Result Stored", isPresented: $showSaveAlert) {
            Button("OK", role: .cancel) {
                // Stay on the same screen
            }
        } message: {
            Text("This result has been successfully added to your analytics dashboard.")
        }
        .navigationDestination(isPresented: $navigateToReport) {
            PatientDetailsInputView(image: image, imageUrl: response?.enhanced_image_url)
        }
    }
    

}

#Preview {
    NavigationStack {
        EnhancedResultView(image: UIImage(systemName: "photo")!, originalImage: UIImage(systemName: "photo.fill")!)
    }
    .environmentObject(AnalyticsStore())
}
