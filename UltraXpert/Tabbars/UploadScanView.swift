import SwiftUI
import PhotosUI
import UIKit

struct UploadScanView: View {

    @State private var showSourceSheet = false
    @State private var showCamera = false

    @State private var showPhotosPicker = false
    @State private var selectedPhotoItem: PhotosPickerItem? = nil

    @State private var selectedImage: UIImage? = nil
    @State private var goNext = false

    @State private var showAlert = false
    @State private var alertMsg = ""

    var body: some View {

        NavigationStack {

            VStack(spacing: 18) {

                VStack(alignment: .leading, spacing: 6) {
                    Text("Upload Scan")
                        .font(.title2).bold()

                    Text("Select scan source")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                ZStack {
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color(.systemGray6))
                        .frame(height: 220)

                    if let img = selectedImage {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 220)
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                    } else {
                        VStack(spacing: 10) {
                            Image(systemName: "square.and.arrow.up")
                                .font(.system(size: 38, weight: .semibold))
                                .foregroundStyle(.blue)

                            Text("No scan selected")
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Button {
                    showSourceSheet = true
                } label: {
                    Text("Choose Scan")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.blue)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }

                Button {
                    if selectedImage != nil {
                        goNext = true
                    }
                } label: {
                    Text("Continue")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(selectedImage == nil ? Color(.systemGray4) : Color.black)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .disabled(selectedImage == nil)

                Spacer()
            }
            .padding()

            .navigationDestination(isPresented: $goNext) {
                ScanPreviewView(scanImage: selectedImage ?? UIImage())
            }

            .sheet(isPresented: $showSourceSheet) {
                ScanSourceSheet(
                    onPhotos: {
                        showSourceSheet = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                            showPhotosPicker = true
                        }
                    },
                    onCamera: {
                        showSourceSheet = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                            openCamera()
                        }
                    }
                )
                .presentationDetents([.height(220)])
            }

            .photosPicker(
                isPresented: $showPhotosPicker,
                selection: $selectedPhotoItem,
                matching: .images
            )

            .sheet(isPresented: $showCamera) {
                CameraPicker(image: $selectedImage)
                    .ignoresSafeArea()
            }

            .onChange(of: selectedPhotoItem) { _, newItem in
                guard let newItem else { return }

                Task {
                    do {
                        if let data = try await newItem.loadTransferable(type: Data.self),
                           let uiImage = UIImage(data: data) {

                            // ✅ FIX ROTATION
                            let fixed = uiImage.normalized()

                            await MainActor.run {
                                selectedImage = fixed
                            }
                        } else {
                            await MainActor.run {
                                alertMsg = "Invalid image selected."
                                showAlert = true
                            }
                        }
                    } catch {
                        await MainActor.run {
                            alertMsg = "Unable to load image."
                            showAlert = true
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

    private func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            showCamera = true
        } else {
            alertMsg = "Camera not available. Please test on a real iPhone device."
            showAlert = true
        }
    }
}
