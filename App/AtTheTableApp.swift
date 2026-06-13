import SwiftUI
import SwiftData

@main
struct AtTheTableApp: App {
    var body: some Scene {
        WindowGroup {
            HomeView()
        }
        .modelContainer(for: CardProgress.self)
    }
}