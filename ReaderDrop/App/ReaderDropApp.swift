import SwiftUI

@main
struct ReaderDropApp: App {
    @StateObject private var settings = AppSettingsStore()
    @StateObject private var history = HistoryStore()
    @StateObject private var router = AppRouter()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(settings)
                .environmentObject(history)
                .environmentObject(router)
        }
    }
}
