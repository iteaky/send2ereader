import SwiftUI

enum AppTheme {
    static let accent = Color(red: 0.34, green: 0.28, blue: 0.92)
    static let accentSecondary = Color(red: 0.20, green: 0.68, blue: 0.88)
    static let success = Color(red: 0.16, green: 0.65, blue: 0.43)
    static let warning = Color(red: 0.96, green: 0.57, blue: 0.18)
    static let cardRadius: CGFloat = 24
    static var background: Color { Color(uiColor: .systemGroupedBackground) }
    static var cardBackground: Color { Color(uiColor: .secondarySystemGroupedBackground) }
}
