import SwiftUI
import PhotosUI

// MARK: - UploadScanView
// A lightweight entry-point wrapper for the scan upload flow.
// Used when navigating to scan upload from contexts outside the Dashboard.
struct UploadScanView: View {

    @AppStorage("themeColor") private var themeColorName = "Blue"
    private var themeColor: Color { ThemeManager.shared.color(for: themeColorName) }

    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var selectedImage: UIImage? = nil
    @State private var navigateToEnhance = false
    @State private var showCamera = false
    @State private var showAlert = false
    @State private var alertMsg = ""

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                VStack(spacing: 28) {

                    // Header Icon
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [themeColor.opacity(0.18), themeColor.opacity(0.06)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 100, height: 100)

                        Image(systemName: "square.and.arrow.up.on.square.fill")
                            .font(.system(size: 42, weight: .semibold))
                            .foregroundStyle(themeColor)
                    }
                    .padding(.top, 40)

                    VStack(spacing: 8) {
                        Text("Upload a Scan")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundStyle(.primary)

                        Text("Choose a source to upload your medical scan for AI enhancement.")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 30)
                    }

                    // Upload Options
                    VStack(spacing: 16) {

                        // Gallery
                        PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                            uploadOptionRow(
                                title: "Import from Gallery",
                                subtitle: "Select an existing scan image",
                                icon: "photo.fill.on.rectangle.fill"
                            )
                        }
                        .buttonStyle(.plain)

                        // Camera
                        Button {
                            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                                showCamera = true
                            } else {
                                alertMsg = "Camera not available on this device."
                                showAlert = true
                            }
                        } label: {
                            uploadOptionRow(
                                title: "Capture with Camera",
                                subtitle: "Take a new photo now",
                                icon: "camera.fill"
                            )
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 24)

                    Spacer()

                    HStack(spacing: 6) {
                        Image(systemName: "lock.shield")
                            .font(.caption)
                        Text("All scans are processed securely on-device.")
                            .font(.caption)
                    }
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("Upload Scan")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(isPresented: $navigateToEnhance) {
                if let img = selectedImage {
                    EnhancementSelectionView(image: img)
                }
            }
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
            .onChange(of: selectedPhotoItem) { _, newItem in
                guard let newItem else { return }
                Task {
                    if let data = try? await newItem.loadTransferable(type: Data.self),
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
                }
            }
            .alert("Error", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMsg)
            }
        }
    }

    // MARK: - Upload Option Card
    private func uploadOptionRow(title: String, subtitle: String, icon: String) -> some View {
        HStack(spacing: 0) {

            LinearGradient(
                colors: [themeColor, themeColor.opacity(0.35)],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(width: 4)
            .clipShape(
                UnevenRoundedRectangle(
                    topLeadingRadius: 20,
                    bottomLeadingRadius: 20,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: 0
                )
            )

            HStack(spacing: 18) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    themeColor.opacity(colorScheme == .dark ? 0.32 : 0.16),
                                    themeColor.opacity(colorScheme == .dark ? 0.12 : 0.06)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 56, height: 56)

                    Image(systemName: icon)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundStyle(themeColor)
                }

                VStack(alignment: .leading, spacing: 5) {
                    Text(title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.primary)
                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }

                Spacer(minLength: 0)

                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(themeColor.opacity(0.5))
            }
            .padding(.vertical, 18)
            .padding(.leading, 18)
            .padding(.trailing, 16)
        }
        .background(
            colorScheme == .dark
                ? Color(white: 0.12)
                : Color(.systemBackground)
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    colorScheme == .dark
                        ? Color.white.opacity(0.08)
                        : Color.black.opacity(0.06),
                    lineWidth: 0.8
                )
        )
        .shadow(
            color: themeColor.opacity(colorScheme == .dark ? 0.14 : 0.10),
            radius: 10, x: 0, y: 5
        )
    }
}

#Preview {
    UploadScanView()
}
