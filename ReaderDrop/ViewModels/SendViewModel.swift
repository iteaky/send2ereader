import Foundation
import Combine

@MainActor
final class SendViewModel: ObservableObject {
    enum ContentMode: String, CaseIterable, Identifiable {
        case file, link
        var id: String { rawValue }
    }

    enum State: Equatable {
        case idle, preparing, processing
        case uploading(Double)
        case success(String)
        case failure(String)
    }

    @Published var key = ""
    @Published var mode: ContentMode = .file
    @Published var selectedFile: ReaderFile?
    @Published var linkText = ""
    @Published var options = SendOptions()
    @Published var state: State = .idle

    let fileStore = FileStore()
    let uploadService = UploadService()
    private var didLoadDefaults = false

    var isSending: Bool {
        switch state {
        case .preparing, .uploading, .processing: true
        default: false
        }
    }

    var validLink: URL? {
        let value = linkText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let url = URL(string: value),
              let scheme = url.scheme?.lowercased(),
              ["http", "https"].contains(scheme),
              url.host != nil else { return nil }
        return url
    }

    var canSend: Bool {
        guard ReaderKey.isValid(key), !isSending else { return false }
        switch mode {
        case .file: return selectedFile != nil
        case .link: return validLink != nil
        }
    }

    func loadDefaults(from settings: AppSettingsStore) {
        guard !didLoadDefaults else { return }
        options = settings.defaultOptions
        didLoadDefaults = true
    }

    func updateKey(_ value: String) {
        key = ReaderKey.sanitize(value)
    }

    func selectFile(from url: URL) {
        do {
            fileStore.removeManagedFile(selectedFile)
            selectedFile = try fileStore.importFile(from: url)
            mode = .file
            state = .idle
        } catch {
            state = .failure(error.localizedDescription)
        }
    }

    func clearContent() {
        fileStore.removeManagedFile(selectedFile)
        selectedFile = nil
        linkText = ""
        state = .idle
    }
}
