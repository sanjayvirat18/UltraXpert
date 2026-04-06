import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct SmartEnhancementView: View {
    let originalImage: UIImage
    @State private var enhancedImage: UIImage?
    @State private var enhancedResponse: EnhancementResponse?
    @State private var processingStep = 0
    @State private var navigateToResult = false
    @State private var isFloating = false
    @AppStorage("themeColor") private var themeColorName = "Blue"
    private var themeColor: Color { ThemeManager.shared.color(for: themeColorName) }
    
    // Core Image Context
    private let context = CIContext(options: [.useSoftwareRenderer: false])

    var body: some View {
        VStack(spacing: 30) {
            
            // Header
            VStack(spacing: 8) {
                Text(processingStep < 4 ? "AI Smart Enhancement" : "Enhancement Complete")
                    .font(.title2)
                    .fontWeight(.bold)
                    .transition(.opacity)
                Text(processingStep < 4 ? "Optimizing your scan automatically..." : "Your scan has been optimized successfully.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .transition(.opacity)
            }
            .padding(.top, 20)
            .offset(y: isFloating ? -10 : 0)
            .animation(
                isFloating 
                    ? Animation.easeInOut(duration: 1.2).repeatForever(autoreverses: true) 
                    : Animation.easeOut(duration: 0.5),
                value: isFloating
            )
            .animation(.easeInOut, value: processingStep)
            
            // Image Preview with Scanning Effect (Added ID to force update when done)
            ZStack {
                Color.black.opacity(0.8)
                
                Image(uiImage: enhancedImage ?? originalImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 300)
            }
            .overlay(
                // Scanning Line Animation - Absolutely removed at step 4
                Group {
                    if processingStep > 0 && processingStep < 4 {
                        ScanningLine()
                    }
                }
            )
            .frame(height: 300)
            .cornerRadius(16)
            .shadow(radius: 8)
            .offset(y: isFloating ? -15 : 0)
            .animation(
                isFloating 
                    ? Animation.easeInOut(duration: 1.2).repeatForever(autoreverses: true) 
                    : Animation.easeOut(duration: 0.5),
                value: isFloating
            )
            .padding(.horizontal)
            
            // Progress Steps
            VStack(alignment: .leading, spacing: 20) {
                ProcessingStepRow(title: "Noise Reduction", status: stepStatus(for: 1))
                ProcessingStepRow(title: "Contrast Enhancement", status: stepStatus(for: 2))
                ProcessingStepRow(title: "Edge Sharpening", status: stepStatus(for: 3))
            }
            .padding(.horizontal, 40)
            .id("progress-steps-\(processingStep)")
            
            Spacer()
            
            // Button to Continue (appears when done)
            if processingStep == 4 {
                Button {
                    navigateToResult = true
                } label: {
                    Text("View Enhanced Result")
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
                        .cornerRadius(14)
                        .shadow(color: themeColor.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 30)
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            isFloating = true
            startSmartEnhancement()
        }
        .onChange(of: processingStep) { newValue in
            if newValue == 4 {
                isFloating = false
            }
        }
        .navigationDestination(isPresented: $navigateToResult) {
            if let result = enhancedImage {
                EnhancedResultView(image: result, originalImage: originalImage, response: enhancedResponse)
            }
        }
    }
    
    // MARK: - Logic
    
    private func stepStatus(for step: Int) -> ProcessingStatus {
        if processingStep < step { return .pending }
        if processingStep == step { return .active }
        return .completed
    }
    
    private func startSmartEnhancement() {
        guard processingStep == 0 else { return }
        
        Task {
            do {
                // 1. Noise Reduction Step - Start Upload
                withAnimation { processingStep = 1 }
                let uploadedUrl = try await ScanService().uploadScan(image: originalImage)
                
                // 2. Contrast Enhancement Step - Process AI
                withAnimation { processingStep = 2 }
                let response = try await ScanService().enhanceScan(patientId: "demo_patient", imageUrl: uploadedUrl)
                self.enhancedResponse = response
                
                guard let finalUrlStr = response.enhanced_image_url,
                      let url = URL(string: AppConfig.backendURL + finalUrlStr) else {
                    throw URLError(.badURL)
                }
                
                // 3. Edge Sharpening Step - Download Result
                withAnimation { processingStep = 3 }
                let (data, _) = try await URLSession.shared.data(from: url)
                if let finalImg = UIImage(data: data) {
                    // Update image and processing state without animation to stop the 'moving' feel
                    enhancedImage = finalImg
                    processingStep = 4 
                } else {
                    throw URLError(.cannotDecodeRawData)
                }
            } catch {
                print("Failed calling AI Backend: \(error.localizedDescription). Falling back to local.")
                await fallbackLocalEnhancement()
            }
        }
    }
    
    private func fallbackLocalEnhancement() async {
        // Wait a moment before starting
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        // 1. Noise Reduction
        withAnimation { processingStep = 1 }
        let noiseReduced = await applyFilter(to: originalImage, type: .noiseReduction)
        enhancedImage = noiseReduced
        try? await Task.sleep(nanoseconds: 1_200_000_000)
        
        // 2. Contrast
        withAnimation { processingStep = 2 }
        let contrastEnhanced = await applyFilter(to: noiseReduced, type: .contrast)
        enhancedImage = contrastEnhanced
        try? await Task.sleep(nanoseconds: 1_200_000_000)
        
        // 3. Edge Sharpening
        withAnimation { processingStep = 3 }
        let sharpened = await applyFilter(to: contrastEnhanced, type: .sharpen)
        // Stop animation here as well
        enhancedImage = sharpened
        try? await Task.sleep(nanoseconds: 1_200_000_000)
        
        // Done
        processingStep = 4
    }
    
    enum FilterType {
        case noiseReduction
        case contrast
        case sharpen
    }
    
    private func applyFilter(to input: UIImage, type: FilterType) async -> UIImage {
        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                guard let ciImage = CIImage(image: input) else {
                    continuation.resume(returning: input)
                    return
                }
                
                var outputImage: CIImage?
                
                switch type {
                case .noiseReduction:
                    let filter = CIFilter.noiseReduction()
                    filter.inputImage = ciImage
                    filter.noiseLevel = 0.02
                    filter.sharpness = 0.4
                    outputImage = filter.outputImage
                    
                case .contrast:
                    let filter = CIFilter.colorControls()
                    filter.inputImage = ciImage
                    filter.contrast = 1.15 // Boost contrast
                    filter.saturation = 1.05
                    outputImage = filter.outputImage
                    
                case .sharpen:
                    let filter = CIFilter.unsharpMask()
                    filter.inputImage = ciImage
                    filter.radius = 3.0
                    filter.intensity = 5.0 // Maximized to match extremely prominent backend structural edge sharpening
                    outputImage = filter.outputImage
                }
                
                if let output = outputImage,
                   let cgImage = self.context.createCGImage(output, from: output.extent) {
                    let result = UIImage(cgImage: cgImage, scale: input.scale, orientation: input.imageOrientation)
                    continuation.resume(returning: result)
                } else {
                    continuation.resume(returning: input)
                }
            }
        }
    }
}

// MARK: - Components

enum ProcessingStatus {
    case pending, active, completed
    
    var color: Color {
        switch self {
        case .pending: return .secondary.opacity(0.3)
        case .active: return ThemeManager.shared.color(for: (UserDefaults.standard.string(forKey: "themeColor") ?? "Blue"))
        case .completed: return .green
        }
    }
    
    var icon: String {
        switch self {
        case .pending: return "circle"
        case .active: return "gearshape.fill" // Rotating
        case .completed: return "checkmark.circle.fill"
        }
    }
}

struct ProcessingStepRow: View {
    let title: String
    let status: ProcessingStatus
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                if status == .active {
                    ProgressView()
                        .tint(ThemeManager.shared.color(for: (UserDefaults.standard.string(forKey: "themeColor") ?? "Blue")))
                } else {
                    Image(systemName: status.icon)
                        .font(.title2)
                        .foregroundColor(status.color)
                }
            }
            .frame(width: 30)
            
            Text(title)
                .font(.body)
                .fontWeight(status == .active ? .bold : .medium)
                .foregroundColor(status == .pending ? .secondary : .primary)
            
            Spacer()
        }
    }
}

struct ScanningLine: View {
    @State private var offset: CGFloat = -150
    
    var body: some View {
        Rectangle()
            .fill(
                LinearGradient(
                    colors: [.clear, ThemeManager.shared.color(for: (UserDefaults.standard.string(forKey: "themeColor") ?? "Blue")).opacity(0.8), .clear],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(height: 4)
            .offset(y: offset)
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    offset = 150
                }
            }
    }
}

#Preview {
    NavigationStack {
        SmartEnhancementView(originalImage: UIImage(systemName: "photo")!)
    }
}
