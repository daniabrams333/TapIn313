import SwiftUI

/// Staff mode on iPhone: intro, numbers at a glance, then the programs to pick from.
struct StaffPhoneView: View {
    @Environment(AppStore.self) private var store

    private var programs: [Program] {
        store.programs.sorted { $0.name < $1.name }
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    StaffIntroBanner()
                }
                .listRowBackground(Theme.staff)

                Section {
                    StaffDashboardView()
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .listRowBackground(Color.clear)
                } header: {
                    Text("At a glance")
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .textCase(nil)
                }

                Section {
                    ForEach(programs) { program in
                        NavigationLink(value: program) {
                            ProgramPickRow(program: program)
                        }
                    }
                } header: {
                    Text("Pick a program")
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .textCase(nil)
                }

                StaffDemoControlsSection()
            }
            // Breathing room so the green card doesn't run into the green navigation bar.
            .contentMargins(.top, 16, for: .scrollContent)
            .navigationTitle("Staff")
            .staffBar()
            .navigationDestination(for: Program.self) { program in
                StaffRosterScreen(program: program)
            }
            .brandMark(onDark: true)
            .staffProfileButton()
        }
        .tint(Theme.onStaff)
    }
}
