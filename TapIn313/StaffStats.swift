import Foundation

/// Numbers for the staff "at a glance" view, worked out from the store. Nothing is stored here,
/// so the numbers always match what staff just confirmed.
struct StaffStats {
    let store: AppStore

    struct DayCount: Identifiable {
        let date: Date
        let count: Int
        var id: Date { date }
    }

    struct CloseToLevel: Identifiable {
        let id: String
        let student: Student
        let trackName: String
        let levelTitle: String
        let programName: String
    }

    struct CheckIn: Identifiable {
        let id: UUID
        let studentName: String
        let student: Student?
        let programName: String
        let date: Date
        let points: Int
    }

    // MARK: Today

    private var attendancesToday: [Attendance] {
        store.attendances.filter { Calendar.current.isDateInToday($0.date) }
    }

    var checkInsToday: Int { attendancesToday.count }

    /// Attendance points plus any level bonuses paid today.
    var pointsToday: Int {
        let attendance = attendancesToday.reduce(0) { $0 + $1.points }
        let bonuses = store.levelCompletions
            .filter { Calendar.current.isDateInToday($0.date) }
            .reduce(0) { $0 + $1.bonus }
        return attendance + bonuses
    }

    var programsWithCheckInsToday: Int {
        Set(attendancesToday.map(\.programID)).count
    }

    var programsWithRosters: Int {
        store.programs.filter { !store.roster(for: $0.id).isEmpty }.count
    }

    // MARK: Students

    var enrolledStudents: Int {
        Set(store.enrollments.values.flatMap { $0 }).count
    }

    // MARK: Last 7 days

    /// Check-ins for each of the last seven days, oldest first, ending today.
    var lastSevenDays: [DayCount] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        return (0..<7).reversed().compactMap { offset in
            guard let day = calendar.date(byAdding: .day, value: -offset, to: today) else { return nil }
            let count = store.attendances.filter { calendar.isDate($0.date, inSameDayAs: day) }.count
            return DayCount(date: day, count: count)
        }
    }

    var checkInsThisWeek: Int {
        lastSevenDays.reduce(0) { $0 + $1.count }
    }

    // MARK: Who to watch

    /// Students exactly one session away from finishing their current level.
    var closeToLevelUp: [CloseToLevel] {
        store.students.compactMap { student in
            guard let track = store.currentTrack(for: student.id),
                  let index = track.levels.indices.first(where: {
                      !store.isLevelComplete(track, levelIndex: $0, studentID: student.id)
                  }) else { return nil }

            let progress = store.levelProgress(track, levelIndex: index, studentID: student.id)
            guard progress.done > 0, progress.required - progress.done == 1 else { return nil }

            let level = track.levels[index]
            return CloseToLevel(
                id: "\(student.id)-\(track.id)-\(index)",
                student: student,
                trackName: track.name,
                levelTitle: level.title,
                programName: store.program(level.programID)?.name ?? ""
            )
        }
    }

    // MARK: Recent

    func recentCheckIns(limit: Int = 5) -> [CheckIn] {
        store.attendances
            .sorted { $0.date > $1.date }
            .prefix(limit)
            .map { attendance in
                let student = store.student(attendance.studentID)
                return CheckIn(
                    id: attendance.id,
                    studentName: student?.displayName ?? "Student",
                    student: student,
                    programName: store.program(attendance.programID)?.name ?? "Program",
                    date: attendance.date,
                    points: attendance.points
                )
            }
    }
}
