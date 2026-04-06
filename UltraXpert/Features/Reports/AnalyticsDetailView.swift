import SwiftUI

struct AnalyticsDetailView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var analyticsStore: AnalyticsStore
    @AppStorage("themeColor") private var themeColorName = "Blue"
    private var themeColor: Color { ThemeManager.shared.color(for: themeColorName) }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("Enhancement Report")
                        .font(.title2)
                        .fontWeight(.bold)
                    if let date = analyticsStore.latestEnhancement?.date {
                        Text("AI Analysis computed on \(date.formatted(date: .abbreviated, time: .shortened))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    } else {
                        Text("AI Processing Analysis for recent scan")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.top, 20)
                
                if let result = analyticsStore.latestEnhancement {
                    // Before/After Comparison Card
                    VStack(spacing: 0) {
                        HStack(spacing: 0) {
                            // Before
                            VStack {
                                ZStack {
                                    Rectangle()
                                        .fill(Color.black.opacity(0.8))
                                        .frame(height: 140)
                                    
                                    Image(uiImage: result.originalImage)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 140)
                                }
                                Text("Original")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.secondary)
                                    .padding(.vertical, 8)
                            }
                            
                            Divider()
                            
                            // After
                            VStack {
                                ZStack {
                                    Rectangle()
                                        .fill(Color.black)
                                        .frame(height: 140)
                                    
                                    Image(uiImage: result.enhancedImage)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 140)
                                }
                                Text("Enhanced (AI)")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(themeColor)
                                    .padding(.vertical, 8)
                            }
                        }
                        
                        Divider()
                        
                        // Total Improvement
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Total Quality Improvement")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text(result.improvementPercentage)
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)
                                
                                Text(result.date.formatted(date: .long, time: .standard))
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Image(systemName: "arrow.up.right.circle.fill")
                                .font(.system(size: 32))
                                .foregroundColor(.green)
                        }
                        .padding(16)
                        .background(Color.green.opacity(0.1))
                    }
                    .background(Color(.systemBackground))
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
                    .padding(.horizontal)

                    // Comparison Metrics
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Quality Metrics")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        // Real data from model
                        VStack(spacing: 16) {
                            ComparisonRow(label: "Signal-to-Noise Ratio", before: result.snrBefore, after: result.snrAfter, improvement: "+SNR", color: .purple)
                            ComparisonRow(label: "Edge Sharpness", before: result.edgeSharpnessBefore, after: result.edgeSharpnessAfter, improvement: "+Details", color: .blue)
                            ComparisonRow(label: "Contrast Clarity", before: result.contrastClarityBefore, after: result.contrastClarityAfter, improvement: "+Clarity", color: .orange)
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(16)
                        .padding(.horizontal)
                    }

                    // Detailed Breakdown Chart (Visual)
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Enhancement Breakdown")
                            .font(.headline)
                            .padding(.horizontal)
                            
                        VStack(spacing: 20) {
                            ChartRow(label: "Noise Reduction Efficiency", value: result.noiseReductionEfficiency, color: .purple)
                            ChartRow(label: "Structure Recovery", value: result.structureRecovery, color: .indigo)
                            ChartRow(label: "Detail Preservation", value: result.detailPreservation, color: .blue)
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(16)
                        .padding(.horizontal)
                    }
                } else {
                    // Empty State
                    VStack(spacing: 24) {
                        Image(systemName: "chart.bar.doc.horizontal")
                            .font(.system(size: 64))
                            .foregroundColor(.secondary.opacity(0.4))
                        
                        VStack(spacing: 8) {
                            Text("No Report Available")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                            
                            Text("Enhance an ultrasound scan to generate a detailed AI processing report here.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 80)
                }
                
                Spacer(minLength: 40)
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Analytics")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Comparison Row Component
struct ComparisonRow: View {
    let label: String
    let before: String
    let after: String
    let improvement: String
    let color: Color
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                HStack(spacing: 4) {
                    Text(before)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .strikethrough()
                    Image(systemName: "arrow.right")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(after)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(color)
                }
            }
            
            Spacer()
            
            Text(improvement)
                .font(.subheadline)
                .fontWeight(.bold)
                .foregroundColor(.green)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.green.opacity(0.1))
                .cornerRadius(6)
        }
    }
}

struct ChartRow: View {
    let label: String
    let value: Double
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(label)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                Text("\(Int(value * 100))%")
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(color)
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                    
                    Capsule()
                        .fill(color)
                        .frame(width: geo.size.width * value, height: 8)
                }
            }
            .frame(height: 8)
        }
    }
}


#Preview {
    NavigationStack {
        AnalyticsDetailView()
            .environmentObject(AnalyticsStore())
    }
}
