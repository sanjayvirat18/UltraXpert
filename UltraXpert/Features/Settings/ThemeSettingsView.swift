import SwiftUI

struct ThemeSettingsView: View {
    @AppStorage("themeColor") private var themeColorName = "Blue"
    @AppStorage("fontScale") private var fontScale = 1.0
    
    let colors = ["Blue", "Green", "Orange", "Purple", "Pink", "Red"]
    
    var body: some View {
        Form {
            Section(header: Text("App Color")) {
                Picker("Accent Color", selection: $themeColorName) {
                    ForEach(colors, id: \.self) { colorName in
                        HStack {
                            Circle()
                                .fill(ThemeManager.shared.color(for: colorName))
                                .frame(width: 20, height: 20)
                            Text(colorName)
                        }
                        .tag(colorName)
                    }
                }
                .pickerStyle(.inline) // or .navigationLink
            }
            
            Section(header: Text("Typography")) {
                VStack(alignment: .leading) {
                    Text("Font Size Scale: \(String(format: "%.1f", fontScale))x")
                    Slider(value: $fontScale, in: 0.8...1.4, step: 0.1)
                }
                .padding(.vertical, 8)
                
                Text("Sample Text Preview")
                    .font(.body)
                    .scaleEffect(fontScale)
                    .frame(height: 40)
            }
            
            Section {
                Button("Reset to Defaults") {
                    themeColorName = "Blue"
                    fontScale = 1.0
                }
                .foregroundColor(.red)
            }
        }
        .navigationTitle("Appearance")
    }
}

#Preview {
    NavigationStack {
        ThemeSettingsView()
    }
}
