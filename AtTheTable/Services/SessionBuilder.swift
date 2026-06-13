import Foundation
import SwiftData

enum SessionBuilder {
    static func buildSession(for deck: Deck, 
                           progress: [CardProgress], 
                           sessionLimit: Int = 12, 
                           currentDate: Date = .now) -> [Card] {
        let progressMap = Dictionary(uniqueKeysWithValues: progress.map { ($0.cardId, $0) })
        
        var dueCards: [Card] = []
        var newCards: [Card] = []
        
        for card in deck.cards {
            if let cardProgress = progressMap[card.id] {
                if cardProgress.dueDate <= currentDate {
                    dueCards.append(card)
                }
            } else {
                newCards.append(card)
            }
        }
        
        dueCards.sort { card1, card2 in
            let progress1 = progressMap[card1.id]!
            let progress2 = progressMap[card2.id]!
            return progress1.dueDate < progress2.dueDate
        }
        
        dueCards.shuffle()
        newCards.shuffle()
        
        var sessionCards = dueCards
        let remainingSlots = sessionLimit - sessionCards.count
        if remainingSlots > 0 {
            sessionCards.append(contentsOf: newCards.prefix(remainingSlots))
        }
        
        return Array(sessionCards.prefix(sessionLimit))
    }
}