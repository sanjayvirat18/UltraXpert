import SwiftUI
struct ProfessionalShareView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("themeColor") private var themeColorName = "Blue"
    private var themeColor: Color { ThemeManager.shared.color(for: themeColorName) }
    
    let report: PatientReport
    
    @State private var selectedFormat = "PDF"
    @State private var isPreparing = false
    @State private var showSystemShare = false
    
    @State private var shareURL: URL?
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()
            
            VStack(spacing: 0) {
                // MARK: Header
                headerView
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        
                        // MARK: Report Preview Card
                        reportPreviewCard
                        
                        // MARK: Format Selection
                        VStack(alignment: .leading, spacing: 12) {
                            sectionTitle("Select Sharing Format")
                            
                            HStack(spacing: 12) {
                                formatButton(title: "PDF Document", icon: "doc.richtext.fill", type: "PDF")
                                formatButton(title: "Image (JPEG)", icon: "photo.fill", type: "IMAGE")
                            }
                        }
                        
                        // MARK: Pro Tip
                        HStack(spacing: 12) {
                            Image(systemName: "lightbulb.fill")
                                .foregroundColor(.yellow)
                            Text("PDF format is recommended for professional medical record sharing.")
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color.yellow.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.top, 8)
                        
                        Spacer(minLength: 40)
                    }
                    .padding(20)
                }
                
                // MARK: Primary Action
                shareButton
            }
        }
        .sheet(isPresented: $showSystemShare) {
             if let url = shareURL {
                 ShareSheet(items: [url])
             } else {
                 ShareSheet(items: [exportText()])
             }
        }

    }
    
    // MARK: - Components
    
    private var headerView: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "multiply")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.primary)
                    .frame(width: 34, height: 34)
                    .background(Color.primary.opacity(0.05))
                    .clipShape(Circle())
            }
            .padding(.leading, 20)
            
            Spacer()
            
            Text("Share Report")
                .font(.system(size: 18, weight: .bold))
            
            Spacer()
            
            // Visual balance
            Circle()
                .fill(Color.clear)
                .frame(width: 34, height: 34)
                .padding(.trailing, 20)
        }
        .padding(.vertical, 16)
        .background(Color(.systemBackground))
    }
    
    private var reportPreviewCard: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(themeColor.opacity(0.1))
                    .frame(width: 70, height: 70)
                
                if let image = report.image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 70, height: 70)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    Image(systemName: "doc.text.fill")
                        .font(.system(size: 28))
                        .foregroundColor(themeColor)
                }
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(report.patientName)
                    .font(.system(size: 17, weight: .bold))
                Text("ID: \(report.patientID)")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                Text(report.date)
                    .font(.system(size: 13))
                    .foregroundColor(themeColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(themeColor.opacity(0.1))
                    .clipShape(Capsule())
            }
            
            Spacer()
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color.black.opacity(0.04), radius: 12, x: 0, y: 6)
    }
    
    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 14, weight: .bold))
            .foregroundColor(.secondary)
            .textCase(.uppercase)
            .tracking(0.5)
            .padding(.leading, 4)
    }
    
    private func formatButton(title: String, icon: String, type: String) -> some View {
        let isSelected = selectedFormat == type
        return Button {
            withAnimation(.spring(response: 0.3)) { selectedFormat = type }
        } label: {
            VStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(isSelected ? .white : themeColor)
                
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(isSelected ? themeColor : Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.clear : Color.primary.opacity(0.05), lineWidth: 1)
            )
            .shadow(color: isSelected ? themeColor.opacity(0.2) : Color.clear, radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
    
    private var shareButton: some View {
        VStack {
            Button {
                triggerShare()
            } label: {
                ZStack {
                    if isPreparing {
                        ProgressView().tint(.white)
                    } else {
                        HStack(spacing: 10) {
                            Image(systemName: selectedFormat == "PDF" ? "doc.fill" : "photo.fill")
                            Text("Share \(selectedFormat)")
                        }
                        .font(.system(size: 17, weight: .bold))
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(themeColor)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .shadow(color: themeColor.opacity(0.3), radius: 10, x: 0, y: 6)
            }
            .disabled(isPreparing)
            .padding(.horizontal, 20)
            .padding(.bottom, 34)
            .padding(.top, 16)
        }
        .background(
            Color(.systemBackground)
                .shadow(color: Color.black.opacity(0.05), radius: 15, x: 0, y: -10)
        )
    }
    
    private func triggerShare() {
        withAnimation { isPreparing = true }
        
        DispatchQueue.global(qos: .userInitiated).async {
            let url: URL?
            
            if selectedFormat == "IMAGE" {
                url = saveImageToTemp()
            } else {
                url = generatePDF()
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                self.shareURL = url
                self.isPreparing = false
                self.showSystemShare = true
            }
        }
    }
    
    private func saveImageToTemp() -> URL? {
        guard let image = report.image,
              let data = image.jpegData(compressionQuality: 0.9) else { return nil }
              
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(report.patientName)_Scan.jpg")
        
        do {
            try data.write(to: tempURL)
            return tempURL
        } catch {
            return nil
        }
    }
    
    private func generatePDF() -> URL? {
        let pdfMetaData = [
            kCGPDFContextCreator: "UltraXpert",
            kCGPDFContextAuthor: "UltraXpert AI",
            kCGPDFContextTitle: "Medical Report - \(report.patientName)"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageWidth = 8.27 * 72.0
        let pageHeight = 11.69 * 72.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        let margin: CGFloat = 50.0
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        // Theme Colors
        let primaryColor = UIColor(themeColor)
        let lightBgColor = UIColor(white: 0.96, alpha: 1.0)
        
        let data = renderer.pdfData { (context) in
            context.beginPage()
            
            var currentY: CGFloat = margin
            let contentWidth = pageWidth - (margin * 2)
            
            // --- Header Background ---
            let headerRect = CGRect(x: 0, y: 0, width: pageWidth, height: 120)
            context.cgContext.setFillColor(primaryColor.withAlphaComponent(0.05).cgColor)
            context.cgContext.fill(headerRect)
            
            // --- Title Row ---
            let headerTitleAttr: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 26, weight: .heavy),
                .foregroundColor: primaryColor
            ]
            
            let dateAttr: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12, weight: .medium),
                .foregroundColor: UIColor.darkGray
            ]
            
            "UltraXpert".draw(at: CGPoint(x: margin, y: margin), withAttributes: headerTitleAttr)
            
            let dateStr = "Report Generated: \(report.date)"
            let dateSize = dateStr.size(withAttributes: dateAttr)
            dateStr.draw(at: CGPoint(x: pageWidth - margin - dateSize.width, y: margin + 10), withAttributes: dateAttr)
            
            currentY += 45
            
            // --- Patient Title ---
            let patientNameAttr: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 18, weight: .bold),
                .foregroundColor: UIColor.black
            ]
            "Patient: \(report.patientName) (\(report.patientID))".draw(at: CGPoint(x: margin, y: currentY), withAttributes: patientNameAttr)
            currentY += 45
            
            // --- Image Section (If Available) ---
            if let image = report.image {
                let imgWidth: CGFloat = 300
                // Maintain aspect ratio roughly
                let aspectRatio = image.size.height / image.size.width
                let imgHeight = min(imgWidth * aspectRatio, 210) // Cap height
                let imgX = (pageWidth - imgWidth) / 2
                
                // Image Background/Border
                let imgRect = CGRect(x: imgX, y: currentY, width: imgWidth, height: imgHeight)
                let clipPath = UIBezierPath(roundedRect: imgRect, cornerRadius: 12)
                context.cgContext.saveGState()
                clipPath.addClip()
                
                // We want to fill the rect, so we need to calculate drawing rect
                image.draw(in: imgRect)
                context.cgContext.restoreGState()
                
                // Border
                primaryColor.withAlphaComponent(0.3).setStroke()
                clipPath.lineWidth = 1
                clipPath.stroke()
                
                currentY += imgHeight + 20
            } else {
                currentY += 20 // Extra spacing if no image
            }
            
            // Text Attributes
            let sectionHeaderAttr: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 15, weight: .bold),
                .foregroundColor: primaryColor
            ]
            
            let labelAttr: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 11, weight: .semibold),
                .foregroundColor: UIColor.gray
            ]
            
            let boxValueAttr: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 13, weight: .semibold),
                .foregroundColor: UIColor.black
            ]
            
            // --- Helper Box Drawing ---
            func drawInfoBox(items: [(String, String)], x: CGFloat, y: CGFloat, width: CGFloat) -> CGFloat {
                let boxRect = CGRect(x: x, y: y, width: width, height: CGFloat(items.count * 25 + 15))
                let roundedRect = UIBezierPath(roundedRect: boxRect, cornerRadius: 8)
                lightBgColor.setFill()
                roundedRect.fill()
                
                for (index, item) in items.enumerated() {
                    let itemY = y + 12 + CGFloat(index * 25)
                    item.0.draw(at: CGPoint(x: x + 15, y: itemY), withAttributes: labelAttr)
                    
                    let valSize = item.1.size(withAttributes: boxValueAttr)
                    item.1.draw(at: CGPoint(x: x + width - 15 - valSize.width, y: itemY), withAttributes: boxValueAttr)
                }
                
                return boxRect.height
            }
            
            // --- Split Layout: Metrics and Info ---
            let halfWidth = (contentWidth - 15) / 2
            
            let metricsItems = [
                ("Scan Type", report.scanType),
                ("Modality", report.modality),
                ("Body Part", report.bodyPart)
            ]
            
            let infoItems = [
                ("Doctor", report.referringDoctor),
                ("Gender / Age", "\(report.gender) / \(report.age)"),
                ("Status", report.status)
            ]
            
            // Check if we need a new page for boxes
            if currentY + 100 > pageHeight - margin {
                context.beginPage()
                currentY = margin
            }
            
            let boxHeight = drawInfoBox(items: metricsItems, x: margin, y: currentY, width: halfWidth)
            _ = drawInfoBox(items: infoItems, x: margin + halfWidth + 15, y: currentY, width: halfWidth)
            
            currentY += boxHeight + 20
            
            // --- Text Sections (Findings, Impression, Recommendations) ---
            func drawTextSection(title: String, text: String, y: inout CGFloat) {
                // Check if we need a new page
                if y + 80 > pageHeight - margin { // Approximate check
                    context.beginPage()
                    y = margin
                }
                
                " \(title) ".draw(at: CGPoint(x: margin, y: y), withAttributes: sectionHeaderAttr)
                
                // Section Line
                let linePath = UIBezierPath()
                linePath.move(to: CGPoint(x: margin, y: y + 25))
                linePath.addLine(to: CGPoint(x: margin + contentWidth, y: y + 25))
                UIColor.lightGray.withAlphaComponent(0.3).setStroke()
                linePath.lineWidth = 1
                linePath.stroke()
                
                // Determine bounding rect for text to measure height
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.lineSpacing = 4
                
                let textAttr: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 13, weight: .regular),
                    .foregroundColor: UIColor.darkGray,
                    .paragraphStyle: paragraphStyle
                ]
                
                let nsText = NSString(string: text)
                let textRectToMeasure = CGSize(width: contentWidth, height: .greatestFiniteMagnitude)
                let boundingRect = nsText.boundingRect(with: textRectToMeasure, options: .usesLineFragmentOrigin, attributes: textAttr, context: nil)
                
                // Actually draw it
                let drawRect = CGRect(x: margin, y: y + 35, width: contentWidth, height: boundingRect.height + 20)
                nsText.draw(in: drawRect, withAttributes: textAttr)
                
                y += boundingRect.height + 45
            }
            
            drawTextSection(title: "FINDINGS", text: report.findings, y: &currentY)
            drawTextSection(title: "IMPRESSION", text: report.impression, y: &currentY)
            drawTextSection(title: "RECOMMENDATIONS", text: report.recommendations, y: &currentY)
            
            // --- Footer ---
            let footerLinePath = UIBezierPath()
            footerLinePath.move(to: CGPoint(x: margin, y: pageHeight - 60))
            footerLinePath.addLine(to: CGPoint(x: margin + contentWidth, y: pageHeight - 60))
            primaryColor.withAlphaComponent(0.2).setStroke()
            footerLinePath.stroke()
            
            let footerText = "This is an AI-generated enhanced report. Please consult a qualified medical professional for diagnosis."
            
            let footerAttr: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 10, weight: .medium),
                .foregroundColor: UIColor.gray
            ]
            let footerSize = footerText.size(withAttributes: footerAttr)
            footerText.draw(at: CGPoint(x: (pageWidth - footerSize.width) / 2, y: pageHeight - 45), withAttributes: footerAttr)
        }
        
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(report.patientName)_Report.pdf")
        
        do {
            try data.write(to: tempURL)
            return tempURL
        } catch {
            return nil
        }
    }
    
    private func exportText() -> String {
        """
        ULTRAXPERT MEDICAL REPORT
        --------------------------
        Patient Name: \(report.patientName)
        Patient ID: \(report.patientID)
        Age/Gender: \(report.age) yrs / \(report.gender)
        Date: \(report.date)
        --------------------------
        Scan Type: \(report.scanType)
        Modality: \(report.modality)
        Body Part: \(report.bodyPart)
        Status: \(report.status)
        
        FINDINGS:
        \(report.findings)
        
        IMPRESSION:
        \(report.impression)
        
        RECOMMENDATIONS:
        \(report.recommendations)
        --------------------------
        Generated via UltraXpert AI
        """
    }
}
