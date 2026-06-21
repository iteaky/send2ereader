import Foundation

struct HistoryItem: Identifiable, Codable, Equatable {
    enum ContentKind: String, Codable {
        case file
        case link
    }

    let id: UUID
    let date: Date
    let kind: ContentKind
    let displayName: String
    let detail: String
    let storedFilePath: String?
    let serverURL: String

    init(
        id: UUID = UUID(),
        date: Date = .now,
        kind: ContentKind,
        displayName: String,
        detail: String,
        storedFilePath: String?,
        serverURL: String
    ) {
        self.id = id
        self.date = date
        self.kind = kind
        self.displayName = displayName
        self.detail = detail
        self.storedFilePath = storedFilePath
        self.serverURL = serverURL
    }

    var storedFileURL: URL? {
        storedFilePath.map(URL.init(fileURLWithPath:))
    }
}
