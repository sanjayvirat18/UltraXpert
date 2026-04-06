import SwiftUI
import Combine

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

// MARK: - Improvement Item Model
struct ImprovementItem: Identifiable, Hashable {
    let id = UUID()
    var title: String
    var value: String
    var icon: String
}

// MARK: - Patient ViewModel / Store
@MainActor
class PatientStore: ObservableObject {
    @Published var patients: [Patient] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let patientService: PatientServiceProtocol
    
    init(patientService: PatientServiceProtocol = PatientService()) {
        self.patientService = patientService
    }
    
    func clear() {
        self.patients = []
        self.errorMessage = nil
    }
    
    func fetchPatients() async {
        self.isLoading = true
        self.errorMessage = nil
        do {
            let responses = try await patientService.getPatients()
            self.patients = responses.map { res in
                Patient(
                    patientID: res.patient_identifier,
                    name: res.name,
                    age: res.age,
                    gender: res.gender
                )
            }
        } catch {
            self.errorMessage = "Failed to load patients: \(error.localizedDescription)"
        }
        self.isLoading = false
    }
    
    func addPatient(_ patient: Patient) {
        // Optimistically insert locally
        patients.insert(patient, at: 0)
        
        let request = PatientCreateRequest(
            patient_identifier: patient.patientID,
            name: patient.name,
            age: patient.age,
            gender: patient.gender
        )
        
        Task {
            do {
                _ = try await patientService.addPatient(request: request)
            } catch {
                self.errorMessage = "Failed to sync new patient: \(error.localizedDescription)"
                // Optionally remove from array again if it failed
            }
        }
    }
    
    func deletePatient(at offsets: IndexSet) {
        // Backend doesn't support DELETE patient yet, just remove locally
        patients.remove(atOffsets: offsets)
    }
}
