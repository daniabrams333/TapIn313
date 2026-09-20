import SwiftUI

/// "New badge: Century Club." The pixel badge pops in with twinkling sparkles around it.
struct BadgeUnlockContent: View {
    @Environment(AppStore.self) private var store
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let badge: Badge
    let revealed: Bool
    @State private var twinkle = false

    /// Where each sparkle sits around the badge, and its size.
    private let sparkles: [(x: CGFloat, y: CGFloat, size: CGFloat, color: Color)] = [
        (-122, -104, 26, Theme.highlight),
        (126, -70, 20, .white),
        (-128, 70, 20, .white),
        (118, 106, 26, Theme.highlight)
    ]

    var body: some View {
        let earned = store.earnedBadgeIDs(for: store.currentStudentID).count

        VStack(spacing: 22) {
            Label("New badge", systemImage: "rosette")
                .font(.subheadline.weight(.bold))
                .reveal(revealed, order: 0)

            ZStack {
                ForEach(sparkles.indices, id: \.self) { index in
                    let sparkle = sparkles[index]
                    PixelSprite(rows: PixelArt.unlockSparkle, colors: ["#": sparkle.color])
                        .frame(width: sparkle.size, height: sparkle.size)
                        .offset(x: sparkle.x, y: sparkle.y)
                        .scaleEffect(twinkle ? 1.25 : 0.7)
                        .opacity(revealed ? (twinkle ? 1 : 0.5) : 0)
                        .animation(
                            reduceMotion ? nil : .easeInOut(duration: 0.9).repeatForever(autoreverses: true).delay(0.2 * Double(index)),
                            value: twinkle
                        )
                }
                BadgeIcon(badge: badge, isEarned: true, size: 168)
                    .popIn(revealed)
            }
            .frame(height: 240)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("\(badge.name) badge")

            VStack(spacing: 6) {
                Text(badge.name)
                    .font(.largeTitle.bold())
                    .accessibilityAddTraits(.isHeader)
                Text(badge.detail)
                    .font(.title3)
            }
            .reveal(revealed, order: 2)

            Text("\(earned) of \(store.badges.count) badges earned")
                .font(.subheadline.weight(.semibold))
                .reveal(revealed, order: 3)
        }
        .onAppear {
            if !reduceMotion { twinkle = true }
        }
    }
}
