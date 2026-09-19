import SwiftUI

/// One program's roster. Staff tap "Confirm attendance" next to each student who showed up.
/// Confirming awards the program's points, and the student's app updates right away.
/// On a wide screen the students sit in a grid of cards. On iPhone they sit in a list.
struct StaffRosterScreen: View {
    @Environment(AppStore.self) private var store
    @Environment(\.horizontalSizeClass) private var sizeClass
    let program: Program
    @State private var confirmation: String?

    private var roster: [Student] { store.roster(for: program.id) }

    private var rosterTitle: String {
        "Roster · \(roster.count) \(roster.count == 1 ? "student" : "students")"
    }

    private func checkInTime(for student: Student) -> Date? {
        store.attendances(for: student.id)
            .first { $0.programID == program.id && Calendar.current.isDateInToday($0.date) }?
            .date
    }

    var body: some View {
        Group {
            if sizeClass == .regular {
                gridLayout
            } else {
                listLayout
            }
        }
        .safeAreaInset(edge: .bottom) {
            if let confirmation {
                ConfirmationBanner(message: confirmation)
                    .padding(16)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.default, value: confirmation)
        .navigationTitle(program.name)
        .navigationBarTitleDisplayMode(.inline)
        .staffBar()
        .toolbar { StudentModeToolbarItem() }
    }

    // MARK: Layouts

    private var listLayout: some View {
        List {
            Section {
                header
            }
            .listRowBackground(Theme.staff)

            Section {
                if roster.isEmpty {
                    emptyText
                }
                ForEach(roster) { student in
                    studentRow(student)
                }
            } header: {
                Text(rosterTitle)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .textCase(nil)
            } footer: {
                Text(footerNote)
                    .font(.footnote)
            }
        }
        // Breathing room so the green header card doesn't run into the green navigation bar.
        .contentMargins(.top, 16, for: .scrollContent)
    }

    private var gridLayout: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header
                    .padding(20)
                    .background(Theme.staff, in: RoundedRectangle(cornerRadius: 16))

                Text(rosterTitle)
                    .font(.headline)
                    .accessibilityAddTraits(.isHeader)

                if roster.isEmpty {
                    emptyText
                }
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 320), spacing: 16, alignment: .top)], spacing: 16) {
                    ForEach(roster) { student in
                        studentRow(student)
                            .padding(16)
                            .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
                    }
                }

                Text(footerNote)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding(20)
        }
        .background(Color(.systemGroupedBackground))
    }

    private var emptyText: some View {
        Text("No students have signed up for this program yet.")
            .font(.body)
            .foregroundStyle(.secondary)
    }

    private var footerNote: String {
        "Sample students. Confirming can't be undone in this demo. Use Reset demo on the staff home screen to start over."
    }

    private func studentRow(_ student: Student) -> some View {
        StudentRow(
            student: student,
            program: program,
            checkInTime: checkInTime(for: student),
            trackNote: trackNote(for: student)
        ) {
            confirm(student)
        }
    }

    // MARK: Header

    private var header: some View {
        let checkedIn = roster.filter { checkInTime(for: $0) != nil }.count
        return VStack(alignment: .leading, spacing: 6) {
            Text(program.name)
                .font(.title2.bold())
            Label("\(program.site) · \(program.schedule)", systemImage: program.venue.symbol)
                .font(.subheadline)
            Text("Today, \(Date.now.formatted(.dateTime.weekday(.wide).month(.wide).day()))")
                .font(.subheadline)
            HStack(spacing: 12) {
                Label("\(checkedIn) of \(roster.count) checked in", systemImage: "person.2.fill")
                Label("+\(program.points) points each", systemImage: "star.fill")
            }
            .font(.footnote.weight(.semibold))
            .padding(.top, 2)
        }
        .foregroundStyle(Theme.onStaff)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 8)
        .accessibilityElement(children: .combine)
    }

    // MARK: Actions

    private func confirm(_ student: Student) {
        guard checkInTime(for: student) == nil else { return }   // already confirmed today
        let unlocks = store.confirmAttendance(studentID: student.id, programID: program.id)

        var message = "\(student.displayName) checked in. +\(program.points) points."
        if !unlocks.isEmpty {
            message += " New achievements unlocked."
        }
        confirmation = message
        AccessibilityNotification.Announcement(message).post()

        Task { @MainActor in
            try? await Task.sleep(for: .seconds(3))
            if confirmation == message { confirmation = nil }
        }
    }

    /// For example "Tech Builder · Explore: 1 of 2 sessions". Only shown when this program is on the student's track.
    private func trackNote(for student: Student) -> String? {
        guard let track = store.currentTrack(for: student.id),
              let index = track.levels.firstIndex(where: { $0.programID == program.id }) else { return nil }
        let level = track.levels[index]
        let progress = store.levelProgress(track, levelIndex: index, studentID: student.id)
        let status = progress.done >= progress.required
            ? "level complete"
            : "\(progress.done) of \(progress.required) sessions"
        return "\(track.name) · \(level.title): \(status)"
    }
}

// MARK: - Pieces

private struct StudentRow: View {
    let student: Student
    let program: Program
    let checkInTime: Date?
    let trackNote: String?
    let onConfirm: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                AvatarView(student: student, size: 48)
                VStack(alignment: .leading, spacing: 2) {
                    Text(student.displayName)
                        .font(.headline)
                    Text("Grade \(student.grade)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    if let trackNote {
                        Text(trackNote)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(
                "\(student.displayName), grade \(student.grade)." + (trackNote.map { " \($0)." } ?? "")
            )

            if let checkInTime {
                // The checkmark and the words say it is done, not only the color.
                Label("Checked in at \(checkInTime.formatted(date: .omitted, time: .shortened))", systemImage: "checkmark.circle.fill")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Theme.onSoftFill)
                    .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                    .padding(.horizontal, 12)
                    .background(Theme.softFill, in: RoundedRectangle(cornerRadius: 10))
                    .accessibilityLabel("\(student.displayName) is checked in at \(checkInTime.formatted(date: .omitted, time: .shortened))")
            } else {
                Button(action: onConfirm) {
                    Text("Confirm attendance")
                        .font(.headline)
                        .foregroundStyle(Theme.onStaff)
                        .frame(maxWidth: .infinity, minHeight: 44)
                        .background(Theme.staff, in: RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Confirm attendance for \(student.displayName)")
                .accessibilityHint("Awards \(program.points) points")
            }
        }
        .padding(.vertical, 6)
    }
}

private struct ConfirmationBanner: View {
    let message: String

    var body: some View {
        Label(message, systemImage: "checkmark.circle.fill")
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(Theme.onSoftFill)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(14)
            .background(Theme.softFill, in: RoundedRectangle(cornerRadius: 12))
            .shadow(radius: 4)
            .accessibilityElement(children: .combine)
    }
}
