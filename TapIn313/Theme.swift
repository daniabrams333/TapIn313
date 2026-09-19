import SwiftUI

extension Color {
    /// Create a color from a hex value like 0x1D3A6B.
    init(hex: UInt32) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: 1
        )
    }
}

/// Palette from the City of Detroit Brand Guide Standards, Version 2.0 (June 2026).
/// This is an independent project, not an official City app. Do not use the City logo
/// or the "Rise Higher" tagline in the app.
///
/// Contrast pairings (WCAG 2.1 AA needs 4.5:1 for text, 3:1 for large text and graphics):
///   White on Rise Blue        about 11.2:1  fine for text
///   White on City Green       about 11.0:1  fine for text
///   Rise Blue on Light Green  about 6.8:1   fine for text
///   Rise Blue on Accent Yellow about 6.4:1  fine for text
///   Black on Spirit Green     about 6.0:1   fine for text
///   White on Spirit Green     about 3.5:1   NOT fine for text, graphics only
///   White on Accent Yellow    about 1.8:1   never
/// Rule of thumb: dark text on Yellow, Light Green, and Spirit Green. White text on
/// Rise Blue and City Green. Never put small text in Spirit Green on white.
enum Theme {

    // MARK: Brand colors (exact values from the guide)

    static let riseBlue = Color(hex: 0x1D3A6B)
    static let spiritGreen = Color(hex: 0x279989)
    static let cityGreen = Color(hex: 0x004445)
    static let lightGreen = Color(hex: 0x9FD5B3)
    static let accentYellow = Color(hex: 0xFEB70D)

    // MARK: Roles

    /// App tint, primary buttons, student mode headers. Pair with white text.
    static let primary = riseBlue
    /// Staff mode headers and controls, so staff mode looks clearly different. Pair with white text.
    static let staff = cityGreen
    /// Progress bars, completed checkmarks, and other graphics. Not for small text.
    static let progress = spiritGreen
    /// Soft backgrounds like a completed level card. Pair with Rise Blue text.
    static let softFill = lightGreen
    /// Points, badges, and calls to action. The guide says use it sparingly, for key
    /// moments. Pair with Rise Blue text, never white.
    static let highlight = accentYellow

    // MARK: Text colors that go with the fills above

    static let onPrimary = Color.white
    static let onStaff = Color.white
    static let onSoftFill = riseBlue
    static let onHighlight = riseBlue

    // MARK: Avatars (picked by Student.colorIndex)

    static let avatarStyles: [(background: Color, text: Color)] = [
        (riseBlue, .white),
        (cityGreen, .white),
        (lightGreen, riseBlue),
        (accentYellow, riseBlue),
        (spiritGreen, .black)
    ]

    static func avatarStyle(_ index: Int) -> (background: Color, text: Color) {
        avatarStyles[index % avatarStyles.count]
    }
}
