import SwiftUI
import UIKit

// MARK: - Report List Screen
struct ReportView: View {

    @EnvironmentObject var appSettings: AppSettings
    @EnvironmentObject var reportStore: ReportStore
    @AppStorage("themeColor") private var themeColorName = "Blue"

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 22) {
                        headerSection
                        reportsList
                    }
                    .padding(.horizontal, 18)
                    .padding(.top, 12)
                    .padding(.bottom, 28)
                }
            }
            .navigationTitle("Patients")
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(appSettings.darkModeEnabled ? .dark : .light)
        }
    }

    // MARK: - Header
    private var headerSection: some View {
        HStack {
            Text("Report Details")
                .font(.largeTitle)
                .fontWeight(.bold)
            Spacer()
        }
        .padding(.top, 10)
    }

    // MARK: - Reports List
    private var reportsList: some View {
        VStack(alignment: .leading, spacing: 14) {
            ForEach(reportStore.reports) { report in
                NavigationLink {
                    PatientReportDetailView(report: report)
                        .environmentObject(appSettings)
                } label: {
                    UXReportCardSummary(report: report)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - Patient Row Card
struct UXReportCardSummary: View {
    let report: PatientReport
    @AppStorage("themeColor") private var themeColorName = "Blue"
    @Environment(\.colorScheme) private var colorScheme

    private var themeColor: Color { ThemeManager.shared.color(for: themeColorName) }

    // Modality-aware SF Symbol
    private var modalityIcon: String {
        let lower = report.scanType.lowercased()
        if lower.contains("ct")         { return "cpu.fill" }
        if lower.contains("mri")        { return "brain.head.profile" }
        if lower.contains("x-ray")      { return "rays" }
        if lower.contains("ultrasound") { return "waveform.path.ecg" }
        return "doc.text.fill"
    }

    var body: some View {
        HStack(spacing: 0) {

            // ── Gradient left accent bar ─────────────────────────────
            LinearGradient(
                colors: [themeColor, themeColor.opacity(0.4)],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(width: 4)
            .clipShape(
                UnevenRoundedRectangle(
                    topLeadingRadius: 16,
                    bottomLeadingRadius: 16,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: 0
                )
            )

            HStack(spacing: 12) {

                // ── Icon stack: modality icon + patient initial ───────
                ZStack(alignment: .bottomTrailing) {
                    // Main modality icon circle
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        themeColor.opacity(colorScheme == .dark ? 0.30 : 0.15),
                                        themeColor.opacity(colorScheme == .dark ? 0.12 : 0.06)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 50, height: 50)

                        Image(systemName: modalityIcon)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(themeColor)
                    }

                    // Patient initial badge (bottom-right corner)
                    Circle()
                        .fill(themeColor)
                        .frame(width: 20, height: 20)
                        .overlay(
                            Text(String(report.patientName.prefix(1)))
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(.white)
                        )
                        .offset(x: 4, y: 4)
                }
                .padding(.trailing, 4)

                // ── Text block ──────────────────────────────────────
                VStack(alignment: .leading, spacing: 5) {

                    // Patient name
                    Text(report.patientName)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.primary)
                        .lineLimit(1)

                    // Scan type pill
                    Text(report.scanType)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(themeColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(themeColor.opacity(colorScheme == .dark ? 0.20 : 0.10))
                        .clipShape(Capsule())

                    // Patient ID
                    HStack(spacing: 4) {
                        Image(systemName: "person.text.rectangle")
                            .font(.system(size: 9))
                            .foregroundStyle(.secondary)
                        Text(report.patientID)
                            .font(.system(size: 11))
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer(minLength: 0)

                // ── Right side: time chip + status badge ─────────────
                VStack(alignment: .trailing, spacing: 8) {

                    // Status badge
                    Text(report.status)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(report.statusColor)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(report.statusColor.opacity(colorScheme == .dark ? 0.20 : 0.12))
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(report.statusColor.opacity(0.30), lineWidth: 0.8)
                        )

                    // Time chip
                    VStack(spacing: 2) {
                        Image(systemName: "clock")
                            .font(.system(size: 9, weight: .medium))
                            .foregroundStyle(themeColor.opacity(0.8))

                        Text(report.date)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.horizontal, 9)
                    .padding(.vertical, 7)
                    .background(
                        colorScheme == .dark
                            ? Color.white.opacity(0.06)
                            : Color.black.opacity(0.04)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(themeColor.opacity(0.20), lineWidth: 0.8)
                    )
                }
            }
            .padding(.vertical, 14)
            .padding(.leading, 14)
            .padding(.trailing, 12)
        }
        .background(
            colorScheme == .dark
                ? Color(white: 0.12)
                : Color(.systemBackground)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    colorScheme == .dark
                        ? Color.white.opacity(0.08)
                        : Color.black.opacity(0.06),
                    lineWidth: 0.8
                )
        )
        .shadow(
            color: themeColor.opacity(colorScheme == .dark ? 0.12 : 0.08),
            radius: 8, x: 0, y: 4
        )
    }
}

// MARK: - Patient Detail Screen
struct PatientReportDetailView: View {

    let report: PatientReport

    @EnvironmentObject var appSettings: AppSettings
    @Environment(\.dismiss) private var dismiss
    @AppStorage("themeColor") private var themeColorName = "Blue"

    @State private var showShareSheet = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {

                patientHeaderCard
                scanInfoCard
                findingsCard
                impressionCard
                recommendationsCard
                actionButtons
            }
            .padding(18)
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle("Patient Report")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                        Text("")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.primary)
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            ProfessionalShareView(report: report)
        }
        .preferredColorScheme(appSettings.darkModeEnabled ? .dark : .light)
    }

    // MARK: - Header Card
    private var patientHeaderCard: some View {
        VStack(spacing: 0) {
            
            // 1. Scan Image
            ZStack {
                Rectangle()
                    .fill(Color.black.opacity(0.8))
                    .frame(height: 220)
                
                if let image = report.image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 220)
                } else if let imageUrlPath = report.imageUrl, let imageUrl = URL(string: AppConfig.backendURL + imageUrlPath) {
                    AsyncImage(url: imageUrl) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(height: 220)
                    } placeholder: {
                        ProgressView()
                            .frame(height: 220)
                    }
                } else {
                    Image(systemName: "photo") // Placeholder
                        .resizable()
                        .scaledToFit()
                        .frame(height: 180)
                        .foregroundStyle(.gray)
                }
                
                // Overlay for Patient Name
                VStack {
                    Spacer()
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(report.patientName)
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Text("\(report.age) yrs • \(report.gender) • \(report.patientID)")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        Spacer()
                        
                        Text(report.status)
                            .font(.caption)
                            .fontWeight(.bold)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(report.statusColor)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                    }
                    .padding()
                    .background(
                        LinearGradient(colors: [.black.opacity(0.8), .clear], startPoint: .bottom, endPoint: .top)
                    )
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
            
            // 2. Statistics Row
            HStack(spacing: 0) {
                statBox(title: "Scan Type", value: report.scanType)
                Divider().frame(height: 30)
                statBox(title: "Modality", value: report.modality)
                Divider().frame(height: 30)
                statBox(title: "Body Part", value: report.bodyPart)
            }
            .padding(.vertical, 16)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(16)
            .padding(.top, 10)
        }
    }
    
    // Helper for stat row
    private func statBox(title: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
                .textCase(.uppercase)
            Text(value)
                .font(.subheadline)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Scan Info Card
    private var scanInfoCard: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Scan Information")
                    .font(.headline)
                Spacer()
            }

            Divider()

            infoRow(title: "Referring Doctor", value: report.referringDoctor)
            infoRow(title: "Scan Date & Time", value: report.date)
            infoRow(title: "Report Status", value: report.status, valueColor: report.statusColor)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    // MARK: - Findings
    private var findingsCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Findings")
                .font(.headline)
            Divider()
            Text(report.findings)
                .foregroundColor(.secondary)
                .lineSpacing(4)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    // MARK: - Impression
    private var impressionCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Impression")
                .font(.headline)
            Divider()
            Text(report.impression)
                .foregroundColor(.secondary)
                .lineSpacing(4)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    // MARK: - Recommendations
    private var recommendationsCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Recommendations")
                .font(.headline)
            Divider()
            Text(report.recommendations)
                .foregroundColor(.secondary)
                .lineSpacing(4)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }

    // MARK: - Actions
    private var actionButtons: some View {
        Button(action: { showShareSheet = true }) {
            HStack(spacing: 10) {
                Image(systemName: "square.and.arrow.up")
                Text("Share Report")
            }
            .font(.system(size: 17, weight: .bold))
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(ThemeManager.shared.color(for: themeColorName))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: ThemeManager.shared.color(for: themeColorName).opacity(0.3), radius: 10, x: 0, y: 5)
        }
    }

    // MARK: - Helper Views
    private func infoRow(title: String, value: String, valueColor: Color = .primary) -> some View {
        HStack {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(valueColor)
        }
    }

    private func infoBlock(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }

    // MARK: - Download Logic
    private func downloadReport() {
        let text = exportText()
        let fileName = "\(report.patientID)_Report.txt"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

        do {
            try text.write(to: url, atomically: true, encoding: .utf8)
            print("Report saved to: \(url)")
        } catch {
            print("Download failed:", error.localizedDescription)
        }
    }

    // MARK: - Export Text
    private func exportText() -> String {
        """
        Patient Report

        Name: \(report.patientName)
        Patient ID: \(report.patientID)
        Age: \(report.age)
        Gender: \(report.gender)

        Scan Type: \(report.scanType)
        Modality: \(report.modality)
        Body Part: \(report.bodyPart)
        Referring Doctor: \(report.referringDoctor)
        Scan Date: \(report.date)
        Status: \(report.status)

        FINDINGS:
        \(report.findings)

        IMPRESSION:
        \(report.impression)

        RECOMMENDATIONS:
        \(report.recommendations)
        """
    }
}


// MARK: - Preview
#Preview {
    ReportView()
        .environmentObject(AppSettings())
}
