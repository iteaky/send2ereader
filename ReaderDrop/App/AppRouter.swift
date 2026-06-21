import Foundation
import Combine

@MainActor
final class AppRouter: ObservableObject {
    enum Tab: Hashable {
        case send
        case history
        case settings
    }

    @Published var selectedTab: Tab = .send
    @Published var incomingFileURL: URL?
    @Published var incomingLink: URL?

    func openFile(_ url: URL) {
        incomingFileURL = url
        selectedTab = .send
    }

    func openLink(_ url: URL) {
        incomingLink = url
        selectedTab = .send
    }
}
