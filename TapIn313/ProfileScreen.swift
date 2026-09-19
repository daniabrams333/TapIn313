import SwiftUI

/// Profile tab: avatar, points balance, badges, and activity history.
struct ProfileScreen: View {
    @Environment(AppStore.self) private var store

    private var student: Student { store.currentStudent }
    private var studentID: String { store.currentStudentID }

    var body: some View {
        NavigationStack {
            List {
                headerSection
                badgesSection
                historySection
                demoControlsSection
            }
            .navigationTitle("Profile")
            .navigationDestination(for: Redemption.self) { redemption in
                GiftCardScreen(redemption: redemption)
            }
        }
    }

    // MARK: Header

    private var headerSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 16) {
                    AvatarView(student: student, size: 88)
                    VStack(alignment: .leading, spacing: 6) {
                        Text(student.displayName)
                            .font(.title2.bold())
                        Text("Grade \(student.grade)")
                            .font(.subheadline)
                        Label("\(store.pointsBalance(for: studentID)) points", systemImage: "star.fill")
                            .font(.headline)
                            .foregroundStyle(Theme.onHighlight)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Theme.highlight, in: Capsule())
                    }
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("\(student.displayName), grade \(student.grade), \(store.pointsBalance(for: studentID)) points")

                Rectangle()
                    .fill(Theme.onPrimary.opacity(0.3))
                    .frame(height: 1)
                    .accessibilityHidden(true)

                if let track = store.currentTrack(for: studentID) {
                    TrackPathView(track: track, student: student)
                } else {
                    Text("Pick a track in My path and your path will show up here.")
                        .font(.subheadline)
                }
            }
            .foregroundStyle(Theme.onPrimary)
            .padding(.vertical, 8)
        }
        .listRowBackground(Theme.primary)
    }

    // MARK: Badges

    private var badgesSection: some View {
        let earnedIDs = store.earnedBadgeIDs(for: studentID)
        return Section {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 140), spacing: 12, alignment: .top)], spacing: 20) {
                ForEach(store.badges) { badge in
                    BadgeCell(badge: badge, earnedDate: earnedDate(for: badge, earned: earnedIDs))
                }
            }
            .padding(.vertical, 8)
        } header: {
            Text("Badges · \(earnedIDs.count) of \(store.badges.count)")
                .font(.headline)
                .foregroundStyle(.primary)
                .textCase(nil)
        }
    }

    private func earnedDate(for badge: Badge, earned: Set<String>) -> Date? {
        guard earned.contains(badge.id) else { return nil }
        let record = store.earnedBadges.first { $0.studentID == studentID && $0.badgeID == badge.id }
        return record?.date ?? Date.distantPast
    }

    // MARK: History

    private var historySection: some View {
        Section {
            if history.isEmpty {
                Text("No activity yet. Join a program and get checked in to earn points.")
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
            ForEach(history) { item in
                if case .redeemed(let redemption, _, _) = item.kind {
                    // Tap a redemption to see its gift card code again.
                    NavigationLink(value: redemption) {
                        HistoryRow(item: item)
                    }
                } else {
                    HistoryRow(item: item)
                }
            }
        } header: {
            Text("Activity")
                .font(.headline)
                .foregroundStyle(.primary)
                .textCase(nil)
        }
    }

    private var history: [HistoryItem] {
        let checkIns = store.attendances(for: studentID).map { attendance in
            HistoryItem(
                id: attendance.id,
                date: attendance.date,
                kind: .checkIn(
                    programName: store.program(attendance.programID)?.name ?? "Program",
                    points: attendance.points
                )
            )
        }
        let levels = store.levelCompletions
            .filter { $0.studentID == studentID }
            .map { completion in
                let track = store.track(completion.trackID)
                let levelTitle = track.flatMap { $0.levels.indices.contains(completion.levelIndex) ? $0.levels[completion.levelIndex].title : nil }
                return HistoryItem(
                    id: completion.id,
                    date: completion.date,
                    kind: .levelComplete(
                        trackName: track?.name ?? "Track",
                        levelTitle: levelTitle ?? "Level",
                        bonus: completion.bonus
                    )
                )
            }
        let redemptions = store.redemptions(for: studentID).map { redemption in
            let reward = store.reward(redemption.rewardID)
            let merchantName = reward.flatMap { store.merchant($0.merchantID)?.name } ?? "Local merchant"
            return HistoryItem(
                id: redemption.id,
                date: redemption.date,
                kind: .redeemed(redemption, title: reward?.title ?? "Reward", merchantName: merchantName)
            )
        }
        return (checkIns + levels + redemptions).sorted { $0.date > $1.date }
    }

    // MARK: Demo controls

    private var demoControlsSection: some View {
        Section {
            Button("Switch to staff mode") { store.mode = .staff }
                .frame(minHeight: 44, alignment: .leading)
            Button("Reset demo", role: .destructive) { store.resetDemo() }
                .frame(minHeight: 44, alignment: .leading)
        } header: {
            Text("Demo controls")
                .font(.headline)
                .foregroundStyle(.primary)
                .textCase(nil)
        } footer: {
            Text("For presenters. Tap In 313 is a demo with sample data and no real student accounts.")
                .font(.footnote)
        }
    }
}

// MARK: - Pieces

private struct BadgeCell: View {
    let badge: Badge
    /// nil means locked. `.distantPast` means earned with no recorded date.
    let earnedDate: Date?

    private var isEarned: Bool { earnedDate != nil }

    var body: some View {
        VStack(spacing: 8) {
            BadgeIcon(badge: badge, isEarned: isEarned, size: 104)
            Text(badge.name)
                .font(.subheadline.weight(.bold))
                .multilineTextAlignment(.center)
            Text(detailText)
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            isEarned
                ? "\(badge.name), earned. \(badge.detail)"
                : "\(badge.name), locked. \(badge.detail)"
        )
    }

    private var detailText: String {
        guard let earnedDate else { return "Locked · \(badge.detail)" }
        if earnedDate == .distantPast { return "Earned" }
        return "Earned \(earnedDate.formatted(.dateTime.month(.abbreviated).day()))"
    }
}

private struct HistoryItem: Identifiable {
    enum Kind {
        case checkIn(programName: String, points: Int)
        case levelComplete(trackName: String, levelTitle: String, bonus: Int)
        case redeemed(Redemption, title: String, merchantName: String)
    }

    let id: UUID
    let date: Date
    let kind: Kind
}

private struct HistoryRow: View {
    let item: HistoryItem

    private var dayText: String {
        item.date.formatted(.dateTime.weekday(.abbreviated).month(.abbreviated).day())
    }

    private var timeText: String {
        item.date.formatted(date: .omitted, time: .shortened)
    }

    var body: some View {
        switch item.kind {
        case .checkIn(let programName, let points):
            row(
                symbol: "checkmark.circle.fill",
                title: programName,
                subtitle: "Checked in by staff at \(timeText)",
                points: points,
                accessibility: "\(programName). Checked in by staff at \(timeText) on \(dayText). Earned \(points) points."
            )
        case .levelComplete(let trackName, let levelTitle, let bonus):
            row(
                symbol: "flag.checkered",
                title: "Level complete: \(levelTitle)",
                subtitle: trackName,
                points: bonus,
                accessibility: "Level complete: \(levelTitle), \(trackName), on \(dayText). Bonus \(bonus) points."
            )
        case .redeemed(let redemption, let title, let merchantName):
            row(
                symbol: "gift.fill",
                title: "Redeemed: \(title)",
                subtitle: merchantName,
                points: redemption.cost,
                sign: "−",
                accessibility: "Redeemed \(title) at \(merchantName) on \(dayText). Spent \(redemption.cost) points. Opens the gift card."
            )
        }
    }

    private func row(symbol: String, title: String, subtitle: String, points: Int, sign: String = "+", accessibility: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: symbol)
                .font(.title3)
                .foregroundStyle(Theme.progress)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                Text(subtitle)
                    .font(.subheadline)
                Text(dayText)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: 8)
            PointsPill(points: points, sign: sign)
        }
        .padding(.vertical, 4)
        .frame(minHeight: 44)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibility)
    }
}
