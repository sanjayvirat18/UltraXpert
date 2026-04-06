import SwiftUI
import PhotosUI
import UIKit

struct ScanUploadScreen: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("themeColor") private var themeColorName = "Blue"
    
    @State private var showCamera = false
    @State private var showPhotosPicker = false
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var selectedImage: UIImage? = nil
    @State private var navigateToEnhance = false
    @State private var showAlert = false
    @State private var alertMsg = ""

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                // Header Section
                VStack(spacing: 8) {
                    Image(systemName: "viewfinder.circle.fill")
                        .font(.system(size: 64, weight: .semibold))
                        .foregroundColor(ThemeManager.shared.color(for: themeColorName))
                        .shadow(color: ThemeManager.shared.color(for: themeColorName).opacity(0.4), radius: 15, x: 0, y: 0)
                        .padding(.bottom, 10)
                    
                    Text("New Scan")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Select a method to upload your medical scan")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top, 60)
                .padding(.bottom, 40)
                
                // Action Cards
                VStack(spacing: 16) {
                    Button {
                        showPhotosPicker = true
                    } label: {
                        UXScanOptionCard(
                            title: "Import from Gallery",
                            subtitle: "Select existing scan image",
                            icon: "photo.fill", // Updated icon
                            color: ThemeManager.shared.color(for: themeColorName)
                        )
                    }
                    .buttonStyle(.plain)
                    
                    Button {
                        openCamera()
                    } label: {
                        UXScanOptionCard(
                            title: "Capture with Camera", // Consistent title
                            subtitle: "Take a new photo now",
                            icon: "camera.fill",
                            color: ThemeManager.shared.color(for: themeColorName)
                        )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 24)
                
                Spacer()
                
                // Footer Info
                HStack(spacing: 6) {
                    Image(systemName: "info.circle")
                    Text("Ensure good lighting for best results")
                }
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.bottom, 30)
            }
        }
        .navigationTitle("Scan Upload")
        .navigationBarTitleDisplayMode(.inline)

        // Navigate to enhance screen
        .navigationDestination(isPresented: $navigateToEnhance) {
            if let img = selectedImage {
                EnhancementSelectionView(image: img)
            }
        }
        // Photo Picker
        .photosPicker(isPresented: $showPhotosPicker, selection: $selectedPhotoItem, matching: .images)
        
        // Camera Sheet
        .sheet(isPresented: $showCamera, onDismiss: {
            if let img = selectedImage {
                if img.isMostlyGrayscale() {
                    navigateToEnhance = true
                } else {
                    selectedImage = nil
                    alertMsg = "This image can't be analyzed. Please capture a valid MRI, X-Ray, or Ultrasound scan."
                    showAlert = true
                }
            }
        }) {
            CameraPicker(image: $selectedImage)
                .ignoresSafeArea()
        }
        
        // Image Loading Logic (Picker)
        .onChange(of: selectedPhotoItem) { _, newItem in
            guard let newItem else { return }
            Task {
                do {
                    if let data = try await newItem.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        await MainActor.run {
                            let normalizedImg = uiImage.normalized()
                            if normalizedImg.isMostlyGrayscale() {
                                self.selectedImage = normalizedImg
                                self.navigateToEnhance = true
                            } else {
                                self.selectedPhotoItem = nil
                                self.alertMsg = "This image can't be analyzed. Please upload a valid MRI, X-Ray, or Ultrasound scan."
                                self.showAlert = true
                            }
                        }
                    }
                } catch {
                    print("Failed to load image: \(error.localizedDescription)")
                }
            }
        }
        .alert("Error", isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMsg)
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("DismissScanSheet"))) { _ in
            // Reset navigation stack and state
            navigateToEnhance = false
            selectedImage = nil
            showPhotosPicker = false
        }
    }
    
    // MARK: - Components
    struct UXScanOptionCard: View {
        let title: String
        let subtitle: String
        let icon: String
        let color: Color

        @Environment(\.colorScheme) private var colorScheme

        var body: some View {
            HStack(spacing: 20) {
                // ── Icon circle ────────────────
                ZStack {
                    Circle()
                        .fill(color.opacity(colorScheme == .dark ? 0.15 : 0.08))
                        .frame(width: 64, height: 64)

                    Image(systemName: icon)
                        .font(.system(size: 26, weight: .semibold))
                        .foregroundStyle(color)
                }

                // ── Text ────────────────────────────────────
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 19, weight: .bold))
                        .foregroundStyle(.primary)

                    Text(subtitle)
                        .font(.system(size: 14))
                        .foregroundStyle(Color.gray)
                }

                Spacer(minLength: 0)

                // ── Chevron ─────────────────────────────────
                Image(systemName: "chevron.right")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(Color.gray.opacity(0.5))
            }
            .padding(.vertical, 24)
            .padding(.horizontal, 24)
            .background(
                RoundedRectangle(cornerRadius: 28)
                    .fill(colorScheme == .dark ? Color(white: 0.11) : Color(.systemBackground))
            )
            .overlay(
                // Floating accent bar on the left edge
                HStack {
                    UnevenRoundedRectangle(
                        topLeadingRadius: 0,
                        bottomLeadingRadius: 0,
                        bottomTrailingRadius: 8,
                        topTrailingRadius: 8
                    )
                    .fill(color)
                    .shadow(color: color.opacity(0.5), radius: 6, x: 0, y: 0)
                    .frame(width: 4, height: 68)
                    Spacer()
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 28)
                    .stroke(
                        colorScheme == .dark
                            ? Color.white.opacity(0.05)
                            : Color.black.opacity(0.04),
                        lineWidth: 1
                    )
            )
            .shadow(
                color: colorScheme == .dark ? .clear : Color.black.opacity(0.05),
                radius: 10, x: 0, y: 5
            )
        }
    }

    private func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            // Reset image before opening camera to ensure we capture NEW image state
            selectedImage = nil
            showCamera = true
        } else {
            alertMsg = "Camera not available on this device."
            showAlert = true
        }
    }
}

// Camera Helper
struct CameraPicker: UIViewControllerRepresentable {
    @Environment(\.dismiss) private var dismiss
    @Binding var image: UIImage?

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.cameraCaptureMode = .photo
        picker.allowsEditing = false
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: CameraPicker
        init(_ parent: CameraPicker) { self.parent = parent }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let img = info[.originalImage] as? UIImage {
                parent.image = img.normalized()
            }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

// MARK: - Extensions
extension UIImage {
    /// Fixes rotation issues by removing EXIF orientation and converting image to `.up`
    func normalized() -> UIImage {
        if imageOrientation == .up { return self }

        let renderer = UIGraphicsImageRenderer(size: size)
        let normalizedImage = renderer.image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
        return normalizedImage
    }
    
    /// Checks if the image is mostly grayscale (e.g., MRI, X-Ray, Ultrasound)
    func isMostlyGrayscale() -> Bool {
        guard let cgImage = self.cgImage else { return false }
        
        let width = 50
        let height = 50
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        
        var rawData = [UInt8](repeating: 0, count: width * height * bytesPerPixel)
        
        guard let context = CGContext(data: &rawData,
                                      width: width,
                                      height: height,
                                      bitsPerComponent: 8,
                                      bytesPerRow: bytesPerRow,
                                      space: colorSpace,
                                      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue) else {
            return false
        }
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        var totalSaturation: CGFloat = 0
        let totalPixels = width * height
        
        for i in 0..<totalPixels {
            let offset = i * 4
            let r = CGFloat(rawData[offset]) / 255.0
            let g = CGFloat(rawData[offset + 1]) / 255.0
            let b = CGFloat(rawData[offset + 2]) / 255.0
            
            let maxColor = max(r, max(g, b))
            let minColor = min(r, min(g, b))
            let saturation = maxColor == 0 ? 0 : (maxColor - minColor) / maxColor
            
            totalSaturation += saturation
        }
        
        let avgSaturation = totalSaturation / CGFloat(totalPixels)
        
        // Strict threshold to reject colorful photos (selfies, nature, etc.)
        return avgSaturation < 0.15
    }
}
