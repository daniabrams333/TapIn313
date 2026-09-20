import SwiftUI

/// A map pin: a circle with an icon. A star marks the Up next site, and a number marks a site
/// with several programs, so neither meaning relies on color alone. `isCompact` is for the map key.
struct MapPin: View {
    let symbol: String
    let count: Int
    let isUpNext: Bool
    var isCompact = false

    private var side: CGFloat { isCompact ? 30 : 44 }
    private var badgeOffset: CGFloat { isCompact ? 4 : 6 }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Image(systemName: symbol)
                .font(isCompact ? .caption.weight(.semibold) : .body.weight(.semibold))
                .foregroundStyle(isUpNext ? Theme.onHighlight : Theme.onPrimary)
                .frame(width: side, height: side)
                .background(isUpNext ? Theme.highlight : Theme.primary, in: Circle())
                .overlay(Circle().strokeBorder(.white, lineWidth: 2))
                .shadow(radius: isCompact ? 0 : 2)

            if isUpNext {
                Image(systemName: "star.fill")
                    .font(.caption2)
                    .foregroundStyle(Theme.onHighlight)
                    .padding(isCompact ? 2 : 4)
                    .background(Theme.highlight, in: Circle())
                    .overlay(Circle().strokeBorder(Theme.onHighlight, lineWidth: 1))
                    .offset(x: badgeOffset, y: -badgeOffset)
            } else if count > 1 {
                Text("\(count)")
                    .font(.caption2.bold())
                    .foregroundStyle(Theme.onHighlight)
                    .frame(minWidth: 20, minHeight: 20)
                    .background(Theme.highlight, in: Circle())
                    .offset(x: badgeOffset, y: -badgeOffset)
            }
        }
    }
}
