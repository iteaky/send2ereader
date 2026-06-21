import Foundation

struct SendOptions: Codable, Equatable, Sendable {
    var optimizeEPUB: Bool = true
    var cropPDFMargins: Bool = false
    var transliterateFilename: Bool = false
}
