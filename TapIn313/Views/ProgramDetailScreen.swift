import SwiftUI

/// Detail page for one program: site, venue type, schedule, grades, address, points, and join.
struct ProgramDetailScreen: View {
    @Environment(AppStore.self) private var store
    let program: Program

    private var isEnrolled: Bool {
        store.isEnrolled(studentID: store.currentStudentID, programID: program.id)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header
                Text(program.summary)
                    .font(.body)

                VStack(alignment: .leading, spacing: 16) {
                    DetailRow(symbol: "mappin.and.ellipse", title: "Site", value: program.site)
                    DetailRow(symbol: program.venue.symbol, title: "Venue type", value: program.venue.title)
                    DetailRow(symbol: "calendar", title: "Schedule", value: program.schedule)
                    DetailRow(symbol: "person.2.fill", title: "Grades", value: program.grades)
                    DetailRow(symbol: "house.fill", title: "Address", value: program.address)
                }

                if program.offersFreeRide {
                    Label("Free ride from your school", systemImage: "bus.fill")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.onSoftFill)
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Theme.softFill, in: RoundedRectangle(cornerRadius: 12))
                }

                joinButton

                Text("Site and activity names come from GOAL Line Detroit. Schedules and details are samples for this demo.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding(16)
        }
        .navigationTitle(program.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(program.category.title, systemImage: program.category.symbol)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(program.name)
                .font(.largeTitle.bold())
            PointsPill(points: program.points, suffix: "each time you attend")
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isHeader)
    }

    @ViewBuilder
    private var joinButton: some View {
        if isEnrolled {
            Label("You joined this program", systemImage: "checkmark.circle.fill")
                .font(.headline)
                .foregroundStyle(Theme.onSoftFill)
                .frame(maxWidth: .infinity, minHeight: 44)
                .padding(.vertical, 8)
                .background(Theme.softFill, in: RoundedRectangle(cornerRadius: 12))
                .accessibilityLabel("You joined \(program.name)")
        } else {
            Button {
                store.join(studentID: store.currentStudentID, programID: program.id)
            } label: {
                Text("Join this program")
                    .font(.headline)
                    .foregroundStyle(Theme.onHighlight)
                    .frame(maxWidth: .infinity, minHeight: 44)
                    .padding(.vertical, 8)
                    .background(Theme.highlight, in: RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Join \(program.name)")
        }
    }
}

// MARK: - Pieces

private struct DetailRow: View {
    let symbol: String
    let title: String
    let value: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: symbol)
                .font(.body)
                .foregroundStyle(Theme.primary)
                .frame(width: 28)
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.body)
            }
        }
        .accessibilityElement(children: .combine)
    }
}
