import SwiftUI
import Combine

struct ExportDownloadsView: View {
    @Environment(\.dismiss) var dismiss
    @AppStorage("themeColor") private var themeColorName = "Blue"
    private var themeColor: Color { ThemeManager.shared.color(for: themeColorName) }
    
    @StateObject private var viewModel = DownloadsViewModel()
    
    var body: some View {
        List {
            if viewModel.isLoading {
                HStack {
                    Spacer()
                    ProgressView("Loading Downloads...")
                    Spacer()
                }
                .listRowBackground(Color.clear)
            } else if viewModel.downloads.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "icloud.and.arrow.down")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    Text("No Downloads Yet")
                        .font(.headline)
                    Text("Your exported reports will appear here.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
                .listRowBackground(Color.clear)
            } else {
                ForEach(viewModel.downloads) { download in
                    DownloadRow(download: download) {
                        if let urlString = download.fileURL, let url = URL(string: urlString) {
                            UIApplication.shared.open(url)
                        }
                    }
                }
                .onDelete(perform: viewModel.deleteDownload)
            }
        }
        .navigationTitle("Downloads")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.fetchDownloads()
        }
        .refreshable {
            await viewModel.fetchDownloads()
        }
    }
}

class DownloadsViewModel: ObservableObject {
    @Published var downloads: [AppNotification] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let service: NotificationServiceProtocol
    
    init(service: NotificationServiceProtocol = NotificationService()) {
        self.service = service
    }
    
    @MainActor
    func fetchDownloads() async {
        isLoading = true
        errorMessage = nil
        do {
            let responses = try await service.getDownloads()
            self.downloads = responses.map { AppNotification(from: $0) }
        } catch {
            self.errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    @MainActor
    func deleteDownload(at offsets: IndexSet) {
        offsets.forEach { index in
            let download = downloads[index]
            Task {
                do {
                    try await service.deleteNotification(id: download.backendID)
                } catch {
                    print("Failed to delete download: \(error)")
                }
            }
        }
        downloads.remove(atOffsets: offsets)
    }
}

struct DownloadRow: View {
    let download: AppNotification
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.1))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: fileIcon(for: download.title))
                        .font(.system(size: 20))
                        .foregroundColor(.blue)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(download.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(download.message)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    
                    Text(download.timeText)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "arrow.down.circle.fill")
                    .foregroundColor(.blue)
                    .font(.title3)
            }
            .padding(.vertical, 4)
        }
    }
    
    private func fileIcon(for title: String) -> String {
        if title.contains("PDF") { return "doc.richtext.fill" }
        if title.contains("CSV") { return "tablecells.fill" }
        if title.contains("JPEG") || title.contains("Images") { return "photo.fill" }
        if title.contains("DICOM") { return "doc.append.fill" }
        return "doc.fill"
    }
}

#Preview {
    NavigationStack {
        ExportDownloadsView()
    }
}
