import Foundation
import Combine

@MainActor
final class HistoryStore: ObservableObject {
    @Published private(set) var items: [HistoryItem] = []

    private let fileURL: URL
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init() {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("ReaderDrop", isDirectory: true)
        try? FileManager.default.createDirectory(at: base, withIntermediateDirectories: true)
        fileURL = base.appendingPathComponent("history.json")
        encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        load()
    }

    func add(_ item: HistoryItem) {
        items.insert(item, at: 0)
        if items.count > 200 {
            items = Array(items.prefix(200))
        }
        save()
    }

    func delete(at offsets: IndexSet) {
        let removed = offsets.compactMap { index in
            items.indices.contains(index) ? items[index] : nil
        }
        for index in offsets.sorted(by: >) where items.indices.contains(index) {
            items.remove(at: index)
        }
        removed.compactMap(\.storedFileURL).forEach { try? FileManager.default.removeItem(at: $0) }
        save()
    }

    func delete(_ item: HistoryItem) {
        items.removeAll { $0.id == item.id }
        if let url = item.storedFileURL { try? FileManager.default.removeItem(at: url) }
        save()
    }

    func clear() {
        items.compactMap(\.storedFileURL).forEach { try? FileManager.default.removeItem(at: $0) }
        items = []
        save()
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL),
              let decoded = try? decoder.decode([HistoryItem].self, from: data) else { return }
        items = decoded
    }

    private func save() {
        guard let data = try? encoder.encode(items) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }
}
