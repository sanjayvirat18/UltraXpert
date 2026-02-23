import SwiftData
import Foundation

@Model
class ScanRecord {

    var id: UUID
    var enhancedImageData: Data
    var enhancementType: String
    var createdAt: Date

    init(
        enhancedImageData: Data,
        enhancementType: String,
        createdAt: Date = Date()
    ) {
        self.id = UUID()
        self.enhancedImageData = enhancedImageData
        self.enhancementType = enhancementType
        self.createdAt = createdAt
    }
}
