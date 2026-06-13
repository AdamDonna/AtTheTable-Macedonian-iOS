import Foundation

enum Grade {
    case gotIt
    case notYet
}

enum Scheduler {
    static let intervalDays: [Int: Int] = [1: 1, 2: 2, 3: 4, 4: 8, 5: 16]

    static func apply(_ grade: Grade, to progress: CardProgress, on date: Date = .now) {
        progress.totalSeen += 1
        
        switch grade {
        case .gotIt:
            progress.totalCorrect += 1
            progress.correctStreak += 1
            progress.box = min(progress.box + 1, 5)
        case .notYet:
            progress.correctStreak = 0
            progress.box = 1
        }
        
        let days = intervalDays[progress.box] ?? 1
        let startOfDay = Calendar.current.startOfDay(for: date)
        progress.dueDate = Calendar.current.date(byAdding: .day, value: days, to: startOfDay) ?? date
        progress.lastReviewed = date
    }
}