import SwiftUI

struct ClinicalResourcesView: View {
    @EnvironmentObject var appSettings: AppSettings
    @AppStorage("themeColor") private var themeColorName = "Blue"
    
    let resources: [ResourceItem] = [
        ResourceItem(title: "AI Noise Reduction", subtitle: "Enhancement", icon: "waveform.path", color: .blue, description: "Advanced convolutional neural networks designed to remove acoustic speckle and shadowing artifacts from raw ultrasound feeds. The purpose is to create a cleaner, diagnostic-grade image without losing critical high-frequency tissue details."),
        ResourceItem(title: "Smart Contrast Validation", subtitle: "Image Processing", icon: "slider.horizontal.3", color: .blue, description: "Utilizes deep learning to dynamically adjust the contrast envelope of the ultrasound. This tool is purpose-built to differentiate between iso-echoic tissues, making masses, fluid-filled cysts, and distinct anatomical boundaries stand out clearly."),
        ResourceItem(title: "Lesion Detection AI", subtitle: "Diagnostics", icon: "magnifyingglass.circle.fill", color: .blue, description: "An AI-assisted bounding box tool that highlights potential structural anomalies. Its purpose is to serve as a second reader for clinicians, automatically calculating the confidence score of suspicious hypoechoic or hyperechoic regions."),
        ResourceItem(title: "Detail & Edge Sharpening", subtitle: "Enhancement", icon: "wand.and.stars", color: .blue, description: "Applies frequency-domain algorithms to intelligently sharpen the margins of organs such as the liver, kidneys, or fetal structures. The purpose is to allow for highly precise caliper measurements.")
    ]
    
    // Columns for Grid
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        Text("Search guidelines, calc...")
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Quick Access Grid
                    Text("Clinical Tools")
                        .font(.headline)
                        .padding(.top)
                    
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(resources) { item in
                            NavigationLink(destination: ResourceDetailView(item: item)) {
                                ResourceCard(item: item)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    
                    // Recent Updates Section
                    Text("Latest Guidelines")
                        .font(.headline)
                        .padding(.top)
                    
                    VStack(spacing: 12) {
                        NavigationLink(destination: GuidelineDetailView(title: "Optimal Scan Acquisition for AI", date: "Mar 15, 2026")) {
                            GuidelineRow(title: "Optimal Scan Acquisition for AI", date: "Mar 15, 2026")
                        }
                        .buttonStyle(.plain)
                        
                        NavigationLink(destination: GuidelineDetailView(title: "Interpreting AI Confidence Scores", date: "Feb 10, 2026")) {
                            GuidelineRow(title: "Interpreting AI Confidence Scores", date: "Feb 10, 2026")
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
            .navigationTitle("Resources")
            .background(Color(.systemGroupedBackground))
            .preferredColorScheme(appSettings.darkModeEnabled ? .dark : .light)
        }
    }
}

// MARK: - Models & Subviews

struct ResourceItem: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let description: String
}

struct ResourceCard: View {
    let item: ResourceItem

    @AppStorage("themeColor") private var themeColorName = "Blue"
    @Environment(\.colorScheme) private var colorScheme

    private var themeColor: Color { ThemeManager.shared.color(for: themeColorName) }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {

            // Top accent bar
            LinearGradient(
                colors: [themeColor, themeColor.opacity(0.3)],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(height: 3)
            .clipShape(
                UnevenRoundedRectangle(
                    topLeadingRadius: 16,
                    bottomLeadingRadius: 0,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: 16
                )
            )

            VStack(alignment: .leading, spacing: 12) {

                // Icon circle
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    themeColor.opacity(colorScheme == .dark ? 0.30 : 0.15),
                                    themeColor.opacity(colorScheme == .dark ? 0.10 : 0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 46, height: 46)

                    Image(systemName: item.icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(themeColor)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(item.title)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.primary)
                        .lineLimit(2)

                    // Category pill
                    Text(item.subtitle)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(themeColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(themeColor.opacity(colorScheme == .dark ? 0.20 : 0.10))
                        .clipShape(Capsule())
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
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

struct GuidelineRow: View {
    let title: String
    let date: String

    @AppStorage("themeColor") private var themeColorName = "Blue"
    @Environment(\.colorScheme) private var colorScheme

    private var themeColor: Color { ThemeManager.shared.color(for: themeColorName) }

    var body: some View {
        HStack(spacing: 0) {

            // ── Gradient left accent bar ─────────────────────────
            LinearGradient(
                colors: [themeColor, themeColor.opacity(0.35)],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(width: 4)
            .clipShape(
                UnevenRoundedRectangle(
                    topLeadingRadius: 12,
                    bottomLeadingRadius: 12,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: 0
                )
            )

            HStack(spacing: 14) {

                // ── Doc icon circle ──────────────────────────────
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    themeColor.opacity(colorScheme == .dark ? 0.28 : 0.14),
                                    themeColor.opacity(colorScheme == .dark ? 0.10 : 0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 42, height: 42)

                    Image(systemName: "doc.text.fill")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(themeColor)
                }

                // ── Title ────────────────────────────────────────
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(2)
                }

                Spacer(minLength: 0)

                // ── Date chip ────────────────────────────────────
                VStack(spacing: 2) {
                    Image(systemName: "calendar")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundStyle(themeColor.opacity(0.8))

                    Text(date)
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

                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(themeColor.opacity(0.45))
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
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
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

#Preview {
    ClinicalResourcesView()
        .environmentObject(AppSettings())
}
