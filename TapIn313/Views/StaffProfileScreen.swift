import SwiftUI

/// The staff member's profile, opened from the person icon at the top right of staff screens.
/// Also where staff switch over to student mode.
struct StaffProfileScreen: View {
    @Environment(AppStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        let staff = store.staffMember
        let stats = StaffStats(store: store)

        NavigationStack {
            List {
                Section {
                    VStack(spacing: 10) {
                        AvatarView(displayName: staff.displayName, colorIndex: staff.colorIndex, size: 96)
                        Text(staff.displayName)
                            .font(.title2.bold())
                        Label(staff.role, systemImage: "checkmark.shield.fill")
                            .font(.subheadline)
                    }
                    .foregroundStyle(Theme.onStaff)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("\(staff.displayName), \(staff.role)")
                }
                .listRowBackground(Theme.staff)

                Section {
                    LabeledContent("Check-ins confirmed", value: "\(stats.checkInsToday)")
                    LabeledContent("Points awarded", value: "\(stats.pointsToday)")
                    LabeledContent("Programs with check-ins", value: "\(stats.programsWithCheckInsToday) of \(stats.programsWithRosters)")
                } header: {
                    Text("Today")
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .textCase(nil)
                }

                Section {
                    Button {
                        store.mode = .student
                    } label: {
                        Label("Switch to student mode", systemImage: "person.fill")
                            .font(.headline)
                            .foregroundStyle(Theme.onStaff)
                            .frame(maxWidth: .infinity, minHeight: 44)
                    }
                    .listRowBackground(Theme.staff)
                } footer: {
                    Text("This is a sample profile. Tap In 313 has no real staff or student accounts.")
                        .font(.footnote)
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                        .frame(minHeight: 44)
                }
            }
        }
        // The sheet sits on a white background, so it needs the green tint, not the bar's white one.
        .tint(Theme.staff)
    }
}
