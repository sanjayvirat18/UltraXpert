import SwiftUI

struct ResourceDetailView: View {
    let item: ResourceItem
    @Environment(\.dismiss) var dismiss
    @AppStorage("themeColor") private var themeColorName = "Blue"

    private var themeColor: Color {
        ThemeManager.shared.color(for: themeColorName)
    }

    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                HStack(spacing: 16) {
                    Circle()
                        .fill(themeColor.opacity(0.15))
                        .frame(width: 80, height: 80)
                        .overlay(
                            Image(systemName: item.icon)
                                .font(.system(size: 36))
                                .foregroundColor(themeColor)
                        )
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text(item.title)
                            .font(.title2)
                            .fontWeight(.bold)
                        Text(item.subtitle)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .padding(.top)
                
                Divider()
                
                // About Section
                VStack(alignment: .leading, spacing: 12) {
                    Text("About this Tool")
                        .font(.headline)
                    Text(item.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .lineSpacing(4)
                }
                
                // Instructions / Usage
                VStack(alignment: .leading, spacing: 12) {
                    Text("Clinical Usage")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        UsageRow(index: 1, text: "Enter patient data consistently for accurate results.")
                        UsageRow(index: 2, text: "Verify measurements against standard deviation charts.")
                        UsageRow(index: 3, text: "Use as a supportive tool, not a sole diagnostic method.")
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(16)
                
                Spacer(minLength: 30)
                
                // Action Button
                NavigationLink {
                    destinationView(for: item)
                } label: {
                    Text("Open Tool")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(themeColor)
                        .cornerRadius(16)
                }
            }
            .padding(20)
        }
        .navigationTitle(item.title)
        .navigationBarTitleDisplayMode(.inline)

        .background(Color(.systemBackground))
    }
    
    @ViewBuilder
    private func destinationView(for item: ResourceItem) -> some View {
        switch item.title {
        case "Gestational Age Calc":
            GestationalAgeCalcView()
        case "Organ Dimensions":
            OrganDimensionsView()
        case "eGFR Calculator":
            EGFRCalculatorView()
        case "Scan Protocols":
            ScanProtocolsView()
        case "TIRADS Calculator":
            TiradsCalculatorView()
        case "Liver Elastography":
            LiverElastographyView()
        default:
            Text("Tool coming soon")
        }
    }
}

struct UsageRow: View {
    let index: Int
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(Color.gray.opacity(0.2))
                .frame(width: 24, height: 24)
                .overlay(
                    Text("\(index)")
                        .font(.caption)
                        .fontWeight(.bold)
                )
            Text(text)
                .font(.subheadline)
                .foregroundColor(.primary)
        }
    }
}
