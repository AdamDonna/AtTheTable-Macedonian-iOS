import Foundation

// MARK: - Alphabet Content

struct AlphabetLetter: Codable, Identifiable {
    let id: String
    let upper: String
    let lower: String
    let roman: String
    let soundHint: String
    let example: Example
    let distinctive: Bool
    
    struct Example: Codable {
        let cyrillic: String
        let roman: String
        let en: String
    }
}

// MARK: - Curriculum Content

struct Curriculum: Codable {
    let contentVersion: Int
    let levels: [Level]
    let decks: [Deck]
}

enum LevelType: String, Codable, Hashable {
    case alphabet
    case phrases
}

enum UnlockType: String, Codable, Hashable {
    case none
    case levelMastery
}

struct Unlock: Codable, Hashable {
    let type: UnlockType
    let levelId: String?
    let threshold: Double?
    let minBox: Int?
}

struct Level: Codable, Identifiable, Hashable {
    let id: String
    let order: Int
    let title: String
    let subtitle: String
    let type: LevelType
    let deckId: String?
    let unlock: Unlock
}

struct Deck: Codable, Identifiable {
    let id: String
    let cards: [Card]
}

struct Card: Codable, Identifiable {
    let id: String
    let front: String
    let roman: String
    let back: String
    let audio: String?
    let note: String?
    let tags: [String]
}