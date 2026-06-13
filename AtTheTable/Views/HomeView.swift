import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allProgress: [CardProgress]
    @AppStorage("hasSeenAlphabetIntro") private var hasSeenAlphabetIntro = false
    @State private var contentStore = ContentStore.shared
    @State private var showingSettings = false
    @State private var showingAlphabet = false
    @State private var selectedLevel: Level?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                headerView
                
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(sortedLevels, id: \.id) { level in
                            LevelRowView(
                                level: level,
                                isUnlocked: isUnlocked(level),
                                isComplete: isComplete(level),
                                progress: progressForLevel(level),
                                onTap: { handleLevelTap(level) }
                            )
                        }
                    }
                    .padding()
                }
            }
            .navigationDestination(isPresented: $showingAlphabet) {
                AlphabetView()
            }
            .navigationDestination(item: $selectedLevel) { level in
                if let deckId = level.deckId,
                   let deck = contentStore.deck(for: deckId) {
                    SessionView(deck: deck)
                } else {
                    Text("Level not available")
                }
            }
            .navigationDestination(isPresented: $showingSettings) {
                SettingsView()
            }
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading) {
                    Text("At the Table")
                        .font(.largeTitle.bold())
                        .foregroundColor(.primary)
                    Text("на маса")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                HStack(spacing: 16) {
                    Button(action: { showingAlphabet = true }) {
                        Image(systemName: "character.book.closed")
                            .font(.title2)
                    }
                    
                    Button(action: { showingSettings = true }) {
                        Image(systemName: "gearshape")
                            .font(.title2)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top)
            
            Divider()
        }
        .background(.regularMaterial)
    }
    
    private var sortedLevels: [Level] {
        contentStore.curriculum?.levels.sorted { $0.order < $1.order } ?? []
    }
    
    private func isUnlocked(_ level: Level) -> Bool {
        Mastery.isLevelUnlocked(level, allProgress: allProgress, contentStore: contentStore, hasSeenAlphabetIntro: hasSeenAlphabetIntro)
    }
    
    private func isComplete(_ level: Level) -> Bool {
        Mastery.isLevelComplete(level, allProgress: allProgress, contentStore: contentStore, hasSeenAlphabetIntro: hasSeenAlphabetIntro)
    }
    
    private func progressForLevel(_ level: Level) -> Double {
        guard level.type == .phrases,
              let deckId = level.deckId,
              let deck = contentStore.deck(for: deckId),
              let minBox = level.unlock.minBox else {
            return hasSeenAlphabetIntro ? 1.0 : 0.0
        }
        
        return Mastery.calculateMastery(for: deck, progress: allProgress, minBox: minBox)
    }
    
    private func handleLevelTap(_ level: Level) {
        guard isUnlocked(level) else { return }
        
        if level.type == .alphabet {
            showingAlphabet = true
        } else {
            selectedLevel = level
        }
    }
}

struct LevelRowView: View {
    let level: Level
    let isUnlocked: Bool
    let isComplete: Bool
    let progress: Double
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(level.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(level.subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    if !isUnlocked {
                        Text("Complete previous level to unlock")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
                
                Spacer()
                
                VStack(spacing: 8) {
                    if isComplete {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.title2)
                    } else if isUnlocked {
                        ProgressRing(progress: progress)
                            .frame(width: 32, height: 32)
                    } else {
                        Image(systemName: "lock.fill")
                            .foregroundColor(.secondary)
                            .font(.title2)
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isUnlocked ? .regularMaterial : .ultraThinMaterial)
            )
            .opacity(isUnlocked ? 1.0 : 0.6)
        }
        .disabled(!isUnlocked)
        .buttonStyle(PlainButtonStyle())
    }
}

struct ProgressRing: View {
    let progress: Double
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(.quaternary, lineWidth: 3)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(.blue, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut, value: progress)
            
            Text("\(Int(progress * 100))%")
                .font(.caption2.bold())
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    HomeView()
        .modelContainer(for: CardProgress.self, inMemory: true)
}