import Foundation

struct MultipartFormData {
    let boundary: String
    private let outputURL: URL
    private var handle: FileHandle?

    init() throws {
        boundary = "ReaderDrop-\(UUID().uuidString)"
        outputURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("ReaderDropMultipart-\(UUID().uuidString)")
        _ = FileManager.default.createFile(atPath: outputURL.path, contents: nil)
        handle = try FileHandle(forWritingTo: outputURL)
    }

    mutating func addField(name: String, value: String) throws {
        try write("--\(boundary)\r\n")
        try write("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n")
        try write("\(value)\r\n")
    }

    mutating func addFile(name: String, file: ReaderFile) throws {
        guard FileManager.default.fileExists(atPath: file.url.path) else {
            throw UploadError.fileAccess(NSLocalizedString("error.fileUnavailable", comment: ""))
        }
        try write("--\(boundary)\r\n")
        try write("Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(escaped(file.name))\"\r\n")
        try write("Content-Type: \(ReaderFile.mimeType(for: file.fileExtension))\r\n\r\n")
        let input = try FileHandle(forReadingFrom: file.url)
        defer { try? input.close() }
        while true {
            let chunk = try input.read(upToCount: 1_048_576) ?? Data()
            if chunk.isEmpty { break }
            try handle?.write(contentsOf: chunk)
        }
        try write("\r\n")
    }

    mutating func finalize() throws -> URL {
        try write("--\(boundary)--\r\n")
        try handle?.close(); handle = nil
        return outputURL
    }

    private mutating func write(_ string: String) throws {
        guard let data = string.data(using: .utf8) else { return }
        try handle?.write(contentsOf: data)
    }

    private func escaped(_ value: String) -> String {
        value.replacingOccurrences(of: "\\", with: "_")
            .replacingOccurrences(of: "\"", with: "_")
            .replacingOccurrences(of: "\r", with: "_")
            .replacingOccurrences(of: "\n", with: "_")
    }
}
