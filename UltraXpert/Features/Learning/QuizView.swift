import SwiftUI

struct QuizView: View {
    
    @State private var currentQuestionIndex = 0
    @State private var selectedOption: Int? = nil
    @State private var showResult = false
    @State private var score = 0
    @AppStorage("themeColor") private var themeColorName = "Blue"
    private var themeColor: Color { ThemeManager.shared.color(for: themeColorName) }
    
    struct Question {
        let text: String
        let options: [String]
        let correctIndex: Int
    }
    
    let questions = [
        Question(
            text: "What is the primary benefit of 'Edge Sharpening' in ultrasound enhancement?",
            options: ["Reduces file size", "Defines organ boundaries clearly", "Increases image brightness", "Removes color Doppler"],
            correctIndex: 1
        ),
        Question(
            text: "Which enhancement technique is best for reducing 'speckle noise'?",
            options: ["Contrast Enhancement", "Edge Sharpening", "Noise Reduction", "Gamma Correction"],
            correctIndex: 2
        ),
        Question(
            text: "When should you use 'High Contrast' mode?",
            options: ["To smooth out grain", "To save battery", "To distinguish subtle tissue differences", "Always"],
            correctIndex: 2
        )
    ]
    
    var body: some View {
        VStack {
            if currentQuestionIndex < questions.count {
                // Question View
                quizContent
            } else {
                // Result View
                resultContent
            }
        }
        .padding()
        .navigationTitle("Knowledge Check")
    }
    
    var quizContent: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Question \(currentQuestionIndex + 1) of \(questions.count)")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(questions[currentQuestionIndex].text)
                .font(.title3)
                .fontWeight(.bold)
            
            ForEach(0..<4) { index in
                Button(action: {
                    selectOption(index)
                }) {
                    HStack {
                        Text(questions[currentQuestionIndex].options[index])
                            .fontWeight(.medium)
                        Spacer()
                        if selectedOption == index {
                            Image(systemName: "checkmark.circle.fill")
                        } else {
                            Image(systemName: "circle")
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    .foregroundColor(selectedOption == index ? themeColor : .primary)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(selectedOption == index ? themeColor : Color.clear, lineWidth: 2)
                    )
                }
                .disabled(showResult) // Disable after selection processed (optional logic)
            }
            
            Spacer()
            
            Button("Next Question") {
                nextQuestion()
            }
            .buttonStyle(.borderedProminent)
            .disabled(selectedOption == nil)
            .frame(maxWidth: .infinity)
        }
    }
    
    var resultContent: some View {
        VStack(spacing: 20) {
            Image(systemName: score == questions.count ? "star.fill" : "hand.thumbsup.fill")
                .font(.system(size: 60))
                .foregroundColor(.yellow)
            
            Text("Quiz Completed!")
                .font(.title)
                .bold()
            
            Text("You scored \(score) out of \(questions.count)")
                .font(.title2)
            
            Button("Restart Quiz") {
                restartQuiz()
            }
            .buttonStyle(.bordered)
        }
    }
    
    func selectOption(_ index: Int) {
        selectedOption = index
    }
    
    func nextQuestion() {
        if let selected = selectedOption {
            if selected == questions[currentQuestionIndex].correctIndex {
                score += 1
            }
        }
        
        selectedOption = nil
        currentQuestionIndex += 1
    }
    
    func restartQuiz() {
        currentQuestionIndex = 0
        score = 0
        selectedOption = nil
    }
}

#Preview {
    NavigationStack {
        QuizView()
    }
}
