import SwiftUI
import PhotosUI

// MARK: - Patient Model
struct Patient: Identifiable, Hashable {
    let id = UUID()
    var patientID: String
    var name: String
    var age: String
    var gender: String
    var createdAt: Date = Date()
    var ultrasoundImages: [UIImage] = []
}

// MARK: - Patients Screen (TAB)
struct PatientsScreen: View {

    @State private var patients: [Patient] = [
        Patient(patientID: "PT-1001", name: "Ravi Kumar", age: "32", gender: "Male"),
        Patient(patientID: "PT-1002", name: "Anjali Sharma", age: "28", gender: "Female")
    ]

    @State private var searchText = ""
    @State private var showAddPatient = false

    var filteredPatients: [Patient] {
        if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return patients
        } else {
            return patients.filter {
                $0.name.lowercased().contains(searchText.lowercased()) ||
                $0.patientID.lowercased().contains(searchText.lowercased())
            }
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Patients")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Manage patient records and attach ultrasound scans.")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.top, 10)

                // List
                List {
                    Section(header: Text("Patient Records")) {
                        ForEach(filteredPatients.indices, id: \.self) { index in
                            NavigationLink {
                                PatientDetailScreen(patient: $patients[index])
                            } label: {
                                PatientRow(patient: filteredPatients[index])
                            }
                        }
                        .onDelete(perform: deletePatient)
                    }
                }
                .listStyle(.insetGrouped)
            }
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAddPatient = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                }
            }
            .sheet(isPresented: $showAddPatient) {
                AddPatientSheet { newPatient in
                    patients.insert(newPatient, at: 0)
                }
            }
        }
    }

    private func deletePatient(at offsets: IndexSet) {
        patients.remove(atOffsets: offsets)
    }
}

// MARK: - Patient Row
struct PatientRow: View {

    let patient: Patient

    var body: some View {
        HStack(spacing: 12) {

            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.15))
                    .frame(width: 44, height: 44)

                Image(systemName: "person.fill")
                    .foregroundColor(.blue)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(patient.name)
                    .font(.headline)

                Text("ID: \(patient.patientID) • Age: \(patient.age) • \(patient.gender)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .font(.caption)
        }
        .padding(.vertical, 6)
    }
}

// MARK: - Patient Detail Screen
struct PatientDetailScreen: View {

    @Binding var patient: Patient

    @State private var showImagePicker = false
    @State private var selectedImage: UIImage? = nil

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {

                // Patient info card
                VStack(alignment: .leading, spacing: 10) {
                    Text(patient.name)
                        .font(.title2)
                        .fontWeight(.bold)

                    Divider()

                    InfoRow(title: "Patient ID", value: patient.patientID)
                    InfoRow(title: "Age", value: patient.age)
                    InfoRow(title: "Gender", value: patient.gender)

                    Text("Created: \(patient.createdAt.formatted(date: .abbreviated, time: .shortened))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 6)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(18)

                // Attach ultrasound button
                Button {
                    showImagePicker = true
                } label: {
                    HStack {
                        Image(systemName: "paperclip")
                        Text("Attach Ultrasound Image")
                            .fontWeight(.semibold)
                        Spacer()
                        Image(systemName: "plus")
                    }
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(18)
                }

                // Uploaded scans section
                VStack(alignment: .leading, spacing: 10) {
                    Text("Attached Scans")
                        .font(.headline)

                    if patient.ultrasoundImages.isEmpty {
                        Text("No scans attached yet.")
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                            .padding(.top, 4)
                    } else {
                        ForEach(patient.ultrasoundImages.indices, id: \.self) { index in
                            NavigationLink {
                                PatientScanDetailScreen(
                                    patientName: patient.name,
                                    image: patient.ultrasoundImages[index]
                                )
                            } label: {
                                HStack(spacing: 12) {
                                    Image(uiImage: patient.ultrasoundImages[index])
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 70, height: 70)
                                        .clipShape(RoundedRectangle(cornerRadius: 14))

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Ultrasound Scan \(index + 1)")
                                            .font(.headline)

                                        Text("Tap to view and enhance")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }

                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.secondary)
                                        .font(.caption)
                                }
                                .padding()
                                .background(Color(.secondarySystemBackground))
                                .cornerRadius(18)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Spacer(minLength: 30)
            }
            .padding()
        }
        .background(Color(.systemBackground))
        .navigationTitle("Patient Details")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showImagePicker) {
            PatientImagePicker(selectedImage: $selectedImage)
        }
        .onChange(of: selectedImage) { _, newImage in
            guard let newImage else { return }
            patient.ultrasoundImages.insert(newImage, at: 0)
        }
    }
}

// MARK: - Scan Detail Screen (Enhancement Link)
struct PatientScanDetailScreen: View {

    let patientName: String
    let image: UIImage

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {

                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .cornerRadius(18)
                    .shadow(radius: 6)

                Text("Patient: \(patientName)")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)

                // Actions
                VStack(spacing: 12) {

                    NavigationLink(destination: EnhancementView()) {
                        ActionButton(title: "Enhance Image", icon: "circle", color: .blue)
                    }

                    NavigationLink(destination: SmartEnhanceView()) {
                        ActionButton(title: "Smart Enhance (AI)", icon: "sparkles", color: .blue)
                    }
                }

                Spacer(minLength: 30)
            }
            .padding()
        }
        .background(Color(.systemBackground))
        .navigationTitle("Ultrasound Scan")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Add Patient Sheet
struct AddPatientSheet: View {

    @Environment(\.dismiss) var dismiss

    @State private var patientID = ""
    @State private var name = ""
    @State private var age = ""
    @State private var gender = "Male"

    let onSave: (Patient) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Patient Information")) {
                    TextField("Patient ID (ex: PT-1003)", text: $patientID)
                    TextField("Full Name", text: $name)
                    TextField("Age", text: $age)

                    Picker("Gender", selection: $gender) {
                        Text("Male").tag("Male")
                        Text("Female").tag("Female")
                        Text("Other").tag("Other")
                    }
                }
            }
            .navigationTitle("Add Patient")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        let newPatient = Patient(
                            patientID: patientID.isEmpty ? "PT-\(Int.random(in: 1000...9999))" : patientID,
                            name: name.isEmpty ? "Unknown Patient" : name,
                            age: age.isEmpty ? "-" : age,
                            gender: gender
                        )
                        onSave(newPatient)
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Reusable UI
struct InfoRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
        }
        .font(.subheadline)
    }
}

struct ActionButton: View {
    let title: String
    let icon: String
    let color: Color

    var body: some View {
        HStack {
            Image(systemName: icon)
            Text(title)
                .fontWeight(.semibold)
            Spacer()
            Image(systemName: "chevron.right")
        }
        .padding()
        .foregroundColor(.white)
        .background(color)
        .cornerRadius(18)
    }
}

// MARK: - Patient Image Picker
struct PatientImagePicker: UIViewControllerRepresentable {

    @Binding var selectedImage: UIImage?

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {

        let parent: PatientImagePicker

        init(_ parent: PatientImagePicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)

            guard let provider = results.first?.itemProvider,
                  provider.canLoadObject(ofClass: UIImage.self) else { return }

            provider.loadObject(ofClass: UIImage.self) { image, _ in
                DispatchQueue.main.async {
                    self.parent.selectedImage = image as? UIImage
                }
            }
        }
    }
}

// MARK: - Dummy Screens (Replace with your actual ones)
struct SmartEnhancementView: View {
    var body: some View {
        Text("Smart Enhance Screen")
            .navigationTitle("Smart Enhance")
    }
}

// MARK: - Preview
#Preview {
    PatientsScreen()
}
