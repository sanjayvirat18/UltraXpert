import Foundation

protocol PatientServiceProtocol {
    func getPatients() async throws -> [PatientResponse]
    func addPatient(request: PatientCreateRequest) async throws -> PatientResponse
}

class PatientService: PatientServiceProtocol {
    
    func getPatients() async throws -> [PatientResponse] {
        return try await APIClient.shared.request(
            endpoint: "/api/v1/patients/",
            method: "GET",
            responseType: [PatientResponse].self
        )
    }
    
    func addPatient(request: PatientCreateRequest) async throws -> PatientResponse {
        return try await APIClient.shared.request(
            endpoint: "/api/v1/patients/",
            method: "POST",
            body: request,
            responseType: PatientResponse.self
        )
    }
}
