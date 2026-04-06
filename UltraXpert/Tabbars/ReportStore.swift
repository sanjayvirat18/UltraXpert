import SwiftUI
import Combine

// MARK: - Patient Report Model
struct PatientReport: Identifiable {
    let id = UUID()
    let patientName: String
    let patientID: String
    let age: Int
    let gender: String
    let scanType: String
    let modality: String
    let bodyPart: String
    let referringDoctor: String
    let date: String
    let status: String
    let statusColor: Color
    let findings: String
    let impression: String
    let recommendations: String
    var image: UIImage? = nil
    var imageUrl: String? = nil
}

// MARK: - Report ViewModel / Store
@MainActor
class ReportStore: ObservableObject {
    @Published var reports: [PatientReport] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let reportService: ReportServiceProtocol
    
    init(reportService: ReportServiceProtocol = ReportService()) {
        self.reportService = reportService
    }
    
    func clear() {
        self.reports = []
        self.errorMessage = nil
    }
    
    func fetchReports() async {
        self.isLoading = true
        self.errorMessage = nil
        do {
            let responses = try await reportService.getReports()
            self.reports = responses.map { res in
                PatientReport(
                    patientName: res.patient_name ?? "Patient \(res.patient_id.prefix(4))",
                    patientID: res.patient_id,
                    age: Int(res.age ?? "0") ?? 0,
                    gender: res.gender ?? "Unknown",
                    scanType: res.scan_type ?? "Unknown Scan",
                    modality: res.modality ?? "Ultrasound",
                    bodyPart: res.body_part ?? "Unknown",
                    referringDoctor: res.doctor_name ?? "Not specified",
                    date: res.created_at ?? "Today",
                    status: res.status,
                    statusColor: res.status == "Completed" ? .green : .orange,
                    findings: res.findings ?? "No findings noted.",
                    impression: res.impression ?? "No impression recorded.",
                    recommendations: res.recommendations ?? "No recommendations.",
                    imageUrl: res.image_url
                )
            }
        } catch {
            self.errorMessage = "Failed to load reports: \(error.localizedDescription)"
        }
        self.isLoading = false
    }
    
    func addReport(_ report: PatientReport) {
        // Optimistic UI update
        reports.insert(report, at: 0)
        
        Task {
            do {
                var finalImageUrl = report.imageUrl
                
                // If there's an image but no URL (happens in manual enhancement), upload it first
                if finalImageUrl == nil, let image = report.image {
                    let scanService = ScanService()
                    finalImageUrl = try await scanService.uploadScan(image: image)
                }

                // Sync with backend using the uploaded URL
                let request = ReportCreateRequest(
                    patient_id: report.patientID,
                    scan_type: report.scanType,
                    modality: report.modality,
                    body_part: report.bodyPart,
                    status: report.status,
                    findings: report.findings,
                    impression: report.impression,
                    recommendations: report.recommendations,
                    image_url: finalImageUrl
                )
                
                 _ = try await reportService.addReport(request: request)
            } catch {
                self.errorMessage = "Failed to create report on server: \(error.localizedDescription)"
            }
        }
    }
}
