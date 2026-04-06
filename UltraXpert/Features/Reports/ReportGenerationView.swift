import SwiftUI

struct ReportGenerationView: View {

    @Environment(\.dismiss) var dismiss
    
    // MARK: - State
    @State private var patientName = ""
    @State private var patientID = ""
    @State private var selectedModality = "Ultrasound"
    @State private var scanDate = Date()
    
    @State private var findings = ""
    @State private var impression = ""
    @State private var recommendations = ""
    
    @State private var showSuccess = false
    
    let modalities = ["Ultrasound", "X-Ray", "CT Scan", "MRI"]

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Patient Details")) {
                    TextField("Patient Name", text: $patientName)
                    TextField("Patient ID", text: $patientID)
                    DatePicker("Scan Date", selection: $scanDate, displayedComponents: [.date, .hourAndMinute])
                }
                
                Section(header: Text("Exam Details")) {
                    Picker("Modality", selection: $selectedModality) {
                        ForEach(modalities, id: \.self) { modality in
                            Text(modality)
                        }
                    }
                }
                
                Section(header: Text("Findings")) {
                    TextEditor(text: $findings)
                        .frame(height: 120)
                }
                
                Section(header: Text("Impression")) {
                    TextEditor(text: $impression)
                        .frame(height: 80)
                }
                
                Section(header: Text("Recommendations")) {
                    TextEditor(text: $recommendations)
                        .frame(height: 80)
                }
            }
            .navigationTitle("New Report")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .fontWeight(.semibold)
                            Text("Back")
                        }
                        .foregroundColor(.blue)
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveReport()
                    }
                    .disabled(patientName.isEmpty || findings.isEmpty)
                }
            }
            .alert("Success", isPresented: $showSuccess) {
                Button("Done") { dismiss() }
            } message: {
                Text("Report has been generated and saved successfully.")
            }
        }
    }
    
    private func saveReport() {
        // Logic to save report to store would go here.
        // For now, we simulate success.
        showSuccess = true
    }
}

#Preview {
    ReportGenerationView()
}
