import SwiftUI

/// "Explore complete!" A flag, the bonus counting up, the path with that step lit, and what comes next.
struct LevelUnlockContent: View {
    @Environment(AppStore.self) private var store
    let trackID: String
    let levelIndex: Int
    let revealed: Bool

    var body: some View {
        if let track = store.track(trackID), let level = track.levels[safe: levelIndex] {
            let programName = store.program(level.programID)?.name ?? ""

            VStack(spacing: 22) {
                Label("Level complete", systemImage: "checkmark.seal.fill")
                    .font(.subheadline.weight(.bold))
                    .reveal(revealed, order: 0)

                HeroTile(rows: PixelArt.unlockFlag, revealed: revealed)

                VStack(spacing: 6) {
                    Text("\(level.title) complete!")
                        .font(.largeTitle.bold())
                        .accessibilityAddTraits(.isHeader)
                    Text("\(programName) · \(track.name)")
                        .font(.title3)
                }
                .reveal(revealed, order: 2)

                BonusCountUp(points: level.bonusPoints, suffix: "bonus points", revealed: revealed)
                    .reveal(revealed, order: 3)

                UnlockPanel {
                    TrackPathView(track: track, student: store.currentStudent, showsTitle: false)
                }
                .reveal(revealed, order: 4)

                if let next = store.upNext(for: store.currentStudentID) {
                    UnlockPanel {
                        Text("Up next")
                            .font(.footnote.weight(.bold))
                        Text("\(next.level.title): \(next.program.name)")
                            .font(.headline)
                        Text("\(next.program.site) · \(next.program.schedule)")
                            .font(.subheadline)
                    }
                    .accessibilityElement(children: .combine)
                    .reveal(revealed, order: 5)
                }
            }
        }
    }
}
