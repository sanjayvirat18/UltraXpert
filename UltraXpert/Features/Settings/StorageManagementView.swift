import SwiftUI

struct StorageManagementView: View {
    var body: some View {
        List {
            Section(header: Text("Usage")) {
                HStack {
                    Text("Used Storage")
                    Spacer()
                    Text("12.5 GB / 50 GB")
                        .foregroundColor(.secondary)
                }
                ProgressView(value: 0.25)
            }
            
            Section(header: Text("Options")) {
                Button("Clear Cache") {
                    // Clear cache
                }
                .foregroundColor(.red)
                
                Toggle("Auto-Delete Old Reports", isOn: .constant(false))
            }
        }
        .navigationTitle("Storage")
    }
}
