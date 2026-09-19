import SwiftUI

/// Staff mode on iPad: a sidebar with Overview and every program, and a detail pane that shows
/// either the dashboard or the selected program's roster.
struct StaffSplitView: View {
    @Environment(AppStore.self) private var store
    @State private var selection: StaffSelection? = .overview

    private enum StaffSelection: Hashable {
        case overview
        case program(String)
    }

    private var programs: [Program] {
        store.programs.sorted { $0.name < $1.name }
    }

    var body: some View {
        NavigationSplitView {
            List(selection: $selection) {
                Label("Overview", systemImage: "chart.bar.fill")
                    .font(.headline)
                    .frame(minHeight: 44, alignment: .leading)
                    .tag(StaffSelection.overview)

                Section {
                    ForEach(programs) { program in
                        ProgramPickRow(program: program)
                            .tag(StaffSelection.program(program.id))
                    }
                } header: {
                    Text("Programs")
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .textCase(nil)
                }

                StaffDemoControlsSection()
            }
            .navigationTitle("Staff")
            .tint(Theme.staff)
        } detail: {
            NavigationStack {
                detail
            }
            .tint(Theme.onStaff)
        }
    }

    @ViewBuilder
    private var detail: some View {
        switch selection ?? .overview {
        case .overview:
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    StaffIntroBanner()
                        .padding(16)
                        .background(Theme.staff, in: RoundedRectangle(cornerRadius: 16))
                    StaffDashboardView()
                }
                .padding(20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Overview")
            .navigationBarTitleDisplayMode(.inline)
            .staffBar()
            .toolbar { StudentModeToolbarItem() }

        case .program(let id):
            if let program = store.program(id) {
                StaffRosterScreen(program: program)
            } else {
                ContentUnavailableView("Program not found", systemImage: "questionmark.circle")
            }
        }
    }
}
