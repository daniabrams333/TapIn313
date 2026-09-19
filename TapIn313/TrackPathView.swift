import SwiftUI

/// A track drawn as a path: Explore, Build, Launch. Finished levels get a checkmark, the level
/// the student is on shows their avatar, and later levels show a lock. Every state also has a word,
/// so it never depends on color alone. Made for a Rise Blue background (white text).
struct TrackPathView: View {
    @Environment(AppStore.self) private var store
    let track: Track
    let student: Student
    var showsTitle = true

    private var states: [LevelState] {
        LevelState.states(for: track, studentID: student.id, in: store)
    }

    private func statusText(index: Int, state: LevelState) -> String {
        switch state {
        case .complete:
            return "Done"
        case .locked:
            return "Locked"
        case .current:
            let progress = store.levelProgress(track, levelIndex: index, studentID: student.id)
            return "\(progress.done) of \(progress.required) sessions"
        }
    }

    var body: some View {
        let states = self.states
        let isTrackComplete = store.isTrackComplete(track, studentID: student.id)

        VStack(alignment: .leading, spacing: 12) {
            if showsTitle {
                Label("\(track.name) path", systemImage: track.symbol)
                    .font(.subheadline.weight(.semibold))
            }

            HStack(alignment: .top, spacing: 0) {
                ForEach(track.levels.indices, id: \.self) { index in
                    let level = track.levels[index]
                    PathNode(
                        student: student,
                        title: level.title,
                        programName: store.program(level.programID)?.name ?? "",
                        status: statusText(index: index, state: states[index]),
                        state: states[index],
                        lineBefore: index > 0 ? states[index - 1] == .complete : nil,
                        lineAfter: index < states.count - 1 ? states[index] == .complete : nil
                    )
                }
            }

            if isTrackComplete {
                Label("Track complete", systemImage: "checkmark.seal.fill")
                    .font(.subheadline.weight(.semibold))
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilitySummary(states: states, isTrackComplete: isTrackComplete))
    }

    private func accessibilitySummary(states: [LevelState], isTrackComplete: Bool) -> String {
        let steps = track.levels.indices.map { index -> String in
            let level = track.levels[index]
            let program = store.program(level.programID)?.name ?? ""
            return "\(level.title), \(program): \(statusText(index: index, state: states[index]))"
        }
        let summary = "\(track.name) path. " + steps.joined(separator: ". ") + "."
        return isTrackComplete ? summary + " Track complete." : summary
    }
}

/// Where a level stands for one student. The first unfinished level is the current one.
enum LevelState {
    case complete, current, locked

    static func states(for track: Track, studentID: String, in store: AppStore) -> [LevelState] {
        var foundCurrent = false
        return track.levels.indices.map { index in
            if store.isLevelComplete(track, levelIndex: index, studentID: studentID) { return .complete }
            if !foundCurrent {
                foundCurrent = true
                return .current
            }
            return .locked
        }
    }
}

// MARK: - Pieces

private struct PathNode: View {
    let student: Student
    let title: String
    let programName: String
    let status: String
    let state: LevelState
    /// nil means no line on that side. true means the line is finished, false means still ahead.
    let lineBefore: Bool?
    let lineAfter: Bool?

    @ScaledMetric private var nodeSide: CGFloat = 48

    var body: some View {
        VStack(spacing: 6) {
            node
            Text(title)
                .font(.footnote.weight(.bold))
            Text(status)
                .font(.caption)
            Text(programName)
                .font(.caption)
                .opacity(0.85)
                .multilineTextAlignment(.center)
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity, alignment: .top)
        .background(alignment: .top) { lines }
    }

    private var node: some View {
        ZStack {
            switch state {
            case .complete:
                RoundedRectangle(cornerRadius: 10).fill(Theme.softFill)
                Image(systemName: "checkmark")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(Theme.onSoftFill)
            case .current:
                RoundedRectangle(cornerRadius: 10).fill(Theme.highlight)
                AvatarView(student: student, size: 38)
            case .locked:
                RoundedRectangle(cornerRadius: 10).fill(Theme.onPrimary.opacity(0.12))
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(Theme.onPrimary.opacity(0.7), style: StrokeStyle(lineWidth: 2, dash: [5, 4]))
                Image(systemName: "lock.fill")
                    .font(.body)
                    .foregroundStyle(Theme.onPrimary)
            }
        }
        .frame(width: nodeSide, height: nodeSide)
    }

    /// The path between nodes: solid and light when finished, dashed when still ahead.
    private var lines: some View {
        HStack(spacing: 0) {
            segment(lineBefore)
            segment(lineAfter)
        }
        .frame(height: nodeSide)
    }

    @ViewBuilder
    private func segment(_ isDone: Bool?) -> some View {
        if let isDone {
            HorizontalLine()
                .stroke(
                    isDone ? Theme.softFill : Theme.onPrimary.opacity(0.6),
                    style: StrokeStyle(lineWidth: 4, dash: isDone ? [] : [6, 5])
                )
                .frame(maxWidth: .infinity)
        } else {
            Color.clear.frame(maxWidth: .infinity)
        }
    }
}

private struct HorizontalLine: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        return path
    }
}
