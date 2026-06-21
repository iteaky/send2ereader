import Foundation
import Combine

@MainActor
final class ShareSendViewModel: ObservableObject {
    enum State: Equatable {
        case loading, ready, processing, success
        case uploading(Double)
        case failure(String)
    }

    @Published var key = ""
    @Published var file: ReaderFile?
    @Published var options = SendOptions()
    @Published var state: State = .loading

    private weak var context: NSExtensionContext?
    private let onFinish: () -> Void
    private let onCancel: () -> Void

    init(
        extensionContext: NSExtensionContext?,
        onFinish: @escaping () -> Void,
        onCancel: @escaping () -> Void
    ) {
        context = extensionContext
        self.onFinish = onFinish
        self.onCancel = onCancel
        Task { await loadFile() }
    }

    var canSend: Bool {
        ReaderKey.isValid(key) && file != nil && state == .ready
    }

    func updateKey(_ value: String) {
        key = ReaderKey.sanitize(value)
    }

    func cancel() {
        cleanup()
        onCancel()
    }

    func finish() {
        cleanup()
        onFinish()
    }

    private func loadFile() async {
        let items = (context?.inputItems ?? []).compactMap { $0 as? NSExtensionItem }
        let providers = items.reduce(into: [NSItemProvider]()) { result, item in
            result.append(contentsOf: item.attachments ?? [])
        }

        guard let provider = providers.first else {
            state = .failure("No file was shared.")
            return
        }

        for identifier in provider.registeredTypeIdentifiers {
            guard let copied = try? await copyFile(from: provider, identifier: identifier) else { continue }
            guard ReaderFile.isSupported(url: copied) else {
                try? FileManager.default.removeItem(at: copied)
                continue
            }
            file = ReaderFile(url: copied, isManagedCopy: true)
            options.optimizeEPUB = copied.pathExtension.lowercased() == "epub"
            state = .ready
            return
        }
        state = .failure("Unsupported file type.")
    }

    private func copyFile(from provider: NSItemProvider, identifier: String) async throws -> URL {
        try await withCheckedThrowingContinuation { continuation in
            provider.loadFileRepresentation(forTypeIdentifier: identifier) { url, error in
                if let error { continuation.resume(throwing: error); return }
                guard let url else { continuation.resume(throwing: UploadError.noContent); return }
                do {
                    let destination = FileManager.default.temporaryDirectory
                        .appendingPathComponent("ReaderDrop-\(UUID().uuidString)-\(url.lastPathComponent)")
                    try FileManager.default.copyItem(at: url, to: destination)
                    continuation.resume(returning: destination)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    private func cleanup() {
        if let file, file.isManagedCopy { try? FileManager.default.removeItem(at: file.url) }
    }
}
