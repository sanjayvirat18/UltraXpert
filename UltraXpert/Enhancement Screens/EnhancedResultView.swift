import SwiftUI

struct EnhancedResultView: View {

    let originalImage: UIImage
    let enhancedImage: UIImage

    @State private var slider: Double = 0.5

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 18) {

                Text("Enhanced Result")
                    .font(.title2).bold()
                    .frame(maxWidth: .infinity, alignment: .leading)

                ZStack {
                    Image(uiImage: originalImage)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 18))

                    Image(uiImage: enhancedImage)
                        .resizable()
                        .scaledToFit()
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .mask(
                            GeometryReader { geo in
                                Rectangle()
                                    .frame(width: geo.size.width * slider)
                            }
                        )
                }
                .frame(height: 280)

                Slider(value: $slider, in: 0...1)

                VStack(spacing: 12) {
                    Button {
                        // later: save to patient record
                    } label: {
                        Text("Save Scan")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.black)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }

                    Button {
                        // later: generate report
                    } label: {
                        Text("Generate Report")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                }
            }
            .padding()
        }
    }
}
