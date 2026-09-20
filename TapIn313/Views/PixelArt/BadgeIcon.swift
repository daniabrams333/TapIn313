import SwiftUI

/// A badge in pixel art. Earned badges are full color on a yellow tile.
/// Locked badges are gray with a lock, so the state is never shown by color alone.
struct BadgeIcon: View {
    let badge: Badge
    let isEarned: Bool
    @ScaledMetric private var side: CGFloat

    init(badge: Badge, isEarned: Bool, size: CGFloat = 64) {
        self.badge = badge
        self.isEarned = isEarned
        _side = ScaledMetric(wrappedValue: size, relativeTo: .title3)
    }

    private var tileColor: Color { isEarned ? Theme.highlight : Color(.systemGray5) }

    private var palette: [Character: Color] {
        isEarned
            ? ["#": Theme.onHighlight, "w": .white, "g": Theme.staff]
            : ["#": Color(.systemGray), "w": Color(.systemGray2), "g": Color(.systemGray)]
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ZStack {
                tileColor
                if let art = PixelArt.badges[badge.id] {
                    PixelSprite(rows: art, colors: palette)
                        .padding(side * 0.12)
                } else {
                    // Falls back to the badge's SF Symbol if no pixel art has been drawn yet.
                    Image(systemName: badge.symbol)
                        .font(.title2)
                        .foregroundStyle(isEarned ? Theme.onHighlight : Color(.systemGray))
                }
            }
            .frame(width: side, height: side)
            .clipShape(RoundedRectangle(cornerRadius: side * 0.14))

            if !isEarned {
                Image(systemName: "lock.fill")
                    .font(.caption2)
                    .foregroundStyle(.white)
                    .padding(5)
                    .background(Color(.systemGray), in: Circle())
                    .offset(x: 4, y: 4)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(badge.name) badge, \(isEarned ? "earned" : "locked")")
    }
}
