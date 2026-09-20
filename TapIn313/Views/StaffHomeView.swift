import SwiftUI

/// Staff mode entry point. iPhone gets a single scrolling list, iPad gets a sidebar and a detail pane.
/// Both use City Green so staff mode looks clearly different from student mode.
struct StaffHomeView: View {
    @Environment(\.horizontalSizeClass) private var sizeClass

    var body: some View {
        if sizeClass == .regular {
            StaffSplitView()
        } else {
            StaffPhoneView()
        }
    }
}

// MARK: - Shared staff pieces

extension View {
    /// City Green navigation bar with white text.
    func staffBar() -> some View {
        self
            .toolbarBackground(Theme.staff, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

extension View {
    /// Adds the staff profile button to the top right of a staff screen. It opens the profile sheet.
    func staffProfileButton() -> some View {
        modifier(StaffProfileButton())
    }
}

private struct StaffProfileButton: ViewModifier {
    @State private var showsProfile = false

    func body(content: Content) -> some View {
        content
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showsProfile = true
                    } label: {
                        Image(systemName: "person.crop.circle")
                            .font(.title3)
                            .frame(minWidth: 44, minHeight: 44)
                    }
                    .foregroundStyle(Theme.onStaff)
                    .accessibilityLabel("Staff profile")
                }
            }
            .sheet(isPresented: $showsProfile) {
                StaffProfileScreen()
            }
    }
}

/// Who is signed in as staff, plus a short "what is staff mode" note, in white on City Green.
struct StaffIntroBanner: View {
    @Environment(AppStore.self) private var store

    var body: some View {
        let staff = store.staffMember

        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                AvatarView(displayName: staff.displayName, colorIndex: staff.colorIndex, size: 56)
                VStack(alignment: .leading, spacing: 2) {
                    Text(staff.displayName)
                        .font(.title3.bold())
                    Label("\(staff.role) · Staff mode", systemImage: "checkmark.shield.fill")
                        .font(.subheadline)
                }
            }
            Text("Pick a program, then tap to confirm each student who showed up. Confirming gives them the program's points.")
                .font(.subheadline)
        }
        .foregroundStyle(Theme.onStaff)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 8)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(staff.displayName), \(staff.role), staff mode. Pick a program, then tap to confirm each student who showed up. Confirming gives them the program's points.")
    }
}

/// Switch to student mode and reset the demo. Drop this inside a List.
struct StaffDemoControlsSection: View {
    @Environment(AppStore.self) private var store

    var body: some View {
        Section {
            Button {
                store.mode = .student
            } label: {
                Label("Switch to student mode", systemImage: "person.fill")
                    .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
            }
            .foregroundStyle(Theme.staff)

            Button(role: .destructive) {
                store.resetDemo()
            } label: {
                Label("Reset demo", systemImage: "arrow.counterclockwise")
                    .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
            }
        } header: {
            Text("Demo controls")
                .font(.headline)
                .foregroundStyle(.primary)
                .textCase(nil)
        } footer: {
            Text("Students and rosters are samples. Tap In 313 has no real student accounts or data.")
                .font(.footnote)
        }
    }
}

/// One program in a staff list: name, site and schedule, and how many are checked in today.
struct ProgramPickRow: View {
    @Environment(AppStore.self) private var store
    let program: Program

    private var roster: [Student] { store.roster(for: program.id) }

    private var checkedInCount: Int {
        roster.filter { store.hasAttended(studentID: $0.id, programID: program.id, on: .now) }.count
    }

    private var summary: String {
        roster.isEmpty ? "No students yet" : "\(checkedInCount) of \(roster.count) checked in today"
    }

    private var isEveryoneIn: Bool {
        !roster.isEmpty && checkedInCount == roster.count
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(program.name)
                .font(.headline)
            Text("\(program.site) · \(program.schedule)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Label(summary, systemImage: isEveryoneIn ? "checkmark.circle.fill" : "person.2.fill")
                .font(.footnote.weight(.semibold))

            // A small progress bar. The words above carry the meaning, so it can be quiet.
            if !roster.isEmpty {
                ProgressView(value: Double(checkedInCount), total: Double(roster.count))
                    .tint(Theme.progress)
                    .accessibilityHidden(true)
            }
        }
        .padding(.vertical, 4)
        .frame(minHeight: 44, alignment: .leading)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(program.name) at \(program.site), \(program.schedule). \(summary).")
    }
}
