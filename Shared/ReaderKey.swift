import Foundation

enum ReaderKey {
    static let allowedCharacters = CharacterSet(charactersIn: "23456789ACDEFGHJKLMNPRSTUVWXYZ")
    static func sanitize(_ value: String) -> String {
        let filtered = value.uppercased().filter { character in character.unicodeScalars.allSatisfy { allowedCharacters.contains($0) } }
        return String(filtered.prefix(4))
    }
    static func isValid(_ value: String) -> Bool {
        let uppercased = value.uppercased()
        return uppercased.count == 4 && sanitize(uppercased) == uppercased
    }
}
