import Foundation
import Combine

@MainActor
final class AppSettingsStore: ObservableObject {
    private enum Keys {
        static let serverURL = "serverURL"
        static let optimizeEPUB = "optimizeEPUB"
        static let cropPDFMargins = "cropPDFMargins"
        static let transliterateFilename = "transliterateFilename"
        static let keepSentFiles = "keepSentFiles"
    }

    static let defaultServerURL = "https://send2ereader.net"

    @Published var serverURLString: String {
        didSet { defaults.set(serverURLString, forKey: Keys.serverURL) }
    }
    @Published var optimizeEPUB: Bool {
        didSet { defaults.set(optimizeEPUB, forKey: Keys.optimizeEPUB) }
    }
    @Published var cropPDFMargins: Bool {
        didSet { defaults.set(cropPDFMargins, forKey: Keys.cropPDFMargins) }
    }
    @Published var transliterateFilename: Bool {
        didSet { defaults.set(transliterateFilename, forKey: Keys.transliterateFilename) }
    }
    @Published var keepSentFiles: Bool {
        didSet { defaults.set(keepSentFiles, forKey: Keys.keepSentFiles) }
    }

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        serverURLString = defaults.string(forKey: Keys.serverURL) ?? Self.defaultServerURL
        optimizeEPUB = defaults.object(forKey: Keys.optimizeEPUB) as? Bool ?? true
        cropPDFMargins = defaults.object(forKey: Keys.cropPDFMargins) as? Bool ?? false
        transliterateFilename = defaults.object(forKey: Keys.transliterateFilename) as? Bool ?? false
        keepSentFiles = defaults.object(forKey: Keys.keepSentFiles) as? Bool ?? false
    }

    var serverURL: URL? {
        let trimmed = serverURLString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard var components = URLComponents(string: trimmed),
              let scheme = components.scheme?.lowercased(),
              ["https", "http"].contains(scheme),
              components.host != nil else { return nil }
        var path = components.path
        while path.count > 1 && path.hasSuffix("/") {
            path.removeLast()
        }
        components.path = path
        return components.url
    }

    var defaultOptions: SendOptions {
        SendOptions(
            optimizeEPUB: optimizeEPUB,
            cropPDFMargins: cropPDFMargins,
            transliterateFilename: transliterateFilename
        )
    }

    func reset() {
        serverURLString = Self.defaultServerURL
        optimizeEPUB = true
        cropPDFMargins = false
        transliterateFilename = false
        keepSentFiles = false
    }
}
