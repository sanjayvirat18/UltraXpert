import SwiftUI

struct ScanPreviewView: View {

    let scanImage: UIImage

    @State private var patientID: String = ""
    @State private var patientName: String = ""
    @State private var age: String = ""
    @State private var gender: String = "Male"
    @State private var scanType: String = "Abdomen"
    @State private var notes: String = ""

    @State private var goNext = false

    let genders = ["Male", "Female", "Other"]
    let scanTypes = ["Abdomen", "Thyroid", "Kidney", "Liver", "Heart", "Other"]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 18) {

                Text("Scan Preview")
                    .font(.title2).bold()
                    .frame(maxWidth: .infinity, alignment: .leading)

                Image(uiImage: scanImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 240)
                    .clipShape(RoundedRectangle(cornerRadius: 18))

                VStack(spacing: 12) {
                    field("Patient ID", text: $patientID)
                    field("Patient Name", text: $patientName)
                    field("Age", text: $age)
                        .keyboardType(.numberPad)

                    Picker("Gender", selection: $gender) {
                        ForEach(genders, id: \.self) { Text($0) }
                    }
                    .pickerStyle(.segmented)

                    Picker("Scan Type", selection: $scanType) {
                        ForEach(scanTypes, id: \.self) { Text($0) }
                    }
                    .pickerStyle(.menu)

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Notes (Optional)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        TextEditor(text: $notes)
                            .frame(height: 90)
                            .padding(10)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                }

                Button {
                    goNext = true
                } label: {
                    Text("Continue to Enhancement")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.black)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }
            .padding()
        }
        .navigationDestination(isPresented: $goNext) {
            EnhancementChoiceView(scanImage: scanImage)
        }
    }

    @ViewBuilder
    private func field(_ title: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            TextField(title, text: text)
                .padding(12)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }
}
