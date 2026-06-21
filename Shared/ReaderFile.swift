import Foundation

struct ReaderFile: Identifiable, Equatable, Sendable {
    let id: UUID
    let url: URL
    let name: String
    let size: Int64
    let isManagedCopy: Bool
    init(id: UUID = UUID(), url: URL, name: String? = nil, size: Int64? = nil, isManagedCopy: Bool = false) {
        self.id = id; self.url = url; self.name = name ?? url.lastPathComponent; self.size = size ?? Self.fileSize(at: url); self.isManagedCopy = isManagedCopy
    }
    var fileExtension: String { url.pathExtension.lowercased() }
    var formattedSize: String { ByteCountFormatter.string(fromByteCount: size, countStyle: .file) }
    var symbolName: String {
        switch fileExtension { case "epub", "mobi": "books.vertical.fill"; case "pdf": "doc.richtext.fill"; case "cbz", "cbr": "rectangle.stack.fill"; case "txt", "html": "doc.text.fill"; default: "doc.fill" }
    }
    static let supportedExtensions = Set(["epub", "mobi", "pdf", "txt", "html", "cbz", "cbr"])
    static func isSupported(url: URL) -> Bool { supportedExtensions.contains(url.pathExtension.lowercased()) }
    static func mimeType(for fileExtension: String) -> String {
        switch fileExtension.lowercased() { case "epub": "application/epub+zip"; case "mobi": "application/x-mobipocket-ebook"; case "pdf": "application/pdf"; case "cbz": "application/vnd.comicbook+zip"; case "cbr": "application/vnd.comicbook-rar"; case "html": "text/html"; case "txt": "text/plain"; default: "application/octet-stream" }
    }
    private static func fileSize(at url: URL) -> Int64 { Int64((try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0) }
}
