import SwiftUI

struct LearningModeView: View {

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {

                VStack(alignment: .leading, spacing: 8) {
                    Text("Learning Mode")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Learn how ultrasound enhancement works and how to use each feature.")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                LearningCard(
                    title: "What is Noise Reduction?",
                    subtitle: "Understand speckle noise and how reduction improves clarity.",
                    icon: "waveform.path.ecg"
                )

                LearningCard(
                    title: "Contrast Enhancement Guide",
                    subtitle: "Improve brightness and organ visibility safely.",
                    icon: "circle.lefthalf.filled"
                )

                LearningCard(
                    title: "Edge Sharpening Tips",
                    subtitle: "How sharpening helps boundary detection in ultrasound.",
                    icon: "viewfinder"
                )

                LearningCard(
                    title: "Smart Enhance (AI)",
                    subtitle: "How AI selects best enhancement settings automatically.",
                    icon: "sparkles"
                )

                VStack(alignment: .leading, spacing: 10) {
                    Text("Quick Practice")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("Try applying enhancements to sample ultrasound images to understand differences.")
                        .foregroundColor(.secondary)
                        .font(.callout)

                    Button {
                        // You can navigate to sample practice module
                    } label: {
                        Text("Start Practice")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(18)
                    }
                }
                .padding(.top, 8)

                Spacer(minLength: 30)
            }
            .padding()
        }
        .background(Color(.systemBackground))
        .navigationTitle("Learning Mode")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Learning Card
struct LearningCard: View {
    let title: String
    let subtitle: String
    let icon: String

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 44, height: 44)
                .background(Color.blue.opacity(0.12))
                .cornerRadius(14)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(20)
        .shadow(
            color: Color.black.opacity(colorScheme == .dark ? 0.25 : 0.08),
            radius: 5,
            x: 0,
            y: 2
        )
    }
}
