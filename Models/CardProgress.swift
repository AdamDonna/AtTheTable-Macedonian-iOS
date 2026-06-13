import SwiftData
import Foundation

@Model
final class CardProgress {
    @Attribute(.unique) var cardId: String
    var box: Int
    var dueDate: Date
    var lastReviewed: Date?
    var correctStreak: Int
    var totalSeen: Int
    var totalCorrect: Int

    init(cardId: String, box: Int = 1, dueDate: Date = .now,
         lastReviewed: Date? = nil, correctStreak: Int = 0,
         totalSeen: Int = 0, totalCorrect: Int = 0) {
        self.cardId = cardId
        self.box = box
        self.dueDate = dueDate
        self.lastReviewed = lastReviewed
        self.correctStreak = correctStreak
        self.totalSeen = totalSeen
        self.totalCorrect = totalCorrect
    }
}