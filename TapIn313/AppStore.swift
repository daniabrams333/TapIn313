import Foundation
import Observation

enum AppMode {
    case student, staff
}

/// One in-memory store shared by the student app and the staff mode.
/// When staff confirm attendance, the student's points, level progress, and
/// badges update instantly.
@Observable
final class AppStore {

    // MARK: State

    var mode: AppMode = .student
    var currentStudentID = "jordan"

    let programs = MockData.programs
    let tracks = MockData.tracks
    let merchants = MockData.merchants
    let rewards = MockData.rewards
    let badges = MockData.badges
    let students = MockData.students

    var studentTracks: [String: String] = [:]    // studentID -> trackID
    var enrollments: [String: [String]] = [:]    // programID -> studentIDs
    var attendances: [Attendance] = []
    var redemptions: [Redemption] = []
    var earnedBadges: [EarnedBadge] = []
    var levelCompletions: [LevelCompletion] = []

    /// Celebrations the current student has not seen yet, shown one at a time in order.
    var pendingUnlocks: [Unlock] = []

    init() {
        loadSeed()
    }

    // MARK: Demo controls

    /// Puts everything back to the starting demo state. Use before each rehearsal.
    func resetDemo() {
        mode = .student
        currentStudentID = "jordan"
        loadSeed()
    }

    private func loadSeed() {
        studentTracks = MockData.studentTracks
        enrollments = MockData.enrollments
        attendances = MockData.seedAttendances
        redemptions = []
        earnedBadges = []
        levelCompletions = []
        pendingUnlocks = []
        for student in students {
            _ = awardLevelCompletions(to: student.id, notify: false)
            _ = awardNewBadges(to: student.id, notify: false)
        }
    }

    // MARK: Lookups

    var currentStudent: Student {
        students.first { $0.id == currentStudentID } ?? students[0]
    }

    func program(_ id: String) -> Program? { programs.first { $0.id == id } }
    func track(_ id: String) -> Track? { tracks.first { $0.id == id } }
    func merchant(_ id: String) -> Merchant? { merchants.first { $0.id == id } }
    func reward(_ id: String) -> Reward? { rewards.first { $0.id == id } }
    func badge(_ id: String) -> Badge? { badges.first { $0.id == id } }
    func student(_ id: String) -> Student? { students.first { $0.id == id } }

    func rewards(for merchantID: String) -> [Reward] {
        rewards.filter { $0.merchantID == merchantID }
    }

    func roster(for programID: String) -> [Student] {
        (enrollments[programID] ?? []).compactMap { student($0) }
    }

    // MARK: Points

    func pointsFromAttendance(for studentID: String) -> Int {
        attendances.filter { $0.studentID == studentID }.reduce(0) { $0 + $1.points }
    }

    func pointsFromLevels(for studentID: String) -> Int {
        levelCompletions.filter { $0.studentID == studentID }.reduce(0) { $0 + $1.bonus }
    }

    func pointsEarned(for studentID: String) -> Int {
        pointsFromAttendance(for: studentID) + pointsFromLevels(for: studentID)
    }

    func pointsSpent(for studentID: String) -> Int {
        redemptions.filter { $0.studentID == studentID }.reduce(0) { $0 + $1.cost }
    }

    /// Balance is always derived, so it can never drift out of sync.
    func pointsBalance(for studentID: String) -> Int {
        pointsEarned(for: studentID) - pointsSpent(for: studentID)
    }

    func attendances(for studentID: String) -> [Attendance] {
        attendances.filter { $0.studentID == studentID }.sorted { $0.date > $1.date }
    }

    func redemptions(for studentID: String) -> [Redemption] {
        redemptions.filter { $0.studentID == studentID }.sorted { $0.date > $1.date }
    }

    func earnedBadgeIDs(for studentID: String) -> Set<String> {
        Set(earnedBadges.filter { $0.studentID == studentID }.map(\.badgeID))
    }

    // MARK: Tracks

    func currentTrack(for studentID: String) -> Track? {
        guard let trackID = studentTracks[studentID] else { return nil }
        return track(trackID)
    }

    /// Picks or switches a track. Progress and bonuses already earned are kept.
    func chooseTrack(_ trackID: String, for studentID: String) {
        studentTracks[studentID] = trackID
        _ = awardLevelCompletions(to: studentID, notify: true)
    }

    func sessionsCompleted(studentID: String, programID: String) -> Int {
        attendances.filter { $0.studentID == studentID && $0.programID == programID }.count
    }

    /// Sessions done and required for one level, for "1 of 2 sessions" labels.
    func levelProgress(_ track: Track, levelIndex: Int, studentID: String) -> (done: Int, required: Int) {
        guard track.levels.indices.contains(levelIndex) else { return (0, 0) }
        let level = track.levels[levelIndex]
        let done = sessionsCompleted(studentID: studentID, programID: level.programID)
        return (min(done, level.sessionsRequired), level.sessionsRequired)
    }

    func isLevelComplete(_ track: Track, levelIndex: Int, studentID: String) -> Bool {
        guard track.levels.indices.contains(levelIndex) else { return false }
        let progress = levelProgress(track, levelIndex: levelIndex, studentID: studentID)
        return progress.done >= progress.required
    }

    func isTrackComplete(_ track: Track, studentID: String) -> Bool {
        track.levels.indices.allSatisfy { isLevelComplete(track, levelIndex: $0, studentID: studentID) }
    }

    /// The first level the student has not finished. This powers the "Up next" card.
    func upNext(for studentID: String) -> (track: Track, levelIndex: Int, level: TrackLevel, program: Program)? {
        guard let track = currentTrack(for: studentID) else { return nil }
        for index in track.levels.indices where !isLevelComplete(track, levelIndex: index, studentID: studentID) {
            let level = track.levels[index]
            if let program = program(level.programID) {
                return (track, index, level, program)
            }
        }
        return nil
    }

    private func hasRecordedCompletion(studentID: String, trackID: String, levelIndex: Int) -> Bool {
        levelCompletions.contains {
            $0.studentID == studentID && $0.trackID == trackID && $0.levelIndex == levelIndex
        }
    }

    /// Records any newly completed levels on the student's track and pays their bonus once.
    @discardableResult
    private func awardLevelCompletions(to studentID: String, notify: Bool) -> [Unlock] {
        guard let track = currentTrack(for: studentID) else { return [] }
        var unlocks: [Unlock] = []

        for (index, level) in track.levels.enumerated() {
            let alreadyRecorded = hasRecordedCompletion(studentID: studentID, trackID: track.id, levelIndex: index)
            if !alreadyRecorded && isLevelComplete(track, levelIndex: index, studentID: studentID) {
                levelCompletions.append(
                    LevelCompletion(id: UUID(), studentID: studentID, trackID: track.id,
                                    levelIndex: index, date: .now, bonus: level.bonusPoints)
                )
                unlocks.append(.level(trackID: track.id, levelIndex: index))
            }
        }

        if !unlocks.isEmpty && isTrackComplete(track, studentID: studentID) {
            unlocks.append(.track(trackID: track.id))
        }

        if notify && studentID == currentStudentID {
            pendingUnlocks.append(contentsOf: unlocks)
        }
        return unlocks
    }

    // MARK: Student actions

    func isEnrolled(studentID: String, programID: String) -> Bool {
        enrollments[programID]?.contains(studentID) ?? false
    }

    func join(studentID: String, programID: String) {
        guard !isEnrolled(studentID: studentID, programID: programID) else { return }
        enrollments[programID, default: []].append(studentID)
    }

    @discardableResult
    func redeem(_ reward: Reward, studentID: String) -> Redemption? {
        guard pointsBalance(for: studentID) >= reward.cost else { return nil }
        let redemption = Redemption(
            id: UUID(), studentID: studentID, rewardID: reward.id,
            code: Self.makeCode(), date: .now, cost: reward.cost
        )
        redemptions.append(redemption)
        _ = awardNewBadges(to: studentID, notify: true)
        return redemption
    }

    // MARK: Staff actions

    func hasAttended(studentID: String, programID: String, on date: Date) -> Bool {
        attendances.contains {
            $0.studentID == studentID &&
            $0.programID == programID &&
            Calendar.current.isDate($0.date, inSameDayAs: date)
        }
    }

    /// Confirms a student attended a program session and awards its points.
    /// Level completions are checked first, then badges, so celebrations play in
    /// that order. Confirming twice on the same day does nothing.
    @discardableResult
    func confirmAttendance(studentID: String, programID: String, on date: Date = .now) -> [Unlock] {
        guard let program = program(programID),
              !hasAttended(studentID: studentID, programID: programID, on: date) else { return [] }
        attendances.append(
            Attendance(id: UUID(), studentID: studentID, programID: programID,
                       date: date, points: program.points)
        )
        let levelUnlocks = awardLevelCompletions(to: studentID, notify: true)
        let badgeUnlocks = awardNewBadges(to: studentID, notify: true)
        return levelUnlocks + badgeUnlocks
    }

    // MARK: Badges

    func dismissUnlock() {
        if !pendingUnlocks.isEmpty { pendingUnlocks.removeFirst() }
    }

    @discardableResult
    private func awardNewBadges(to studentID: String, notify: Bool) -> [Unlock] {
        let already = earnedBadgeIDs(for: studentID)
        var unlocks: [Unlock] = []
        for badge in badges where !already.contains(badge.id) && isMet(badge.rule, studentID: studentID) {
            earnedBadges.append(EarnedBadge(id: UUID(), studentID: studentID, badgeID: badge.id, date: .now))
            unlocks.append(.badge(badge))
        }
        if notify && studentID == currentStudentID {
            pendingUnlocks.append(contentsOf: unlocks)
        }
        return unlocks
    }

    private func isMet(_ rule: BadgeRule, studentID: String) -> Bool {
        let attended = attendances.filter { $0.studentID == studentID }
        let redeemed = redemptions.filter { $0.studentID == studentID }
        switch rule {
        case .attendances(let n):
            return attended.count >= n
        case .categories(let n):
            return Set(attended.compactMap { program($0.programID)?.category }).count >= n
        case .lifetimePoints(let n):
            return pointsEarned(for: studentID) >= n
        case .redemptions(let n):
            return redeemed.count >= n
        case .merchants(let n):
            return Set(redeemed.compactMap { reward($0.rewardID)?.merchantID }).count >= n
        }
    }

    // MARK: Codes

    /// Digital gift card code, like TAP-K7M2-Q9XA. Skips look-alike characters.
    static func makeCode() -> String {
        let characters = Array("ABCDEFGHJKLMNPQRSTUVWXYZ23456789")
        func chunk() -> String {
            String((0..<4).map { _ in characters.randomElement() ?? "A" })
        }
        return "TAP-\(chunk())-\(chunk())"
    }
}
