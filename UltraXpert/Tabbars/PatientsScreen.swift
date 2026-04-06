import SwiftUI
import PhotosUI
import UIKit

// Note: Models (Patient, ImprovementItem) extracted to PatientStore.swift

// MARK: - Patient Row
struct PatientRow: View {

    let patient: Patient
    @AppStorage("themeColor") private var themeColorName = "Blue"
    private var themeColor: Color { ThemeManager.shared.color(for: themeColorName) }

    var body: some View {
        HStack(spacing: 12) {

            ZStack {
                Circle()
                    .fill(themeColor.opacity(0.15))
                    .frame(width: 44, height: 44)

                Image(systemName: "person.fill")
                    .foregroundColor(themeColor)
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

struct PatientsScreen: View {

    @Environment(\.dismiss) var dismiss // <-- needed for back button
    @EnvironmentObject var patientStore: PatientStore

    @State private var searchText = ""
    @State private var showAddPatient = false

    var filteredPatients: [Patient] {
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if q.isEmpty { return patientStore.patients }
        return patientStore.patients.filter {
            $0.name.lowercased().contains(q) || $0.patientID.lowercased().contains(q)
        }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredPatients.indices, id: \.self) { index in
                     // We need to find the binding in the store. 
                     // Since filteredPatients is a computed property, we can't get a direct binding easily for all cases if filtering is active.
                     // However, for typical SwiftUI navigation to detail with binding:
                     // We can find the index in the original array.
                     if let realIndex = patientStore.patients.firstIndex(where: { $0.id == filteredPatients[index].id }) {
                         NavigationLink {
                             PatientDetailScreen(patient: $patientStore.patients[realIndex])
                         } label: {
                             PatientRow(patient: filteredPatients[index])
                         }
                     }
                }
                .onDelete(perform: deletePatient)
            }
            .listStyle(.insetGrouped)
            .searchable(text: $searchText)
            .navigationTitle("Patients")
            .toolbar {
                // Add patient button on trailing
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showAddPatient = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $showAddPatient) {
                AddPatientView()
            }
        }
    }

    private func deletePatient(at offsets: IndexSet) {
        let snapshot = filteredPatients
        let itemsToDelete = offsets.map { snapshot[$0] }
        
        for item in itemsToDelete {
            if let index = patientStore.patients.firstIndex(where: { $0.id == item.id }) {
                patientStore.patients.remove(at: index)
            }
        }
    }
}

// MARK: - Patient Detail Screen
struct PatientDetailScreen: View {

    @Binding var patient: Patient

    @State private var showImagePicker = false
    @State private var selectedImage: UIImage? = nil

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 18) {

                // Patient info card
                VStack(alignment: .leading, spacing: 12) {
                    Text(patient.name)
                        .font(.title2.bold())

                    Divider()

                    InfoRow(title: "Patient ID", value: patient.patientID)
                    InfoRow(title: "Age", value: patient.age)
                    InfoRow(title: "Gender", value: patient.gender)

                    Text("Created: \(patient.createdAt.formatted(date: .abbreviated, time: .shortened))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.top, 4)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 18))
                
                // History Button
                NavigationLink {
                    PatientHistoryView(patientName: patient.name)
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 20))
                            .foregroundColor(.purple)
                        
                        Text("View Medical History")
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }

                // Attach ultrasound button
                Button {
                    showImagePicker = true
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "paperclip")
                        Text("Attach Ultrasound Image")
                            .fontWeight(.semibold)
                        Spacer()
                        Image(systemName: "plus")
                    }
                    .padding()
                    .foregroundColor(.white)
                    .background(ThemeManager.shared.color(for: (UserDefaults.standard.string(forKey: "themeColor") ?? "Blue")))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }

                // Attached scans
                VStack(alignment: .leading, spacing: 12) {
                    Text("Attached Scans")
                        .font(.headline)

                    if patient.ultrasoundImages.isEmpty {
                        Text("No scans attached yet.")
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                            .padding(.top, 2)
                    } else {
                        VStack(spacing: 12) {
                            ForEach(patient.ultrasoundImages.indices, id: \.self) { index in
                                NavigationLink {
                                    UltrasoundScanScreen(
                                        patientName: patient.name,
                                        patientId: patient.patientID,
                                        age: patient.age,
                                        gender: patient.gender,
                                        scanType: "Abdomen",
                                        scanDate: "29 Jan 2026",
                                        beforeImage: patient.ultrasoundImages[index],
                                        afterImage: patient.ultrasoundImages[index],
                                        beforePercent: 62,
                                        afterPercent: 89,
                                        totalImprovementPercent: 27,
                                        avgQualityGain: 37,
                                        improvements: [
                                            ImprovementItem(title: "Noise Reduced", value: "High", icon: "waveform.path.ecg"),
                                            ImprovementItem(title: "Sharpness", value: "+22%", icon: "scope"),
                                            ImprovementItem(title: "Contrast", value: "+18%", icon: "circle.lefthalf.filled"),
                                            ImprovementItem(title: "Brightness", value: "+12%", icon: "sun.max.fill")
                                        ]
                                    )
                                } label: {
                                    HStack(spacing: 12) {
                                        Image(uiImage: patient.ultrasoundImages[index])
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 64, height: 64)
                                            .clipShape(RoundedRectangle(cornerRadius: 14))
                                            .clipped()

                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("Ultrasound Scan \(index + 1)")
                                                .font(.headline)

                                            Text("Tap to view report")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }

                                        Spacer()

                                        Image(systemName: "chevron.right")
                                            .foregroundColor(.secondary)
                                            .font(.caption)
                                    }
                                    .padding(14)
                                    .background(Color(.secondarySystemBackground))
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Spacer(minLength: 24)
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 90) // IMPORTANT: avoids TabBar overlap
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

// MARK: - Ultrasound Scan Screen (FULL FIXED)
struct UltrasoundScanScreen: View {

    let patientName: String
    let patientId: String
    let age: String
    let gender: String
    let scanType: String
    let scanDate: String

    let beforeImage: UIImage
    let afterImage: UIImage

    let beforePercent: Int
    let afterPercent: Int
    let totalImprovementPercent: Int
    let avgQualityGain: Int

    let improvements: [ImprovementItem]

    private let gridColumns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]

    @State private var showAnnotation = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {

                // MARK: Before / After (GRID FIX)
                LazyVGrid(columns: gridColumns, spacing: 14) {
                    ScanImageCard(title: "Before", percent: beforePercent, image: beforeImage)
                    ScanImageCard(title: "After", percent: afterPercent, image: afterImage)
                }

                // MARK: Patient Info
                sectionTitle("Patient Information")

                VStack(spacing: 10) {
                    InfoRow(title: "Name", value: patientName)
                    InfoRow(title: "Patient ID", value: patientId)
                    InfoRow(title: "Age", value: age)
                    InfoRow(title: "Gender", value: gender)
                    InfoRow(title: "Scan Type", value: scanType)
                    InfoRow(title: "Scan Date", value: scanDate)
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 18))

                // MARK: Enhancement Summary
                sectionTitle("Enhancement Summary")

                LazyVGrid(columns: gridColumns, spacing: 14) {
                    StatMiniCard(title: "Total Improvement", value: "\(totalImprovementPercent)%", icon: "sparkles")
                    StatMiniCard(title: "Avg Quality Gain", value: "\(avgQualityGain)%", icon: "chart.line.uptrend.xyaxis")
                }

                // MARK: Improvements
                sectionTitle("Improvements")

                VStack(spacing: 10) {
                    ForEach(improvements) { item in
                        HStack(spacing: 12) {
                            Image(systemName: item.icon)
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(ThemeManager.shared.color(for: (UserDefaults.standard.string(forKey: "themeColor") ?? "Blue")))
                                .frame(width: 42, height: 42)
                                .background(ThemeManager.shared.color(for: (UserDefaults.standard.string(forKey: "themeColor") ?? "Blue")).opacity(0.12))
                                .clipShape(RoundedRectangle(cornerRadius: 14))

                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.title)
                                    .font(.headline)

                                Text(item.value)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()
                        }
                        .padding(14)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                    }
                }

                Spacer(minLength: 24)
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 100) // IMPORTANT: avoid tab bar overlap
        }
        .background(Color(.systemBackground))
        .navigationTitle("Ultrasound Scan")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showAnnotation = true
                } label: {
                    Image(systemName: "pencil.tip.crop.circle")
                }
            }
        }
        .sheet(isPresented: $showAnnotation) {
            ScanAnnotationView()
        }
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title)
        .font(.title3.bold())
        .padding(.top, 4)
    }
}

// MARK: - Scan Image Card (No Clipping)
struct ScanImageCard: View {

    let title: String
    let percent: Int
    let image: UIImage

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            HStack {
                Text(title)
                    .font(.headline.bold())
                Spacer()
                Text("\(percent)%")
                    .font(.headline.bold())
                    .foregroundColor(ThemeManager.shared.color(for: (UserDefaults.standard.string(forKey: "themeColor") ?? "Blue")))
            }

            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(height: 140)
                .frame(maxWidth: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .clipped()
        }
        .padding(12)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

// MARK: - Stat Mini Card
struct StatMiniCard: View {

    let title: String
    let value: String
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {

            Image(systemName: icon)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(ThemeManager.shared.color(for: (UserDefaults.standard.string(forKey: "themeColor") ?? "Blue")))
                .frame(width: 42, height: 42)
                .background(ThemeManager.shared.color(for: (UserDefaults.standard.string(forKey: "themeColor") ?? "Blue")).opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 14))

            Text(value)
                .font(.system(size: 26, weight: .bold))

            Text(title)
                .font(.footnote)
                .foregroundStyle(.secondary)

            Spacer(minLength: 0)
        }
        .padding(14)
        .frame(maxWidth: .infinity)
        .frame(height: 140)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

// MARK: - Reusable UI
struct InfoRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
        }
        .font(.subheadline)
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

// MARK: - Preview
#Preview {
    NavigationStack {
        PatientsScreen()
    }
}
