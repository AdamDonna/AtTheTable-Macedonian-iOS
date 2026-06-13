import SwiftUI

struct AlphabetView: View {
    @AppStorage("hasSeenAlphabetIntro") private var hasSeenAlphabetIntro = false
    @State private var contentStore = ContentStore.shared
    @State private var currentLetterIndex = 0
    @State private var showingRecognitionCheck = false
    @State private var recognitionQuestions: [RecognitionQuestion] = []
    @State private var currentQuestionIndex = 0
    @State private var selectedAnswer: String?
    @State private var showingResult = false
    @State private var correctCount = 0
    @State private var quizResults: [QuizResult] = []
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            if hasSeenAlphabetIntro {
                referenceMode
            } else if showingRecognitionCheck {
                recognitionCheckView
            } else {
                teachingFlow
            }
        }
        .navigationTitle("Азбука")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var teachingFlow: some View {
        VStack {
            ProgressView(value: Double(currentLetterIndex + 1), total: Double(contentStore.alphabet.count))
                .padding()
            
            Text("Letter \(currentLetterIndex + 1) of \(contentStore.alphabet.count)")
                .font(.caption)
                .foregroundColor(.secondary)
            
            if currentLetterIndex < contentStore.alphabet.count {
                let letter = contentStore.alphabet[currentLetterIndex]
                
                LetterDetailView(letter: letter)
                    .id(letter.id)
                
                HStack(spacing: 20) {
                    if currentLetterIndex > 0 {
                        Button("Previous") {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                currentLetterIndex -= 1
                            }
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    Spacer()
                    
                    Button(currentLetterIndex == contentStore.alphabet.count - 1 ? "Take Quiz" : "Next") {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            if currentLetterIndex == contentStore.alphabet.count - 1 {
                                startRecognitionCheck()
                            } else {
                                currentLetterIndex += 1
                            }
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            }
            
            Spacer()
        }
    }
    
    private var referenceMode: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 16) {
                ForEach(contentStore.alphabet, id: \.id) { letter in
                    LetterCardView(letter: letter)
                }
            }
            .padding()
        }
    }
    
    private var recognitionCheckView: some View {
        VStack {
            if currentQuestionIndex < recognitionQuestions.count {
                let question = recognitionQuestions[currentQuestionIndex]
                
                VStack(spacing: 24) {
                    Text("Question \(currentQuestionIndex + 1) of \(recognitionQuestions.count)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("What sound does this letter make?")
                        .font(.headline)
                    
                    Text(question.letter.upper)
                        .font(.system(size: 72, weight: .light))
                        .foregroundColor(.primary)
                    
                    VStack(spacing: 12) {
                        ForEach(question.options, id: \.self) { option in
                            Button(action: { selectAnswer(option) }) {
                                HStack {
                                    Text(option)
                                        .foregroundColor(.primary)
                                    Spacer()
                                    if selectedAnswer == option {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.blue)
                                    }
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(selectedAnswer == option ? .blue.opacity(0.2) : Color(.systemGray6))
                                )
                            }
                        }
                    }
                    
                    if selectedAnswer != nil {
                        Button("Next") {
                            nextQuestion()
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.top)
                    }
                    
                    Spacer()
                }
                .padding()
                .animation(.easeInOut, value: selectedAnswer)
            } else {
                recognitionResultView
            }
        }
    }
    
    private var recognitionResultView: some View {
        ScrollView {
            VStack(spacing: 24) {
                Image(systemName: correctCount >= 6 ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.system(size: 64))
                    .foregroundColor(correctCount >= 6 ? .green : .orange)
                
                Text(correctCount >= 6 ? "Excellent!" : "Good try!")
                    .font(.largeTitle.bold())
                
                Text("You got \(correctCount) out of \(recognitionQuestions.count) correct")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                // Show detailed results
                VStack(alignment: .leading, spacing: 12) {
                    Text("Quiz Results:")
                        .font(.headline)
                        .padding(.top)
                    
                    ForEach(Array(quizResults.enumerated()), id: \.offset) { index, result in
                        HStack {
                            VStack(alignment: .leading) {
                                HStack {
                                    Text(result.letter.upper)
                                        .font(.title2.bold())
                                    Image(systemName: result.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                                        .foregroundColor(result.isCorrect ? .green : .red)
                                }
                                
                                if !result.isCorrect {
                                    HStack {
                                        Text("Your answer:")
                                            .foregroundColor(.secondary)
                                        Text(result.userAnswer)
                                            .foregroundColor(.red)
                                    }
                                    .font(.caption)
                                    
                                    HStack {
                                        Text("Correct answer:")
                                            .foregroundColor(.secondary)
                                        Text(result.correctAnswer)
                                            .foregroundColor(.green)
                                    }
                                    .font(.caption)
                                }
                            }
                            Spacer()
                        }
                        .padding(.vertical, 4)
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 8).fill(.regularMaterial))
                
                if correctCount >= 6 {
                    Text("You've completed the alphabet! Phrase lessons are now unlocked.")
                        .multilineTextAlignment(.center)
                        .padding()
                } else {
                    Text("Review the alphabet and try again when you're ready.")
                        .multilineTextAlignment(.center)
                        .padding()
                }
                
                HStack(spacing: 16) {
                    if correctCount < 6 {
                        Button("Review Alphabet") {
                            resetToTeaching()
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    Button(correctCount >= 6 ? "Continue" : "Back to Home") {
                        if correctCount >= 6 {
                            hasSeenAlphabetIntro = true
                        }
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding()
        }
    }
    
    private func startRecognitionCheck() {
        let distinctiveLetters = contentStore.alphabet.filter { $0.distinctive }
        let shuffledLetters = distinctiveLetters.shuffled().prefix(8)
        
        recognitionQuestions = shuffledLetters.map { letter in
            let wrongOptions = contentStore.alphabet
                .filter { $0.id != letter.id }
                .map { $0.roman }
                .shuffled()
                .prefix(3)
            
            let options = (wrongOptions + [letter.roman]).shuffled()
            return RecognitionQuestion(letter: letter, options: Array(options))
        }
        
        currentQuestionIndex = 0
        correctCount = 0
        quizResults = []
        showingRecognitionCheck = true
    }
    
    private func selectAnswer(_ answer: String) {
        selectedAnswer = answer
    }
    
    private func nextQuestion() {
        // Only count the answer when user submits by clicking Next
        if let answer = selectedAnswer {
            let question = recognitionQuestions[currentQuestionIndex]
            let isCorrect = answer == question.letter.roman
            
            // Track the result
            let result = QuizResult(
                letter: question.letter,
                userAnswer: answer,
                correctAnswer: question.letter.roman,
                isCorrect: isCorrect
            )
            quizResults.append(result)
            
            if isCorrect {
                correctCount += 1
            }
        }
        
        selectedAnswer = nil
        currentQuestionIndex += 1
    }
    
    private func resetToTeaching() {
        showingRecognitionCheck = false
        currentLetterIndex = 0
        selectedAnswer = nil
    }
}

struct LetterDetailView: View {
    let letter: AlphabetLetter
    
    var body: some View {
        VStack(spacing: 32) {
            VStack(spacing: 16) {
                HStack(spacing: 24) {
                    Text(letter.upper)
                        .font(.system(size: 72, weight: .light))
                    Text(letter.lower)
                        .font(.system(size: 72, weight: .light))
                }
                
                Text(letter.roman)
                    .font(.title.bold())
                    .foregroundColor(.blue)
                
                if letter.distinctive {
                    Text("⭐ Distinctive Macedonian letter")
                        .font(.caption.bold())
                        .foregroundColor(.orange)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(.orange.opacity(0.2)))
                }
            }
            
            VStack(spacing: 12) {
                Text(letter.soundHint)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                
                VStack(spacing: 4) {
                    Text(letter.example.cyrillic)
                        .font(.title2.bold())
                    Text(letter.example.roman)
                        .font(.callout)
                        .foregroundColor(.secondary)
                    Text(letter.example.en)
                        .font(.callout)
                        .foregroundColor(.blue)
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 8).fill(.regularMaterial))
            }
        }
        .padding()
    }
}

struct LetterCardView: View {
    let letter: AlphabetLetter
    @State private var showingDetail = false
    
    var body: some View {
        Button(action: { showingDetail = true }) {
            VStack(spacing: 8) {
                Text(letter.upper)
                    .font(.largeTitle)
                Text(letter.roman)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(RoundedRectangle(cornerRadius: 8).fill(.regularMaterial))
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showingDetail) {
            NavigationStack {
                LetterDetailView(letter: letter)
                    .navigationTitle("Letter \(letter.upper)")
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationBarBackButtonHidden()
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Done") {
                                showingDetail = false
                            }
                        }
                    }
            }
        }
    }
}

struct RecognitionQuestion {
    let letter: AlphabetLetter
    let options: [String]
}

struct QuizResult {
    let letter: AlphabetLetter
    let userAnswer: String
    let correctAnswer: String
    let isCorrect: Bool
}

#Preview {
    AlphabetView()
}