import SwiftUI
import Charts

/// Staff "at a glance": today's numbers, check-ins for the last seven days, who is one session
/// from a level-up, and the latest check-ins. Made to sit inside a scroll view or a list row.
struct StaffDashboardView: View {
    @Environment(AppStore.self) private var store

    var body: some View {
        let stats = StaffStats(store: store)

        VStack(alignment: .leading, spacing: 16) {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 12, alignment: .top)], spacing: 12) {
                StatTile(
                    value: "\(stats.checkInsToday)",
                    label: "Checked in today",
                    detail: "\(stats.programsWithCheckInsToday) of \(stats.programsWithRosters) programs",
                    symbol: "person.fill.checkmark",
                    isHero: true
                )
                StatTile(
                    value: "\(stats.pointsToday)",
                    label: "Points awarded today",
                    detail: "Attendance and level bonuses",
                    symbol: "star.fill"
                )
                StatTile(
                    value: "\(stats.checkInsThisWeek)",
                    label: "Check-ins, last 7 days",
                    detail: "Across all programs",
                    symbol: "calendar"
                )
                StatTile(
                    value: "\(stats.enrolledStudents)",
                    label: "Students enrolled",
                    detail: "In at least one program",
                    symbol: "person.2.fill"
                )
            }

            WeekChartCard(days: stats.lastSevenDays)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 300), spacing: 12, alignment: .top)], spacing: 12) {
                CloseToLevelCard(items: stats.closeToLevelUp)
                RecentCheckInsCard(items: stats.recentCheckIns())
            }

            Text("Sample students and history, plus any check-ins you confirm in this demo.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Pieces

private struct Card<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            content
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground), in: RoundedRectangle(cornerRadius: 16))
    }
}

private struct StatTile: View {
    let value: String
    let label: String
    let detail: String
    let symbol: String
    var isHero = false

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Image(systemName: symbol)
                .font(.title3)
                .accessibilityHidden(true)
            Text(value)
                .font(.largeTitle.bold())
            Text(label)
                .font(.subheadline.weight(.semibold))
            Text(detail)
                .font(.footnote)
                .opacity(0.85)
        }
        .foregroundStyle(isHero ? Theme.onStaff : Color.primary)
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            isHero ? Theme.staff : Color(.secondarySystemGroupedBackground),
            in: RoundedRectangle(cornerRadius: 16)
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(label): \(value). \(detail).")
    }
}

/// One series, so one color, no legend, a quiet grid, and a single direct label on today's bar.
private struct WeekChartCard: View {
    let days: [StaffStats.DayCount]

    private var maxCount: Int { days.map(\.count).max() ?? 0 }

    var body: some View {
        Card {
            Text("Check-ins by day")
                .font(.headline)
                .accessibilityAddTraits(.isHeader)

            Chart(days) { day in
                BarMark(
                    x: .value("Day", day.date, unit: .day),
                    y: .value("Check-ins", day.count),
                    width: .ratio(0.6)
                )
                .foregroundStyle(Theme.staff)
                .cornerRadius(4)
                .annotation(position: .top, spacing: 2) {
                    // Label only today's bar, not every bar.
                    if Calendar.current.isDateInToday(day.date) && day.count > 0 {
                        Text("\(day.count)")
                            .font(.footnote.weight(.bold))
                    }
                }
                .accessibilityLabel(day.date.formatted(.dateTime.weekday(.wide).month().day()))
                .accessibilityValue("\(day.count) check-ins")
            }
            .chartYScale(domain: 0...max(3, maxCount + 1))
            .chartYAxis {
                AxisMarks(position: .leading, values: .automatic(desiredCount: 3)) { _ in
                    AxisGridLine().foregroundStyle(Color(.systemGray5))
                    AxisValueLabel().font(.caption).foregroundStyle(.secondary)
                }
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { _ in
                    AxisValueLabel(format: .dateTime.weekday(.abbreviated)).font(.caption)
                }
            }
            .frame(height: 170)
            .accessibilityLabel("Check-ins per day for the last 7 days")
        }
    }
}

private struct CloseToLevelCard: View {
    let items: [StaffStats.CloseToLevel]

    var body: some View {
        Card {
            Label("One session from a level-up", systemImage: "flag.checkered")
                .font(.headline)
                .accessibilityAddTraits(.isHeader)

            if items.isEmpty {
                Text("No one is one session away right now.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            ForEach(items) { item in
                HStack(spacing: 12) {
                    AvatarView(student: item.student, size: 40)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.student.displayName)
                            .font(.subheadline.weight(.semibold))
                        Text("\(item.trackName) · \(item.levelTitle): 1 more session of \(item.programName)")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("\(item.student.displayName), \(item.trackName), \(item.levelTitle) level. One more session of \(item.programName) to finish it.")
            }
        }
    }
}

private struct RecentCheckInsCard: View {
    let items: [StaffStats.CheckIn]

    private func when(_ date: Date) -> String {
        if Calendar.current.isDateInToday(date) {
            return "Today, \(date.formatted(date: .omitted, time: .shortened))"
        }
        return date.formatted(.dateTime.weekday(.abbreviated).month(.abbreviated).day())
    }

    var body: some View {
        Card {
            Label("Recent check-ins", systemImage: "clock.fill")
                .font(.headline)
                .accessibilityAddTraits(.isHeader)

            if items.isEmpty {
                Text("No check-ins yet.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            ForEach(items) { item in
                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(item.studentName) · \(item.programName)")
                            .font(.subheadline.weight(.semibold))
                        Text(when(item.date))
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    Spacer(minLength: 8)
                    Text("+\(item.points)")
                        .font(.subheadline.weight(.bold))
                }
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("\(item.studentName), \(item.programName), \(when(item.date)). \(item.points) points.")
            }
        }
    }
}
