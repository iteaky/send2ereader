import SwiftUI

struct HistoryView: View {
    @EnvironmentObject private var history: HistoryStore

    var body: some View {
        NavigationStack {
            List {
                ForEach(history.items) { item in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.displayName).font(.headline)
                        Text(item.detail).font(.subheadline).foregroundStyle(.secondary)
                        Text(item.date, style: .date).font(.caption).foregroundStyle(.tertiary)
                    }
                }
                .onDelete(perform: history.delete)
            }
            .overlay {
                if history.items.isEmpty {
                    ContentUnavailableView("history.empty.title", systemImage: "clock", description: Text("history.empty.message"))
                }
            }
            .navigationTitle("history.title")
            .toolbar {
                if !history.items.isEmpty {
                    Button("history.clear", role: .destructive) { history.clear() }
                }
            }
        }
    }
}
