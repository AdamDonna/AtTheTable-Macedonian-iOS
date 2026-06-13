import SwiftUI
import SwiftData

@Observable
final class SessionModel {
    let cards: [Card]
    private(set) var index = 0
    var revealed = false
    private(set) var gotItCount = 0
    private(set) var notYetCount = 0
    let context: ModelContext
    
    init(cards: [Card], context: ModelContext) {
        self.cards = cards
        self.context = context
    }
    
    var current: Card? { index < cards.count ? cards[index] : nil }
    var isFinished: Bool { index >= cards.count }
    var progress: Double { cards.isEmpty ? 1.0 : Double(index) / Double(cards.count) }
    
    func reveal() {
        revealed = true
    }
    
    func grade(_ grade: Grade) {
        guard let card = current else { return }
        let progress = fetchOrCreate(cardId: card.id)
        Scheduler.apply(grade, to: progress)
        try? context.save()
        
        if grade == .gotIt {
            gotItCount += 1
        } else {
            notYetCount += 1
        }
        
        index += 1
        revealed = false
    }
    
    private func fetchOrCreate(cardId: String) -> CardProgress {
        let descriptor = FetchDescriptor<CardProgress>(
            predicate: #Predicate { $0.cardId == cardId }
        )
        
        if let existing = try? context.fetch(descriptor).first {
            return existing
        } else {
            let newProgress = CardProgress(cardId: cardId)
            context.insert(newProgress)
            return newProgress
        }
    }
}

struct SessionView: View {
    let deck: Deck
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var allProgress: [CardProgress]
    @State private var sessionModel: SessionModel?
    @State private var showingSummary = false
    @State private var isButtonDisabled = false
    
    var body: some View {
        VStack(spacing: 0) {
            if let model = sessionModel {
                if model.isFinished {
                    SessionSummaryView(
                        totalCards: model.cards.count,
                        gotItCount: model.gotItCount,
                        notYetCount: model.notYetCount,
                        onDismiss: { dismiss() }
                    )
                } else {
                    sessionContent(model: model)
                }
            } else {
                emptySessionView
            }
        }
        .navigationBarBackButtonHidden()
        .onAppear {
            setupSession()
        }
    }
    
    private func sessionContent(model: SessionModel) -> some View {
        VStack(spacing: 0) {
            sessionChrome(model: model)
            
            Spacer()
            
            if let card = model.current {
                FlashcardCard(
                    card: card,
                    revealed: model.revealed,
                    onReveal: { model.reveal() }
                )
                .id(card.id)
            }
            
            Spacer()
            
            actionArea(model: model)
        }
        .padding()
    }
    
    private func sessionChrome(model: SessionModel) -> some View {
        VStack(spacing: 8) {
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text("\(model.index + 1) / \(model.cards.count)")
                    .font(.headline.monospacedDigit())
                    .foregroundColor(.secondary)
            }
            
            ProgressView(value: model.progress)
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
        }
    }
    
    private func actionArea(model: SessionModel) -> some View {
        HStack {
            if model.revealed {
                Button("Not yet") {
                    grade(model: model, grade: .notYet)
                }
                .buttonStyle(.bordered)
                .foregroundColor(.orange)
                .disabled(isButtonDisabled)
                
                Button("Got it") {
                    grade(model: model, grade: .gotIt)
                }
                .buttonStyle(.borderedProminent)
                .disabled(isButtonDisabled)
            } else {
                Spacer()
                
                Button("Show answer") {
                    model.reveal()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .frame(height: 44)
    }
    
    private var emptySessionView: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundColor(.green)
            
            Text("You're all caught up!")
                .font(.title.bold())
            
            Text("Come back tomorrow for more practice.")
                .font(.headline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Back to Home") {
                dismiss()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
    
    private func setupSession() {
        let sessionCards = SessionBuilder.buildSession(for: deck, progress: allProgress)
        if !sessionCards.isEmpty {
            sessionModel = SessionModel(cards: sessionCards, context: modelContext)
        }
    }
    
    private func grade(model: SessionModel, grade: Grade) {
        isButtonDisabled = true
        
        withAnimation(.easeInOut(duration: 0.25)) {
            model.grade(grade)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            isButtonDisabled = false
        }
    }
}

struct FlashcardCard: View {
    let card: Card
    let revealed: Bool
    let onReveal: () -> Void
    
    var body: some View {
        Button(action: { if !revealed { onReveal() } }) {
            VStack(spacing: 20) {
                if revealed {
                    revealedContent
                } else {
                    frontContent
                }
            }
            .frame(maxWidth: .infinity, minHeight: 300)
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.regularMaterial)
                    .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(revealed)
    }
    
    private var frontContent: some View {
        VStack(spacing: 16) {
            Text(card.front)
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.5)
            
            Text(card.roman)
                .font(.title3)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Spacer()
            
            Text("Tap to reveal")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
    }
    
    private var revealedContent: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Text(card.front)
                    .font(.title.bold())
                    .multilineTextAlignment(.center)
                
                Text(card.roman)
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Divider()
            
            VStack(spacing: 8) {
                Text(card.back)
                    .font(.title2.bold())
                    .foregroundColor(.blue)
                    .multilineTextAlignment(.center)
                
                if let note = card.note {
                    Text(note)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.top, 4)
                }
            }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: CardProgress.self, configurations: config)
    
    let sampleDeck = Deck(
        id: "sample",
        cards: [
            Card(id: "1", front: "Здраво", roman: "Zdravo", back: "Hello", audio: nil, note: nil, tags: []),
            Card(id: "2", front: "Благодарам", roman: "Blagodaram", back: "Thank you", audio: nil, note: nil, tags: [])
        ]
    )
    
    return SessionView(deck: sampleDeck)
        .modelContainer(container)
}