import XCTest
@testable import AtTheTable

final class ValidationTests: XCTestCase {
    
    func testAlphabetDataIntegrity() throws {
        guard let url = Bundle.main.url(forResource: "alphabet", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let alphabet = try? JSONDecoder().decode([AlphabetLetter].self, from: data) else {
            XCTFail("Failed to load alphabet.json")
            return
        }
        
        // Verify we have all 31 letters
        XCTAssertEqual(alphabet.count, 31, "Should have exactly 31 letters")
        
        // Check for distinctive letters
        let distinctiveLetters = alphabet.filter { $0.distinctive }
        let expectedDistinctive = ["ѓ", "ќ", "ѕ", "џ", "љ", "њ", "ј"]
        XCTAssertEqual(distinctiveLetters.count, expectedDistinctive.count, "Should have 7 distinctive letters")
        
        // Verify all letters have required fields
        for letter in alphabet {
            XCTAssertFalse(letter.upper.isEmpty, "Upper case should not be empty")
            XCTAssertFalse(letter.lower.isEmpty, "Lower case should not be empty")
            XCTAssertFalse(letter.roman.isEmpty, "Roman should not be empty")
            XCTAssertFalse(letter.soundHint.isEmpty, "Sound hint should not be empty")
            XCTAssertFalse(letter.example.cyrillic.isEmpty, "Example cyrillic should not be empty")
        }
    }
    
    func testCurriculumDataIntegrity() throws {
        guard let url = Bundle.main.url(forResource: "curriculum", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let curriculum = try? JSONDecoder().decode(Curriculum.self, from: data) else {
            XCTFail("Failed to load curriculum.json")
            return
        }
        
        // Verify content version
        XCTAssertEqual(curriculum.contentVersion, 1, "Content version should be 1")
        
        // Verify levels
        XCTAssertEqual(curriculum.levels.count, 6, "Should have 6 levels")
        
        // Check level ordering
        let sortedLevels = curriculum.levels.sorted { $0.order < $1.order }
        for (index, level) in sortedLevels.enumerated() {
            XCTAssertEqual(level.order, index, "Level order should be sequential")
        }
        
        // Verify decks
        XCTAssertEqual(curriculum.decks.count, 5, "Should have 5 decks (excluding alphabet)")
        
        // Check that each phrase level has a corresponding deck
        for level in curriculum.levels where level.type == .phrases {
            guard let deckId = level.deckId else {
                XCTFail("Phrase level \(level.id) should have a deckId")
                continue
            }
            
            let deck = curriculum.decks.first { $0.id == deckId }
            XCTAssertNotNil(deck, "Deck \(deckId) should exist")
            XCTAssertGreaterThan(deck?.cards.count ?? 0, 0, "Deck should have cards")
        }
    }
    
    func testLeitnerScheduling() {
        let progress = CardProgress(cardId: "test-card")
        
        // Test "Got It" progression
        Scheduler.apply(.gotIt, to: progress)
        XCTAssertEqual(progress.box, 2, "Should advance to box 2")
        XCTAssertEqual(progress.correctStreak, 1, "Correct streak should be 1")
        XCTAssertEqual(progress.totalCorrect, 1, "Total correct should be 1")
        XCTAssertEqual(progress.totalSeen, 1, "Total seen should be 1")
        
        // Test "Not Yet" reset
        Scheduler.apply(.notYet, to: progress)
        XCTAssertEqual(progress.box, 1, "Should reset to box 1")
        XCTAssertEqual(progress.correctStreak, 0, "Correct streak should reset")
        XCTAssertEqual(progress.totalCorrect, 1, "Total correct should remain 1")
        XCTAssertEqual(progress.totalSeen, 2, "Total seen should be 2")
        
        // Test box cap at 5
        progress.box = 5
        Scheduler.apply(.gotIt, to: progress)
        XCTAssertEqual(progress.box, 5, "Should cap at box 5")
    }
    
    func testSessionBuilder() {
        let cards = [
            Card(id: "1", front: "Test 1", roman: "test1", back: "Test 1", audio: nil, note: nil, tags: []),
            Card(id: "2", front: "Test 2", roman: "test2", back: "Test 2", audio: nil, note: nil, tags: []),
            Card(id: "3", front: "Test 3", roman: "test3", back: "Test 3", audio: nil, note: nil, tags: [])
        ]
        
        let deck = Deck(id: "test-deck", cards: cards)
        let progress: [CardProgress] = []
        
        let session = SessionBuilder.buildSession(for: deck, progress: progress, sessionLimit: 2)
        
        // Should limit to session limit
        XCTAssertLesssThanOrEqual(session.count, 2, "Should respect session limit")
        
        // Should return new cards when no progress exists
        XCTAssertGreaterThan(session.count, 0, "Should return cards for new deck")
    }
}

// MARK: - Test Helper Extensions

extension XCTestCase {
    func loadTestAlphabet() -> [AlphabetLetter] {
        guard let url = Bundle.main.url(forResource: "alphabet", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let alphabet = try? JSONDecoder().decode([AlphabetLetter].self, from: data) else {
            XCTFail("Failed to load test alphabet")
            return []
        }
        return alphabet
    }
    
    func loadTestCurriculum() -> Curriculum? {
        guard let url = Bundle.main.url(forResource: "curriculum", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let curriculum = try? JSONDecoder().decode(Curriculum.self, from: data) else {
            XCTFail("Failed to load test curriculum")
            return nil
        }
        return curriculum
    }
}