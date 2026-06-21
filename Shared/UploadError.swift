import Foundation

enum UploadError: LocalizedError, Equatable {
    case invalidServerURL, invalidKey, unsupportedFile, noContent, invalidResponse
    case server(statusCode: Int, message: String)
    case fileAccess(String)
    var errorDescription: String? {
        switch self {
        case .invalidServerURL: NSLocalizedString("error.invalidServerURL", comment: "")
        case .invalidKey: NSLocalizedString("error.invalidKey", comment: "")
        case .unsupportedFile: NSLocalizedString("error.unsupportedFile", comment: "")
        case .noContent: NSLocalizedString("error.noContent", comment: "")
        case .invalidResponse: NSLocalizedString("error.invalidResponse", comment: "")
        case let .server(_, message): message.isEmpty ? NSLocalizedString("error.server", comment: "") : message
        case let .fileAccess(message): message
        }
    }
}
