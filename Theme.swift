import SwiftUI

extension Color {
    /// Create a color from a hex value like 0x14213D.
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

/// Brand colors. Use these for fills and accents. For text, use .primary and
/// .secondary so light and dark mode both work.
enum Theme {
    /// Deep navy. Headers, hero cards, staff mode.
    static let ink = Color(hex: 0x14213D)
    /// Burnt orange. Primary buttons and highlights. White text on it passes 4.5:1.
    static let signal = Color(hex: 0xC2410C)
    /// Warm gold. Points and badges. Pair with ink text, never white.
    static let gold = Color(hex: 0xFFC533)
    /// Lake teal. Secondary accent, confirmations, the map.
    static let lake = Color(hex: 0x1D7A8C)
    /// Cool light gray. Card and section backgrounds in light mode.
    static let mist = Color(hex: 0xEEF2F7)

    /// Avatar colors, picked by Student.colorIndex.
    static let avatarColors: [Color] = [
        Color(hex: 0xC2410C), Color(hex: 0x1D7A8C), Color(hex: 0x6D4AA8),
        Color(hex: 0x2B6CB0), Color(hex: 0x2F855A), Color(hex: 0xB7791F)
    ]
}
