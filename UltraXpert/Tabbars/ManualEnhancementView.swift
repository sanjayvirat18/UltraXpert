import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct ManualEnhancementView: View {
    let originalImage: UIImage
    @State private var noiseReduction: Double = 0.0
    @State private var contrastEnhancement: Double = 0.0
    @State private var edgeSharpening: Double = 0.0
    @AppStorage("themeColor") private var themeColorName = "Blue"
    private var themeColor: Color { ThemeManager.shared.color(for: themeColorName) }
    
    @State private var displayedImage: UIImage?
    @State private var navigateToResult = false
    @State private var isProcessing = false
    
    // Core Image Context (reused for performance)
    private let context = CIContext(options: [.useSoftwareRenderer: false])
    
    // Debounce task
    @State private var processingTask: Task<Void, Never>?
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                // Image Preview Area
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.black)
                        .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 4)
                    
                    if let displayedImage {
                        Image(uiImage: displayedImage)
                            .resizable()
                            .scaledToFit()
                            .padding(4)
                            .clipShape(RoundedRectangle(cornerRadius: 24))
                    } else {
                        ProgressView()
                            .tint(.white)
                    }
                    
                    VStack {
                        Spacer()
                        HStack {
                            HStack(spacing: 6) {
                                Image(systemName: "tv")
                                    .font(.caption2)
                                    .foregroundColor(.white)
                                Text("LIVE PREVIEW")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(.ultraThinMaterial)
                            .environment(\.colorScheme, .dark)
                            .cornerRadius(20)
                            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.15), lineWidth: 1))
                            .padding(16)
                            
                            Spacer()
                        }
                    }
                    
                    if isProcessing {
                        VStack {
                            Spacer()
                            HStack(spacing: 8) {
                                ProgressView()
                                    .tint(.white)
                                Text("Enhancing...")
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(.ultraThinMaterial)
                            .environment(\.colorScheme, .dark)
                            .cornerRadius(20)
                            .padding(.bottom, 16)
                        }
                    }
                }
                .frame(height: 360)
                .padding(.horizontal, 16)
                .padding(.top, 16)
                
                ScrollView {
                    VStack(spacing: 24) {
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Adjust Enhancements")
                                .font(.title3)
                                .fontWeight(.black)
                                .foregroundColor(.primary)
                            Text("Fine-tune your scan for better diagnostic clarity")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        .padding(.top, 24)
                        
                        // Professional Sliders
                        VStack(spacing: 20) {
                            UXEnhancementSlider(
                                title: "Noise Reduction",
                                value: $noiseReduction,
                                range: 0...100,
                                icon: "sparkles",
                                color: .purple
                            )
                            
                            UXEnhancementSlider(
                                title: "Contrast",
                                value: $contrastEnhancement,
                                range: 0...100,
                                icon: "circle.righthalf.filled",
                                color: .orange
                            )
                            
                            UXEnhancementSlider(
                                title: "Sharpening",
                                value: $edgeSharpening,
                                range: 0...100,
                                icon: "scissors",
                                color: .blue
                            )
                        }
                        .padding(.horizontal)

                        Spacer(minLength: 20)
                        
                        // Apply Button
                        Button {
                            navigateToResult = true
                        } label: {
                            Text("Apply Enhancement")
                                .font(.headline)
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(
                                        colors: [themeColor, themeColor.opacity(0.75)],
                                        startPoint: .topLeading, endPoint: .bottomTrailing
                                    )
                                )
                                .foregroundColor(.white)
                                .cornerRadius(16)
                                .shadow(color: themeColor.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 30)
                    }
                }
            }
        }
        .navigationTitle("Manual Enhancement")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $navigateToResult) {
            if let result = displayedImage {
                EnhancedResultView(image: result, originalImage: originalImage)
            }
        }
        .onAppear {
            displayedImage = originalImage
            scheduleProcessing()
        }
        .onChange(of: noiseReduction) { _, _ in scheduleProcessing() }
        .onChange(of: contrastEnhancement) { _, _ in scheduleProcessing() }
        .onChange(of: edgeSharpening) { _, _ in scheduleProcessing() }
    }
    
    // MARK: - Processing Logic
    
    private func scheduleProcessing() {
        // Cancel previous task to debounce
        processingTask?.cancel()
        
        isProcessing = true
        
        processingTask = Task {
            // Wait slightly to gather rapid slider changes
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1s debounce
            
            if Task.isCancelled { return }
            
            let processed = await processImage(
                input: originalImage,
                noise: noiseReduction / 100.0,
                contrast: 1.0 + (contrastEnhancement / 166.0), // Cap at 1.6 for more "punch"
                sharpness: (edgeSharpening / 100.0) * 2.0 // Cap at 2.0
            )
            
            if !Task.isCancelled {
                await MainActor.run {
                    self.displayedImage = processed
                    self.isProcessing = false
                }
            }
        }
    }
    
    private func processImage(input: UIImage, noise: Double, contrast: Double, sharpness: Double) async -> UIImage {
        return await withCheckedContinuation { continuation in
            // Move complex CI operations to background queue
            DispatchQueue.global(qos: .userInitiated).async {
                guard let ciImage = CIImage(image: input) else {
                    continuation.resume(returning: input)
                    return
                }
                
                var outputImage = ciImage
                
                // 1. Professional Noise Reduction (Balanced)
                if noise > 0 {
                    let noiseFilter = CIFilter.noiseReduction()
                    noiseFilter.inputImage = outputImage
                    noiseFilter.noiseLevel = Float(noise * 0.05) // Reduced to preserve more detail
                    noiseFilter.sharpness = 0.5
                    if let filtered = noiseFilter.outputImage {
                        outputImage = filtered
                    }
                }
                
                // 2. Exposure & Contrast (Diagnostic Clarity)
                let controls = CIFilter.colorControls()
                controls.inputImage = outputImage
                // Use a subtle gamma-like adjustment via brightness
                controls.brightness = Float((contrast - 1.0) * -0.15) 
                controls.contrast = Float(contrast) 
                controls.saturation = 1.0 
                if let out = controls.outputImage {
                    outputImage = out
                }
                
                // 3. High-Radius Sharpening (Clarity/Local Contrast)
                if sharpness > 0 {
                    let unsharp = CIFilter.unsharpMask()
                    unsharp.inputImage = outputImage
                    unsharp.radius = 8.0 // Larger radius for structural clarity, not just edges
                    unsharp.intensity = Float(sharpness)
                    if let out = unsharp.outputImage {
                        outputImage = out
                    }
                }
                
                // Render
                if let cgImage = self.context.createCGImage(outputImage, from: outputImage.extent) {
                    let result = UIImage(
                        cgImage: cgImage,
                        scale: input.scale,
                        orientation: input.imageOrientation
                    )
                    continuation.resume(returning: result)
                } else {
                    continuation.resume(returning: input)
                }
            }
        }
    }
}

// MARK: - UX Enhancement Slider
struct UXEnhancementSlider: View {
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label {
                    Text(title)
                        .font(.body)
                        .fontWeight(.medium)
                } icon: {
                    Image(systemName: icon)
                        .foregroundColor(color)
                }
                
                Spacer()
                
                // Display percentage or value
                let percentage = Int(value)
                Text("\(percentage)%")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(color)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(color.opacity(0.1))
                    .cornerRadius(8)
            }
            
            Slider(value: $value, in: range)
                .tint(color)
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    NavigationStack {
        ManualEnhancementView(originalImage: UIImage(systemName: "photo")!)
    }
    .environmentObject(AnalyticsStore())
}
