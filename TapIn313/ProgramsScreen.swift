import SwiftUI

/// Programs tab: the "Up next" card, a category filter, and the list of programs.
struct ProgramsScreen: View {
    @Environment(AppStore.self) private var store
    @State private var selectedCategory: ProgramCategory?

    private var filteredPrograms: [Program] {
        guard let selectedCategory else { return store.programs }
        return store.programs.filter { $0.category == selectedCategory }
    }

    var body: some View {
        NavigationStack {
            List {
                if let next = store.upNext(for: store.currentStudentID) {
                    Section {
                        NavigationLink(value: next.program) {
                            UpNextCard(trackName: next.track.name, levelTitle: next.level.title, program: next.program)
                        }
                        .listRowBackground(Theme.primary)
                    } header: {
                        Text("Your next step starts here")
                            .font(.headline)
                            .foregroundStyle(.primary)
                            .textCase(nil)
                    }
                }

                Section {
                    CategoryFilter(selected: $selectedCategory)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)

                    if filteredPrograms.isEmpty {
                        Text("No programs in this category yet.")
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                    ForEach(filteredPrograms) { program in
                        NavigationLink(value: program) {
                            ProgramRow(program: program)
                        }
                    }
                } header: {
                    Text("All programs")
                        .font(.headline)
                        .foregroundStyle(.primary)
                        .textCase(nil)
                }

                Section {
                    Text("Site and activity names come from GOAL Line Detroit. Schedules and details are samples for this demo. Tap In 313 is an independent project and is not an official City of Detroit app.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Programs")
            .navigationDestination(for: Program.self) { program in
                ProgramDetailScreen(program: program)
            }
        }
    }
}

// MARK: - Pieces

private struct UpNextCard: View {
    let trackName: String
    let levelTitle: String
    let program: Program

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("\(trackName) · \(levelTitle)")
                .font(.subheadline)
            Text(program.name)
                .font(.title2.bold())
            Text("\(program.site) · \(program.schedule)")
                .font(.subheadline)
            if program.offersFreeRide {
                Label("Free ride from your school", systemImage: "bus.fill")
                    .font(.footnote.bold())
                    .padding(.top, 2)
            }
        }
        .foregroundStyle(Theme.onPrimary)
        .padding(.vertical, 8)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Up next: \(program.name) at \(program.site), \(program.schedule). \(trackName), \(levelTitle) level.")
        .accessibilityHint("Opens program details")
    }
}

private struct ProgramRow: View {
    let program: Program

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline) {
                Text(program.name)
                    .font(.headline)
                Spacer(minLength: 8)
                PointsPill(points: program.points)
            }
            Label(program.site, systemImage: program.venue.symbol)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            if program.offersFreeRide {
                Label("Free ride from your school", systemImage: "bus.fill")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
        .frame(minHeight: 44, alignment: .leading)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(
            "\(program.name) at \(program.site). Earns \(program.points) points."
            + (program.offersFreeRide ? " Free ride from your school." : "")
        )
    }
}

private struct CategoryFilter: View {
    @Binding var selected: ProgramCategory?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                chip(title: "All", symbol: "square.grid.2x2.fill", isOn: selected == nil) {
                    selected = nil
                }
                ForEach(ProgramCategory.allCases) { category in
                    chip(title: category.title, symbol: category.symbol, isOn: selected == category) {
                        selected = category
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 4)
        }
    }

    private func chip(title: String, symbol: String, isOn: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                // A checkmark and a filled shape, so the selected state never relies on color alone.
                Image(systemName: isOn ? "checkmark" : symbol)
                Text(title)
            }
            .font(.subheadline.weight(.semibold))
            .padding(.horizontal, 14)
            .frame(minHeight: 44)
            .foregroundStyle(isOn ? Theme.onPrimary : Theme.primary)
            .background(isOn ? Theme.primary : Color.clear, in: Capsule())
            .overlay(Capsule().strokeBorder(Theme.primary, lineWidth: 1.5))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
        .accessibilityAddTraits(isOn ? .isSelected : [])
    }
}
