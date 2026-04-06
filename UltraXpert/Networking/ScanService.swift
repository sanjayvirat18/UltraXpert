import Foundation
import UIKit

protocol ScanServiceProtocol {
    func uploadScan(image: UIImage) async throws -> String
    func enhanceScan(patientId: String, imageUrl: String) async throws -> EnhancementResponse
    func getAnalytics() async throws -> [EnhancementResponse]
}

class ScanService: ScanServiceProtocol {
    
    func uploadScan(image: UIImage) async throws -> String {
        guard let url = URL(string: AppConfig.backendURL + "/api/v1/scans/upload") else { throw APIError.invalidURL }
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { throw APIError.requestFailed }
        
        let boundary = UUID().uuidString
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        if let token = UserDefaults.standard.string(forKey: "access_token") {
            request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        var body = Data()
        let filename = "scan_\(UUID().uuidString).jpg"
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        let (data, response) = try await URLSession.shared.upload(for: request, from: body)
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw APIError.requestFailed
        }
        
        struct UploadResponse: Decodable {
            let original_image_url: String
        }
        
        do {
            let decoded = try JSONDecoder().decode(UploadResponse.self, from: data)
            return decoded.original_image_url
        } catch {
            throw APIError.decodingError
        }
    }
    
    func enhanceScan(patientId: String, imageUrl: String) async throws -> EnhancementResponse {
        let request = EnhancementCreateRequest(patient_id: patientId, original_image_url: imageUrl)
        
        return try await APIClient.shared.request(
            endpoint: "/api/v1/scans/enhance",
            method: "POST",
            body: request,
            responseType: EnhancementResponse.self
        )
    }
    
    func getAnalytics() async throws -> [EnhancementResponse] {
        return try await APIClient.shared.request(
            endpoint: "/api/v1/scans/analytics",
            method: "GET",
            responseType: [EnhancementResponse].self
        )
    }
}
