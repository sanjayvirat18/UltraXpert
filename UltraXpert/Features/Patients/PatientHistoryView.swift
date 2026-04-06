import SwiftUI

struct PatientHistoryView: View {
    let patientName: String
    
    struct HistoryEvent: Identifiable {
        let id = UUID()
        let date: String
        let title: String
        let description: String
        let icon: String
        let color: Color
    }
    
    let events = [
        HistoryEvent(date: "Today, 10:30 AM", title: "Ultrasound Scan", description: "Abdominal scan completed. Report generated.", icon: "waveform.path.ecg", color: .blue),
        HistoryEvent(date: "Jan 28, 2026", title: "Doctor Consultation", description: "Follow-up regarding liver functions.", icon: "stethoscope", color: .green),
        HistoryEvent(date: "Jan 15, 2026", title: "Lab Results", description: "Blood work analysis received.", icon: "doc.text", color: .orange),
        HistoryEvent(date: "Dec 20, 2025", title: "Initial Visit", description: "Patient registration and preliminary checkup.", icon: "person.badge.plus", color: .purple)
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                HStack {
                    Text("Medical Timeline")
                        .font(.title2)
                        .bold()
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top)
                
                // Timeline
                VStack(spacing: 0) {
                    ForEach(Array(events.enumerated()), id: \.element.id) { index, event in
                        HStack(alignment: .top, spacing: 16) {
                            // Time Column
                            Text(event.date)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .frame(width: 80, alignment: .trailing)
                                .padding(.top, 4)
                            
                            // Line and Dot
                            VStack(spacing: 0) {
                                Circle()
                                    .fill(event.color)
                                    .frame(width: 14, height: 14)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white, lineWidth: 2)
                                    )
                                
                                if index != events.count - 1 {
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(width: 2)
                                        .frame(minHeight: 60)
                                }
                            }
                            
                            // Content
                            VStack(alignment: .leading, spacing: 6) {
                                Text(event.title)
                                    .font(.headline)
                                
                                Text(event.description)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .fixedSize(horizontal: false, vertical: true)
                                
                                Spacer().frame(height: 16)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle(patientName)
        .background(Color(.systemGroupedBackground))
    }
}

#Preview {
    NavigationStack {
        PatientHistoryView(patientName: "Sarah Johnson")
    }
}
