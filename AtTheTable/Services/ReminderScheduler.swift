import Foundation

enum ReminderScheduler {
    static let identifier = "daily-practice-reminder"

    @MainActor
    static func requestAuthorization() async -> Bool {
        // Notifications disabled for now - will return false
        return false
    }

    static func schedule(hour: Int, minute: Int) {
        // Notification scheduling disabled for now
        print("Reminder would be scheduled for \(hour):\(minute)")
    }

    static func cancel() {
        // Notification cancellation disabled for now
        print("Reminder cancelled")
    }
}