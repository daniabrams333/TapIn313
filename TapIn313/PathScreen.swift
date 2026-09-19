import SwiftUI

/// My path tab: the student's track as a path, progress on each level, what comes next,
/// the track payoff, and a way to pick or switch tracks.
struct PathScreen: View {
    @Environment(AppStore.self) private var store

    private var student: Student { store.currentStudent }
    private var studentID: String { store.currentStudentID }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    if let track = store.currentTrack(for: studentID) {
                        pathHeader(track)
                        levelsSection(track)
                        nextSection(track)
                        payoffSection(track)
                        trackPicker(currentTrackID: track.id)
                    } else {
                        emptyState
                        trackPicker(currentTrackID: nil)
                    }

                    Text("Tracks, payoffs, and schedules are samples for this demo.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                .padding(16)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("My path")
            .brandMark()
            .navigationDestination(for: Program.self) { program in
                ProgramDetailScreen(program: program)
            }
        }
    }

    // MARK: Header

    private func pathHeader(_ track: Track) -> some View {
        let totalBonus = track.levels.reduce(0) { $0 + $1.bonusPoints }
        return VStack(alignment: .leading, spacing: 12) {
            Label(track.name, systemImage: track.symbol)
                .font(.title2.bold())
            Text(track.tagline)
                .font(.subheadline)
            Text("\(track.levels.count) levels · \(totalBonus) bonus points")
                .font(.footnote.weight(.semibold))

            Rectangle()
                .fill(Theme.onPrimary.opacity(0.3))
                .frame(height: 1)
                .accessibilityHidden(true)

            TrackPathView(track: track, student: student, showsTitle: false)
        }
        .foregroundStyle(Theme.onPrimary)
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.primary, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: Levels

    private func levelsSection(_ track: Track) -> some View {
        let states = LevelState.states(for: track, studentID: studentID, in: store)
        return VStack(alignment: .leading, spacing: 12) {
            SectionTitle("Your levels")
            ForEach(track.levels.indices, id: \.self) { index in
                let level = track.levels[index]
                if let program = store.program(level.programID) {
                    NavigationLink(value: program) {
                        LevelCard(
                            level: level,
                            program: program,
                            state: states[index],
                            done: store.levelProgress(track, levelIndex: index, studentID: studentID).done
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: What's next

    @ViewBuilder
    private func nextSection(_ track: Track) -> some View {
        if let next = store.upNext(for: studentID) {
            let progress = store.levelProgress(track, levelIndex: next.levelIndex, studentID: studentID)
            let remaining = max(progress.required - progress.done, 0)
            let following = track.levels.indices.contains(next.levelIndex + 1) ? track.levels[next.levelIndex + 1] : nil

            VStack(alignment: .leading, spacing: 8) {
                SectionTitle("What unlocks next")
                InfoCard(symbol: "lock.open.fill") {
                    Text("\(remaining) more \(remaining == 1 ? "session" : "sessions") of \(next.program.name) finishes \(next.level.title) and earns +\(next.level.bonusPoints) bonus points.")
                        .font(.body)
                    if let following, let followingProgram = store.program(following.programID) {
                        Text("Then you move on to \(following.title): \(followingProgram.name).")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }

    // MARK: Payoff

    private func payoffSection(_ track: Track) -> some View {
        let isComplete = store.isTrackComplete(track, studentID: studentID)
        return VStack(alignment: .leading, spacing: 8) {
            SectionTitle("At the end of the track")
            InfoCard(symbol: isComplete ? "checkmark.seal.fill" : "flag.checkered", tint: isComplete ? Theme.softFill : nil) {
                if isComplete {
                    Label("Track complete", systemImage: "checkmark")
                        .font(.headline)
                }
                Text(track.payoff)
                    .font(.body)
                if !isComplete {
                    Text("Finish all \(track.levels.count) levels to get here.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                // Data honesty: payoffs are sample ideas, never a confirmed offer.
                Text("A sample idea for this demo, not a confirmed event or offer.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: Picker

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("What sounds like you?")
                .font(.title2.bold())
            Text("Pick a track and your path shows up here. Each track has three levels, and each level is one program.")
                .font(.body)
        }
    }

    private func trackPicker(currentTrackID: String?) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionTitle(currentTrackID == nil ? "Choose a track" : "Switch track")
            if currentTrackID != nil {
                Text("Switching keeps the points and levels you already earned.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            ForEach(store.tracks) { track in
                TrackCard(
                    track: track,
                    isCurrent: track.id == currentTrackID,
                    levelsDone: track.levels.indices.filter {
                        store.isLevelComplete(track, levelIndex: $0, studentID: studentID)
                    }.count,
                    programNames: track.levels.compactMap { store.program($0.programID)?.name }
                ) {
                    store.chooseTrack(track.id, for: studentID)
                }
            }
        }
    }
}

// MARK: - Pieces

private struct SectionTitle: View {
    let text: String
    init(_ text: String) { self.text = text }

    var body: some View {
        Text(text)
            .font(.headline)
            .accessibilityAddTraits(.isHeader)
    }
}

/// A white card with a symbol on the left and any content on the right.
private struct InfoCard<Content: View>: View {
    let symbol: String
    var tint: Color?
    @ViewBuilder let content: Content

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: symbol)
                .font(.title3)
                .foregroundStyle(Theme.primary)
                .frame(width: 28)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 6) {
                content
            }
            Spacer(minLength: 0)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(tint ?? Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
        .foregroundStyle(tint == nil ? Color.primary : Theme.onSoftFill)
        .accessibilityElement(children: .combine)
    }
}

private struct LevelCard: View {
    let level: TrackLevel
    let program: Program
    let state: LevelState
    let done: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text(level.title)
                    .font(.headline)
                Spacer(minLength: 8)
                stateLabel
            }
            Text(program.name)
                .font(.title3.bold())
            Text("\(program.site) · \(program.schedule)")
                .font(.subheadline)

            HStack(spacing: 12) {
                SessionBar(done: done, required: level.sessionsRequired)
                Text("\(done) of \(level.sessionsRequired) sessions")
                    .font(.subheadline.weight(.semibold))
                    .fixedSize()
            }

            PointsPill(
                points: level.bonusPoints,
                suffix: state == .complete ? "bonus earned" : "bonus points"
            )
        }
        .foregroundStyle(state == .complete ? Theme.onSoftFill : Color.primary)
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            state == .complete ? Theme.softFill : Color(.secondarySystemGroupedBackground),
            in: RoundedRectangle(cornerRadius: 16)
        )
        .overlay {
            if state == .current {
                RoundedRectangle(cornerRadius: 16).strokeBorder(Theme.primary, lineWidth: 3)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            "\(level.title): \(program.name) at \(program.site). \(stateWord). \(done) of \(level.sessionsRequired) sessions. \(level.bonusPoints) bonus points."
        )
        .accessibilityHint("Opens program details")
    }

    private var stateWord: String {
        switch state {
        case .complete: "Complete"
        case .current: "In progress"
        case .locked: "Locked"
        }
    }

    @ViewBuilder
    private var stateLabel: some View {
        switch state {
        case .complete:
            Label("Complete", systemImage: "checkmark.circle.fill")
                .font(.subheadline.weight(.semibold))
        case .current:
            Label("You are here", systemImage: "figure.walk")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.primary)
        case .locked:
            Label("Locked", systemImage: "lock.fill")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)
        }
    }
}

/// One block per required session. Filled blocks are finished sessions.
private struct SessionBar: View {
    let done: Int
    let required: Int

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<max(required, 1), id: \.self) { index in
                RoundedRectangle(cornerRadius: 3)
                    .fill(index < done ? Theme.progress : Color(.systemGray5))
                    .frame(height: 12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 3)
                            .strokeBorder(Color(.systemGray2), lineWidth: index < done ? 0 : 1)
                    )
            }
        }
        .accessibilityHidden(true)
    }
}

private struct TrackCard: View {
    let track: Track
    let isCurrent: Bool
    let levelsDone: Int
    let programNames: [String]
    let onChoose: () -> Void

    private var progressText: String {
        levelsDone == 0 ? "Not started" : "\(levelsDone) of \(track.levels.count) levels done"
    }

    var body: some View {
        Button(action: onChoose) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: track.symbol)
                    .font(.title3)
                    .foregroundStyle(Theme.onPrimary)
                    .frame(width: 44, height: 44)
                    .background(Theme.primary, in: RoundedRectangle(cornerRadius: 10))
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: 4) {
                    Text(track.name)
                        .font(.headline)
                    Text(track.tagline)
                        .font(.subheadline)
                    Text(programNames.joined(separator: " → "))
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    Text(progressText)
                        .font(.footnote.weight(.semibold))
                        .padding(.top, 2)
                }
                .multilineTextAlignment(.leading)

                Spacer(minLength: 8)

                if isCurrent {
                    Label("Your track", systemImage: "checkmark.circle.fill")
                        .font(.footnote.weight(.bold))
                        .labelStyle(.titleAndIcon)
                        .foregroundStyle(Theme.onSoftFill)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Theme.softFill, in: Capsule())
                } else {
                    Image(systemName: "chevron.right")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .accessibilityHidden(true)
                }
            }
            .foregroundStyle(Color.primary)
            .padding(16)
            .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
            .overlay {
                if isCurrent {
                    RoundedRectangle(cornerRadius: 16).strokeBorder(Theme.primary, lineWidth: 3)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            "\(track.name). \(track.tagline) \(programNames.joined(separator: ", then ")). \(progressText)."
            + (isCurrent ? " Your current track." : "")
        )
        .accessibilityHint(isCurrent ? "" : "Switches your path to this track. Progress you already earned is kept.")
    }
}
