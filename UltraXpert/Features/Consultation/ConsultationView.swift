import SwiftUI

struct ConsultationView: View {
    @State private var messageText = ""
    @AppStorage("themeColor") private var themeColorName = "Blue"
    private var themeColor: Color { ThemeManager.shared.color(for: themeColorName) }
    @State private var messages: [Message] = [
        Message(id: UUID(), text: "Hello Dr. Smith, I have uploaded the scan.", isCurrentUser: false, timestamp: "09:41 AM"),
        Message(id: UUID(), text: "Great, I see it. The resolution looks much better after enhancement.", isCurrentUser: true, timestamp: "09:42 AM"),
        Message(id: UUID(), text: "Do you need any more angles?", isCurrentUser: false, timestamp: "09:43 AM"),
        Message(id: UUID(), text: "No, this is sufficient for the diagnosis. I will generate the report shortly.", isCurrentUser: true, timestamp: "09:45 AM")
    ]
    
    struct Message: Identifiable {
        let id: UUID
        let text: String
        let isCurrentUser: Bool
        let timestamp: String
    }
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(messages) { message in
                        HStack {
                            if message.isCurrentUser {
                                Spacer()
                                VStack(alignment: .trailing) {
                                    Text(message.text)
                                        .padding()
                                        .background(themeColor)
                                        .foregroundColor(.white)
                                        .cornerRadius(16)
                                    Text(message.timestamp)
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                            } else {
                                VStack(alignment: .leading) {
                                    Text(message.text)
                                        .padding()
                                        .background(Color(.secondarySystemBackground))
                                        .foregroundColor(.primary)
                                        .cornerRadius(16)
                                    Text(message.timestamp)
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                            }
                        }
                    }
                }
                .padding()
            }
            
            // Input Area
            HStack {
                TextField("Type a message...", text: $messageText)
                    .padding(10)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(20)
                
                Button {
                    sendMessage()
                } label: {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 20))
                        .foregroundColor(themeColor)
                        .padding(10)
                        .background(themeColor.opacity(0.1))
                        .clipShape(Circle())
                }
                .disabled(messageText.isEmpty)
            }
            .padding()
            .background(Color(.systemBackground))
        }
        .navigationTitle("Consultation")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func sendMessage() {
        guard !messageText.isEmpty else { return }
        let newMessage = Message(id: UUID(), text: messageText, isCurrentUser: true, timestamp: DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .short))
        messages.append(newMessage)
        messageText = ""
    }
}

#Preview {
    NavigationStack {
        ConsultationView()
    }
}
