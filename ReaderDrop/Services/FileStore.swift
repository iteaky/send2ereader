import Foundation

struct FileStore {
    private let fileManager = FileManager.default

    func importFile(from sourceURL: URL) throws -> ReaderFile {
        guard ReaderFile.isSupported(url: sourceURL) else { throw UploadError.unsupportedFile }

        let didAccess = sourceURL.startAccessingSecurityScopedResource()
        defer {
            if didAccess { sourceURL.stopAccessingSecurityScopedResource() }
        }

        let importsDirectory = fileManager.temporaryDirectory
            .appendingPathComponent("ReaderDropImports", isDirectory: true)
        try fileManager.createDirectory(at: importsDirectory, withIntermediateDirectories: true)

        let destination = importsDirectory
            .appendingPathComponent("\(UUID().uuidString)-\(sanitized(sourceURL.lastPathComponent))")
        if fileManager.fileExists(atPath: destination.path) {
            try fileManager.removeItem(at: destination)
        }
        try fileManager.copyItem(at: sourceURL, to: destination)
        return ReaderFile(url: destination, name: sourceURL.lastPathComponent, isManagedCopy: true)
    }

    func keepCopy(of file: ReaderFile) throws -> URL {
        let directory = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("ReaderDrop/SentFiles", isDirectory: true)
        try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        let destination = directory
            .appendingPathComponent("\(UUID().uuidString)-\(sanitized(file.name))")
        try fileManager.copyItem(at: file.url, to: destination)
        return destination
    }

    func removeManagedFile(_ file: ReaderFile?) {
        guard let file, file.isManagedCopy else { return }
        try? fileManager.removeItem(at: file.url)
    }

    private func sanitized(_ name: String) -> String {
        let invalid = CharacterSet(charactersIn: "/\\:\0")
        return name.components(separatedBy: invalid).joined(separator: "_")
    }
}
