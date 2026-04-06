import SwiftUI

struct SubscriptionView: View {
    @AppStorage("themeColor") private var themeColorName = "Blue"
    private var themeColor: Color { ThemeManager.shared.color(for: themeColorName) }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("UltraXpert Pro")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top, 40)
                
                Text("Unlock advanced AI features and unlimited cloud storage.")
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                VStack(spacing: 15) {
                    SubscriptionFeatureRow(text: "AI Noise Reduction")
                    SubscriptionFeatureRow(text: "Unlimited Patient Storage")
                    SubscriptionFeatureRow(text: "Cloud Sync")
                    SubscriptionFeatureRow(text: "Priority Support")
                }
                .padding()
                .background(themeColor.opacity(0.1))
                .cornerRadius(20)
                .padding()
                
                Button("Upgrade Now - ₹99/mo") {

                    // Purchase logic
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                
                Spacer()
            }
        }
        .navigationTitle("Subscription")
    }
}

struct SubscriptionFeatureRow: View {
    let text: String
    var body: some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
            Text(text)
            Spacer()
        }
    }
}
