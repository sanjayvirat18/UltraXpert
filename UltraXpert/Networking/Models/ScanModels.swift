import Foundation
import UIKit

// MARK: - Scan Models
struct ScanUploadResponse: Decodable {
    let original_image_url: String
}

struct EnhancementCreateRequest: Encodable {
    let patient_id: String
    let original_image_url: String
}

struct EnhancementResponse: Decodable {
    let id: String
    let patient_id: String
    let original_image_url: String
    let enhanced_image_url: String?
    let improvement_percentage: String?
    let snr_before: String?
    let snr_after: String?
    let edge_sharpness_before: String?
    let edge_sharpness_after: String?
    let contrast_clarity_before: String?
    let contrast_clarity_after: String?
    let noise_reduction_efficiency: Double?
    let structure_recovery: Double?
    let detail_preservation: Double?
}
