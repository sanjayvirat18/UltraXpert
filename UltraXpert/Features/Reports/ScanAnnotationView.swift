import SwiftUI

struct ScanAnnotationView: View {
    @Environment(\.dismiss) var dismiss
    @State private var annotations: [CGPoint] = []
    
    // Mock image for annotation (would normally be passed in)
    let image: UIImage? = UIImage(systemName: "photo") 
    
    var body: some View {
        VStack {
            // Toolbar
            HStack {
                Button("Cancel") { dismiss() }
                Spacer()
                Text("Annotate Scan")
                    .font(.headline)
                Spacer()
                Button("Save") { dismiss() }
                    .fontWeight(.bold)
            }
            .padding()
            
            // Editor Area
            GeometryReader { geo in
                ZStack {
                    Color.black
                    
                    if let img = image {
                        Image(uiImage: img)
                            .resizable()
                            .scaledToFit()
                    } else {
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .padding(50)
                            .foregroundColor(.gray)
                    }
                    
                    // Drawing Layer
                    ForEach(0..<annotations.count, id: \.self) { i in
                        Circle()
                            .fill(Color.red)
                            .frame(width: 10, height: 10)
                            .position(annotations[i])
                    }
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onEnded { value in
                            annotations.append(value.location)
                        }
                )
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding()
            
            // Tools
            HStack(spacing: 30) {
                ToolButton(icon: "pencil.tip", label: "Draw", isSelected: true)
                ToolButton(icon: "textformat", label: "Text", isSelected: false)
                ToolButton(icon: "arrow.up.left", label: "Arrow", isSelected: false)
                ToolButton(icon: "eraser", label: "Erase", isSelected: false)
            }
            .padding(.bottom)
        }
    }
}

struct ToolButton: View {
    let icon: String
    let label: String
    let isSelected: Bool
    @AppStorage("themeColor") private var themeColorName = "Blue"
    private var themeColor: Color { ThemeManager.shared.color(for: themeColorName) }
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(isSelected ? themeColor : .primary)
                .frame(width: 50, height: 50)
                .background(isSelected ? themeColor.opacity(0.1) : Color(.secondarySystemBackground))
                .clipShape(Circle())
            
            Text(label)
                .font(.caption)
                .foregroundColor(isSelected ? themeColor : .secondary)
        }
    }
}

#Preview {
    ScanAnnotationView()
}
