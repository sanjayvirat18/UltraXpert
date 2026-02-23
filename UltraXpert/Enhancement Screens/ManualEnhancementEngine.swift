import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins

final class ManualEnhancementEngine {

    private let context = CIContext()

    func enhance(
        image: UIImage,
        noiseReduction: Float,
        contrast: Float,
        sharpness: Float
    ) -> UIImage? {

        guard let inputCI = CIImage(image: image) else { return nil }

        var output = inputCI

        // 1) Noise Reduction
        let noiseFilter = CIFilter.noiseReduction()
        noiseFilter.inputImage = output
        noiseFilter.noiseLevel = noiseReduction          // 0...0.1 recommended
        noiseFilter.sharpness = 0.4
        if let noiseOut = noiseFilter.outputImage {
            output = noiseOut
        }

        // 2) Contrast
        let colorControls = CIFilter.colorControls()
        colorControls.inputImage = output
        colorControls.contrast = contrast                // 0.8...2.0
        colorControls.brightness = 0.0
        colorControls.saturation = 1.0
        if let contrastOut = colorControls.outputImage {
            output = contrastOut
        }

        // 3) Sharpen
        let sharpen = CIFilter.sharpenLuminance()
        sharpen.inputImage = output
        sharpen.sharpness = sharpness                    // 0...2
        if let sharpOut = sharpen.outputImage {
            output = sharpOut
        }

        guard let cg = context.createCGImage(output, from: output.extent) else { return nil }
        return UIImage(cgImage: cg)
    }
}
