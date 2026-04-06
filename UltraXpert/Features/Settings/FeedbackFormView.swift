import SwiftUI

struct FeedbackFormView: View {
    @State private var feedbackText = ""
    @State private var rating = 5
    @State private var email = ""
    @State private var showSuccess = false
    
    var body: some View {
        Form {
            Section(header: Text("Experience")) {
                Picker("Rating", selection: $rating) {
                    ForEach(1...5, id: \.self) { i in
                        Text("\(i) Stars").tag(i)
                    }
                }
                .pickerStyle(.segmented)
            }
            
            Section(header: Text("Message")) {
                TextEditor(text: $feedbackText)
                    .frame(height: 150)
                    .overlay(
                        Group {
                            if feedbackText.isEmpty {
                                Text("Tell us what you think...")
                                    .foregroundColor(.gray.opacity(0.5))
                                    .padding(.leading, 4)
                                    .padding(.top, 8)
                                    .frame(maxWidth: .infinity, alignment: .topLeading)
                            }
                        }
                    )
            }
            
            Section(header: Text("Contact (Optional)")) {
                TextField("Email Address", text: $email)
                    .keyboardType(.emailAddress)
            }
            
            Section {
                Button("Submit Feedback") {
                    showSuccess = true
                }
                .disabled(feedbackText.isEmpty)
            }
        }
        .navigationTitle("Send Feedback")
        .alert("Thank You!", isPresented: $showSuccess) {
            Button("OK") {}
        } message: {
            Text("We appreciate your input.")
        }
    }
}
