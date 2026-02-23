import SwiftUI

struct ScanDetailsView: View {

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            VStack(spacing: 0) {

                // MARK: Top Bar
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.black)
                            .frame(width: 44, height: 44)
                    }

                    Spacer()

                    Text("Scan Details")
                        .font(.system(size: 17, weight: .semibold))

                    Spacer()

                    Color.clear
                        .frame(width: 44, height: 44)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 10)
                .background(Color.white)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {

                        // MARK: Scan Preview
                        ZStack(alignment: .bottomTrailing) {
                            RoundedRectangle(cornerRadius: 18)
                                .fill(Color.black)
                                .frame(height: 220)
                                .overlay(
                                    Text("Scan Image Preview")
                                        .foregroundColor(.white.opacity(0.5))
                                        .font(.system(size: 14, weight: .medium))
                                )

                            Text("Enhanced")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.white)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color.blue)
                                .clipShape(Capsule())
                                .padding(10)
                        }
                        .padding(.top, 16)

                        // MARK: Action Buttons
                        HStack(spacing: 14) {
                            ScanAction(icon: "arrow.left.arrow.right", title: "Compare")
                            ScanAction(icon: "pencil", title: "Annotate")
                            ScanAction(icon: "brain.head.profile", title: "AI Analysis")
                            ScanAction(icon: "doc.text", title: "Report")
                        }

                        // MARK: Metadata Card
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Metadata")
                                .font(.system(size: 17, weight: .semibold))

                            metadataRow(title: "Scan ID", value: "S-102")
                            metadataRow(title: "Date", value: "Oct 24, 2023 • 10:30 AM")
                            metadataRow(title: "Type", value: "Abdominal Ultrasound")
                            metadataRow(title: "Device", value: "GE Logiq E9")
                        }
                        .padding(16)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 18))

                        // MARK: AI Findings Card
                        VStack(alignment: .leading, spacing: 12) {
                            Text("AI Findings")
                                .font(.system(size: 17, weight: .semibold))

                            Text("Scan quality enhanced by 45%. Detected mild inflammation in the lower right quadrant. No significant abnormalities in organ structure.")
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                                .lineSpacing(4)
                        }
                        .padding(16)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 18))

                        // MARK: Bottom Buttons
                        HStack(spacing: 14) {
                            Button {} label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "square.and.arrow.up")
                                    Text("Share")
                                }
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color(.systemGray6))
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                            }

                            Button {} label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "arrow.down.circle.fill")
                                    Text("Download")
                                }
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.blue)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                            }
                        }
                        .padding(.top, 6)

                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 28)
                }
            }
        }
        .navigationBarBackButtonHidden()
    }

    // MARK: Metadata Row
    private func metadataRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 14))
                .foregroundColor(.gray)

            Spacer()

            Text(value)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.black)
        }
    }
}

// MARK: - Action Button
struct ScanAction: View {

    let icon: String
    let title: String

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.blue)
                .frame(width: 44, height: 44)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))

            Text(title)
                .font(.system(size: 12))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    NavigationStack {
        ScanDetailsView()
    }
}
