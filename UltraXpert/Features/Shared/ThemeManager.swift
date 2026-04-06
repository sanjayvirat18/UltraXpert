import SwiftUI

class ThemeManager {
    static let shared = ThemeManager()
    
    func color(for name: String) -> Color {
        switch name {
        case "Blue": return .blue
        case "Green": return .green
        case "Orange": return .orange
        case "Purple": return .purple
        case "Pink": return .pink
        case "Red": return .red
        default: return .blue
        }
    }
}
