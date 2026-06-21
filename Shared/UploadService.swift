import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

struct UploadRequest: Sendable {
    let serverURL: URL
    let key: String
    let file: ReaderFile?
    let link: URL?
    let options: SendOptions
}

struct UploadResponse: Sendable { let message: String }

struct UploadService: Sendable {
    func upload(_ input: UploadRequest, progress: @escaping @Sendable (Double) -> Void) async throws -> UploadResponse {
        guard ReaderKey.isValid(input.key) else { throw UploadError.invalidKey }
        guard input.file != nil || input.link != nil else { throw UploadError.noContent }
        if let file = input.file, !ReaderFile.isSupported(url: file.url) { throw UploadError.unsupportedFile }
        var multipart = try MultipartFormData()
        try multipart.addField(name: "key", value: ReaderKey.sanitize(input.key))
        if input.options.optimizeEPUB { try multipart.addField(name: "kepubify", value: "on"); try multipart.addField(name: "kindlegen", value: "on") }
        if input.options.cropPDFMargins { try multipart.addField(name: "pdfcropmargins", value: "on") }
        if input.options.transliterateFilename { try multipart.addField(name: "transliteration", value: "on") }
        if let link = input.link { try multipart.addField(name: "url", value: link.absoluteString) }
        if let file = input.file { try multipart.addFile(name: "file", file: file) }
        let bodyURL = try multipart.finalize()
        defer { try? FileManager.default.removeItem(at: bodyURL) }
        var request = URLRequest(url: input.serverURL.appendingPathComponent("upload"))
        request.httpMethod = "POST"; request.timeoutInterval = 600; request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        request.setValue("multipart/form-data; boundary=\(multipart.boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("ReaderDrop/1.0 (iOS)", forHTTPHeaderField: "User-Agent")
        let delegate = UploadProgressDelegate(handler: progress)
        let configuration = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForRequest = 600; configuration.timeoutIntervalForResource = 900
        #if !canImport(FoundationNetworking)
        configuration.waitsForConnectivity = true
        #endif
        let session = URLSession(configuration: configuration)
        let (data, response) = try await session.upload(for: request, fromFile: bodyURL, delegate: delegate)
        guard let http = response as? HTTPURLResponse else { throw UploadError.invalidResponse }
        let message = (String(data: data, encoding: .utf8) ?? "").replacingOccurrences(of: "<br/>", with: "\n", options: .caseInsensitive).trimmingCharacters(in: .whitespacesAndNewlines)
        guard (200...299).contains(http.statusCode) else { throw UploadError.server(statusCode: http.statusCode, message: message) }
        return UploadResponse(message: message)
    }
}

private final class UploadProgressDelegate: NSObject, URLSessionTaskDelegate, @unchecked Sendable {
    private let handler: @Sendable (Double) -> Void
    init(handler: @escaping @Sendable (Double) -> Void) { self.handler = handler }
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        guard totalBytesExpectedToSend > 0 else { return }
        handler(min(max(Double(totalBytesSent) / Double(totalBytesExpectedToSend), 0), 1))
    }
}
