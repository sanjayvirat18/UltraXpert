import SwiftUI

struct TutorialsListView: View {
    @AppStorage("themeColor") private var themeColorName = "Blue"
    private var themeColor: Color { ThemeManager.shared.color(for: themeColorName) }
    struct TutorialVideo: Identifiable {
        let id = UUID()
        let title: String
        let duration: String
        let thumbnail: String // System icon for mock
    }
    
    let videos = [
        TutorialVideo(title: "Getting Started with UltraXpert", duration: "2:30", thumbnail: "play.circle.fill"),
        TutorialVideo(title: "Advanced Noise Reduction", duration: "5:45", thumbnail: "waveform.path.ecg"),
        TutorialVideo(title: "Exporting High-Res Reports", duration: "3:15", thumbnail: "doc.text.fill"),
        TutorialVideo(title: "Managing Patient History", duration: "4:00", thumbnail: "person.2.fill")
    ]
    
    var body: some View {
        List(videos) { video in
            NavigationLink {
                VideoPlayerMockView(title: video.title)
            } label: {
                HStack(spacing: 16) {
                    Image(systemName: video.thumbnail)
                        .font(.system(size: 40))
                        .foregroundColor(themeColor)
                        .frame(width: 80, height: 60)
                        .background(themeColor.opacity(0.1))
                        .cornerRadius(8)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(video.title)
                            .font(.headline)
                        
                        Text(video.duration)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical, 8)
            }
        }
        .navigationTitle("Video Tutorials")
    }
}

// Mock Player
struct VideoPlayerMockView: View {
    let title: String
    
    var body: some View {
        VStack {
            Rectangle()
                .fill(Color.black)
                .aspectRatio(16/9, contentMode: .fit)
                .overlay(
                    Image(systemName: "play.fill")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                )
            
            Text(title)
                .font(.title2)
                .padding()
            
            Spacer()
        }
        .navigationTitle("Playing")
    }
}

#Preview {
    NavigationStack {
        TutorialsListView()
    }
}
