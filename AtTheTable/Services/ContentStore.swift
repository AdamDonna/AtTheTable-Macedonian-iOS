import Foundation

@Observable
final class ContentStore {
    static let shared = ContentStore()
    
    private(set) var alphabet: [AlphabetLetter] = []
    private(set) var curriculum: Curriculum?
    
    private init() {
        loadContent()
    }
    
    private func loadContent() {
        loadAlphabet()
        loadCurriculum()
    }
    
    private func loadAlphabet() {
        guard let url = Bundle.main.url(forResource: "alphabet", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let letters = try? JSONDecoder().decode([AlphabetLetter].self, from: data) else {
            print("Failed to load alphabet.json")
            return
        }
        self.alphabet = letters
    }
    
    private func loadCurriculum() {
        guard let url = Bundle.main.url(forResource: "curriculum", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let curriculum = try? JSONDecoder().decode(Curriculum.self, from: data) else {
            print("Failed to load curriculum.json")
            return
        }
        self.curriculum = curriculum
    }
    
    func deck(for id: String) -> Deck? {
        return curriculum?.decks.first { $0.id == id }
    }
    
    func level(for id: String) -> Level? {
        return curriculum?.levels.first { $0.id == id }
    }
}