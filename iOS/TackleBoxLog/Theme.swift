import SwiftUI

/// Tackle Box Log unique visual theme.
enum Theme {
    static let accent = Color(red: 0.1843, green: 0.4000, blue: 0.5647)
    static let accentSecondary = Color(red: 0.9098, green: 0.5294, blue: 0.1176)
    static let background = Color(red: 0.0549, green: 0.1020, blue: 0.1412)
    static let card = Color(red: 0.0824, green: 0.1529, blue: 0.2118)
    static let textPrimary = Color(red: 0.9176, green: 0.9490, blue: 0.9725)
    static let textMuted = textPrimary.opacity(0.62)

    static let titleFont = Font.system(.title2, design: .serif).weight(.bold)
    static let headlineFont = Font.system(.headline, design: .rounded).weight(.semibold)
    static let bodyFont = Font.system(.body, design: .default)
    static let captionFont = Font.system(.caption, design: .rounded)

    static let cornerRadius: CGFloat = 16
}

struct CardBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(16)
            .background(Theme.card)
            .cornerRadius(Theme.cornerRadius)
    }
}

extension View {
    func cardStyle() -> some View { modifier(CardBackground()) }
}
