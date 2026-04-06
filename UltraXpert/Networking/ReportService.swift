import Foundation

protocol ReportServiceProtocol {
    func getReports() async throws -> [ReportResponse]
    func addReport(request: ReportCreateRequest) async throws -> ReportResponse
}

class ReportService: ReportServiceProtocol {
    
    func getReports() async throws -> [ReportResponse] {
        return try await APIClient.shared.request(
            endpoint: "/api/v1/reports/",
            method: "GET",
            responseType: [ReportResponse].self
        )
    }
    
    func addReport(request: ReportCreateRequest) async throws -> ReportResponse {
        return try await APIClient.shared.request(
            endpoint: "/api/v1/reports/",
            method: "POST",
            body: request,
            responseType: ReportResponse.self
        )
    }
}
