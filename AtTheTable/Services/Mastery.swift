import Foundation
import SwiftData

enum Mastery {
    static func calculateMastery(for deck: Deck, progress: [CardProgress], minBox: Int) -> Double {
        let progressMap = Dictionary(uniqueKeysWithValues: progress.map { ($0.cardId, $0) })
        
        let masteredCount = deck.cards.reduce(0) { count, card in
            if let cardProgress = progressMap[card.id], cardProgress.box >= minBox {
                return count + 1
            }
            return count
        }
        
        return Double(masteredCount) / Double(deck.cards.count)
    }
    
    static func isLevelUnlocked(_ level: Level, 
                              allProgress: [CardProgress], 
                              contentStore: ContentStore,
                              hasSeenAlphabetIntro: Bool) -> Bool {
        switch level.unlock.type {
        case .none:
            return true
        case .levelMastery:
            guard let prerequisiteLevelId = level.unlock.levelId,
                  let threshold = level.unlock.threshold,
                  let minBox = level.unlock.minBox,
                  let prerequisiteLevel = contentStore.level(for: prerequisiteLevelId) else {
                return false
            }
            
            if prerequisiteLevel.type == .alphabet {
                return hasSeenAlphabetIntro
            }
            
            guard let deckId = prerequisiteLevel.deckId,
                  let deck = contentStore.deck(for: deckId) else {
                return false
            }
            
            let mastery = calculateMastery(for: deck, progress: allProgress, minBox: minBox)
            return mastery >= threshold
        }
    }
    
    static func isLevelComplete(_ level: Level,
                               allProgress: [CardProgress],
                               contentStore: ContentStore,
                               hasSeenAlphabetIntro: Bool) -> Bool {
        if level.type == .alphabet {
            return hasSeenAlphabetIntro
        }
        
        guard let deckId = level.deckId,
              let deck = contentStore.deck(for: deckId),
              let minBox = level.unlock.minBox else {
            return false
        }
        
        let mastery = calculateMastery(for: deck, progress: allProgress, minBox: minBox)
        return mastery >= (level.unlock.threshold ?? 0.8)
    }
}