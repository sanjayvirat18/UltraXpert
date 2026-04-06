import SwiftUI

struct ExportFormat: Identifiable {
    let id: String
    let name: String
    let description: String
    let icon: String
}

struct ExportOptionsView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("themeColor") private var themeColorName = "Blue"
    private var themeColor: Color { ThemeManager.shared.color(for: themeColorName) }
    
    @State private var selectedFormat = "PDF"
    @State private var includeImages = true
    @State private var includeNotes = true
    @State private var isExporting = false
    
    let formats = [
        ExportFormat(id: "PDF", name: "PDF Document", description: "Standard professional medical report with all details.", icon: "doc.richtext.fill"),
        ExportFormat(id: "DICOM", name: "DICOM File", description: "High-quality medical imaging format with metadata.", icon: "doc.append.fill"),
        ExportFormat(id: "JPEG", name: "JPEG Images", description: "Standalone enhanced images only, high resolution.", icon: "photo.fill"),
        ExportFormat(id: "CSV", name: "CSV Data", description: "Raw scan metrics and patient details in spreadsheet.", icon: "tablecells.fill")
    ]
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()
            
            VStack(spacing: 0) {
                // MARK: Custom Header
                headerView
                
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 28) {
                        
                        // MARK: Format Section
                        VStack(alignment: .leading, spacing: 14) {
                            sectionTitle("Choose Export Format")
                            
                            VStack(spacing: 12) {
                                ForEach(formats) { format in
                                    formatCard(format)
                                }
                            }
                        }
                        
                        // MARK: Preferences Section
                        VStack(alignment: .leading, spacing: 14) {
                            sectionTitle("Export Preferences")
                            
                            VStack(spacing: 0) {
                                preferenceToggle(icon: "photo.on.rectangle.angled", title: "Include High-Res Images", subtitle: "Embed AI-enhanced scans in the file", isOn: $includeImages)
                                Divider().padding(.leading, 54)
                                preferenceToggle(icon: "text.quote", title: "Include Doctor Notes", subtitle: "Add findings, impressions, and recommendations", isOn: $includeNotes)
                            }
                            .background(Color(.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                            .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.primary.opacity(0.05), lineWidth: 1))
                        }
                        
                        Spacer(minLength: 100)
                    }
                    .padding(20)
                }
                
                // MARK: Action Button
                actionButton
            }
        }
    }
    
    // MARK: - Components
    
    private var headerView: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.primary)
                    .frame(width: 34, height: 34)
                    .background(Color.primary.opacity(0.05))
                    .clipShape(Circle())
            }
            .padding(.leading, 20)
            
            Spacer()
            
            Text("Export Options")
                .font(.system(size: 18, weight: .bold))
            
            Spacer()
            
            // Empty placeholder for visual balance
            Circle()
                .fill(Color.clear)
                .frame(width: 34, height: 34)
                .padding(.trailing, 20)
        }
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
    }
    
    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 14, weight: .bold))
            .foregroundColor(.secondary)
            .textCase(.uppercase)
            .tracking(0.8)
            .padding(.leading, 4)
    }
    
    private func formatCard(_ format: ExportFormat) -> some View {
        let isSelected = selectedFormat == format.id
        return Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                selectedFormat = format.id
            }
        } label: {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSelected ? themeColor.opacity(0.15) : Color.primary.opacity(0.05))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: format.icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(isSelected ? themeColor : .secondary)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(format.name)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(isSelected ? themeColor : .primary)
                    
                    Text(format.description)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(themeColor)
                        .font(.title3)
                        .transition(.scale.combined(with: .opacity))
                } else {
                    Circle()
                        .stroke(Color.primary.opacity(0.1), lineWidth: 1.5)
                        .frame(width: 22, height: 22)
                }
            }
            .padding(14)
            .background(isSelected ? Color(.systemBackground) : Color.primary.opacity(0.02))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? themeColor.opacity(0.3) : Color.clear, lineWidth: 2)
            )
            .shadow(color: isSelected ? themeColor.opacity(0.12) : Color.clear, radius: 10, x: 0, y: 5)
        }
        .buttonStyle(.plain)
    }
    
    private func preferenceToggle(icon: String, title: String, subtitle: String, isOn: Binding<Bool>) -> some View {
        HStack(spacing: 18) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(themeColor)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Toggle("", isOn: isOn)
                .toggleStyle(SwitchToggleStyle(tint: themeColor))
                .labelsHidden()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
    
    private var actionButton: some View {
        VStack {
            Button {
                startExport()
            } label: {
                ZStack {
                    if isExporting {
                        ProgressView().tint(.white)
                    } else {
                        HStack(spacing: 10) {
                            Image(systemName: "arrow.up.doc.fill")
                            Text("Export Report")
                        }
                        .font(.system(size: 17, weight: .bold))
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    LinearGradient(
                        colors: [themeColor, themeColor.opacity(0.85)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .shadow(color: themeColor.opacity(0.3), radius: 10, x: 0, y: 6)
            }
            .disabled(isExporting)
            .padding(.horizontal, 20)
            .padding(.bottom, 34)
            .padding(.top, 16)
        }
        .background(
            Color(.systemBackground)
                .shadow(color: Color.black.opacity(0.05), radius: 15, x: 0, y: -10)
        )
    }
    
    func startExport() {
        withAnimation { isExporting = true }
        // Simulate export delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isExporting = false
            dismiss()
        }
    }
}

#Preview {
    ExportOptionsView()
}
