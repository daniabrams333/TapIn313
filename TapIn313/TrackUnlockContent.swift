import SwiftUI

/// "Tech Builder complete!" A trophy, the total bonus, and the track payoff, labeled as a sample idea.
struct TrackUnlockContent: View {
    @Environment(AppStore.self) private var store
    let trackID: String
    let revealed: Bool

    var body: some View {
        if let track = store.track(trackID) {
            let totalBonus = track.levels.reduce(0) { $0 + $1.bonusPoints }

            VStack(spacing: 22) {
                Label("Track complete", systemImage: "flag.checkered")
                    .font(.subheadline.weight(.bold))
                    .reveal(revealed, order: 0)

                HeroTile(rows: PixelArt.unlockTrophy, revealed: revealed)

                VStack(spacing: 6) {
                    Text("\(track.name) complete!")
                        .font(.largeTitle.bold())
                        .accessibilityAddTraits(.isHeader)
                    Text("You finished all \(track.levels.count) levels.")
                        .font(.title3)
                }
                .reveal(revealed, order: 2)

                BonusCountUp(points: totalBonus, suffix: "bonus points in all", revealed: revealed)
                    .reveal(revealed, order: 3)

                UnlockPanel {
                    Label("At the end of the track", systemImage: "flag.checkered")
                        .font(.subheadline.weight(.bold))
                    Text(track.payoff)
                        .font(.body)
                    // Data honesty: payoffs are sample ideas, never a confirmed offer.
                    Text("A sample idea for this demo, not a confirmed event or offer.")
                        .font(.footnote)
                }
                .accessibilityElement(children: .combine)
                .reveal(revealed, order: 4)
            }
        }
    }
}
