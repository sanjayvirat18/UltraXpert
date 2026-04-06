import SwiftUI
import Combine

// MARK: - Notification Screen
struct NotificationScreen: View {

    @Environment(\.dismiss) var dismiss
    @AppStorage("themeColor") private var themeColorName = "Blue"
    private var themeColor: Color { ThemeManager.shared.color(for: themeColorName) }

    @StateObject private var viewModel = NotificationViewModel()
    @State private var selectedFilter: NotificationFilter = .all

    var body: some View {
        List {

            // MARK: Header Actions
            Section {
                Picker("Filter", selection: $selectedFilter) {
                    ForEach(NotificationFilter.allCases, id: \.self) { filter in
                        Text(filter.title).tag(filter)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.vertical, 6)

                HStack(spacing: 12) {
                    Button {
                        Task { await viewModel.markAllRead() }
                    } label: {
                        Label("Mark All Read", systemImage: "checkmark.circle.fill")
                    }
                    .buttonStyle(.bordered)

                    Button(role: .destructive) {
                        Task { await viewModel.clearAll() }
                    } label: {
                        Label("Clear All", systemImage: "trash.fill")
                    }
                    .buttonStyle(.bordered)
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }

            // MARK: Notifications List
            Section(header: Text("Notifications").fontWeight(.bold)) {

                if viewModel.isLoading {
                    HStack {
                        Spacer()
                        ProgressView("Loading…")
                        Spacer()
                    }
                    .padding(.vertical, 30)

                } else if let error = viewModel.errorMessage {
                    VStack(spacing: 10) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 35))
                            .foregroundColor(.orange)
                        Text("Could not load notifications")
                            .font(.headline)
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        Button("Retry") {
                            Task { await viewModel.fetchNotifications() }
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(themeColor)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 30)

                } else if filteredNotifications.isEmpty {
                    VStack(spacing: 10) {
                        Image(systemName: "bell.slash.fill")
                            .font(.system(size: 35))
                            .foregroundColor(.secondary)
                        Text("No Notifications")
                            .font(.headline)
                        Text("You're all caught up.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 30)

                } else {
                    ForEach(filteredNotifications) { notification in
                        NotificationRow(
                            notification: notification,
                            onTap: {
                                Task { await viewModel.markAsRead(notification) }
                            },
                            onMarkRead: {
                                Task { await viewModel.markAsRead(notification) }
                            },
                            onDelete: {
                                Task { await viewModel.delete(notification) }
                            }
                        )
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.fetchNotifications()
        }
        .refreshable {
            await viewModel.fetchNotifications()
        }
    }

    // MARK: - Filtered Data
    private var filteredNotifications: [AppNotification] {
        let sorted = viewModel.notifications.sorted { $0.date > $1.date }
        switch selectedFilter {
        case .all:    return sorted
        case .unread: return sorted.filter { !$0.isRead }
        }
    }
}

// MARK: - ViewModel
@MainActor
class NotificationViewModel: ObservableObject {

    @Published var notifications: [AppNotification] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let service: NotificationServiceProtocol

    init(service: NotificationServiceProtocol = NotificationService()) {
        self.service = service
    }

    private func updateUnreadCount() {
        let unread = notifications.filter { !$0.isRead }.count
        UserDefaults.standard.set(unread, forKey: "unreadNotificationCount")
    }

    func fetchNotifications() async {
        isLoading = true
        errorMessage = nil
        do {
            let responses = try await service.getNotifications()
            self.notifications = responses.map { AppNotification(from: $0) }
            updateUnreadCount()
        } catch {
            self.errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func markAsRead(_ notification: AppNotification) async {
        guard !notification.isRead else { return }
        do {
            let updated = try await service.markAsRead(id: notification.backendID)
            if let idx = notifications.firstIndex(where: { $0.backendID == notification.backendID }) {
                notifications[idx].isRead = updated.is_read
                updateUnreadCount()
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func markAllRead() async {
        do {
            try await service.markAllRead()
            for idx in notifications.indices { notifications[idx].isRead = true }
            updateUnreadCount()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func delete(_ notification: AppNotification) async {
        do {
            try await service.deleteNotification(id: notification.backendID)
            notifications.removeAll { $0.backendID == notification.backendID }
            updateUnreadCount()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func clearAll() async {
        do {
            try await service.clearAllNotifications()
            notifications.removeAll()
            updateUnreadCount()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

// MARK: - Notification Detail View
struct NotificationDetailView: View {
    let notification: AppNotification

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack(spacing: 16) {
                    Image(systemName: notification.icon)
                        .font(.system(size: 40))
                        .foregroundColor(ThemeManager.shared.color(for: (UserDefaults.standard.string(forKey: "themeColor") ?? "Blue")))
                        .frame(width: 80, height: 80)
                        .background(ThemeManager.shared.color(for: (UserDefaults.standard.string(forKey: "themeColor") ?? "Blue")).opacity(0.1))
                        .cornerRadius(20)

                    VStack(alignment: .leading, spacing: 6) {
                        Text(notification.title)
                            .font(.title2)
                            .bold()
                        Text(notification.timeText)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.bottom)

                Divider()

                Text("Message")
                    .font(.headline)

                Text(notification.message)
                    .font(.body)
                    .lineSpacing(6)

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Notification")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Notification Row
struct NotificationRow: View {

    let notification: AppNotification
    let onTap: () -> Void
    let onMarkRead: () -> Void
    let onDelete: () -> Void

    var body: some View {
        ZStack {
            NavigationLink(destination: NotificationDetailView(notification: notification)) {
                EmptyView()
            }
            .opacity(0.0)

            Button {
                onTap()
            } label: {
                HStack(alignment: .top, spacing: 12) {

                    Image(systemName: notification.icon)
                        .font(.system(size: 20))
                        .foregroundColor(notification.isRead ? .secondary : ThemeManager.shared.color(for: (UserDefaults.standard.string(forKey: "themeColor") ?? "Blue")))
                        .frame(width: 30)

                    VStack(alignment: .leading, spacing: 4) {

                        HStack {
                            Text(notification.title)
                                .font(.headline)
                                .foregroundColor(.primary)

                            Spacer()

                            Text(notification.timeText)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Text(notification.message)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(2)

                        if !notification.isRead {
                            Text("Unread")
                                .font(.caption2)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(ThemeManager.shared.color(for: (UserDefaults.standard.string(forKey: "themeColor") ?? "Blue")).opacity(0.15))
                                .cornerRadius(10)
                                .padding(.top, 4)
                        }
                    }
                }
                .padding(.vertical, 6)
            }
            .buttonStyle(.plain)
        }
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {

            Button(role: .destructive) {
                onDelete()
            } label: {
                Label("Delete", systemImage: "trash.fill")
            }

            Button {
                onMarkRead()
            } label: {
                Label("Read", systemImage: "checkmark.circle.fill")
            }
            .tint(ThemeManager.shared.color(for: (UserDefaults.standard.string(forKey: "themeColor") ?? "Blue")))
        }
    }
}

// MARK: - Filter Enum
enum NotificationFilter: CaseIterable {
    case all, unread

    var title: String {
        switch self {
        case .all:    return "All"
        case .unread: return "Unread"
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationStack {
        NotificationScreen()
    }
}
