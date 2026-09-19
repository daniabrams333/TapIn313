import SwiftUI
import MapKit

/// Programs on a map, one pin per site. A site with one program opens its detail page.
/// A site that hosts several programs shows a short list first.
/// Must sit inside a NavigationStack that handles `Program` destinations.
struct ProgramsMapView: View {
    let programs: [Program]
    let upNextProgramID: String?

    @State private var position: MapCameraPosition
    @State private var selectedSite: Site?

    init(programs: [Program], upNextProgramID: String?) {
        self.programs = programs
        self.upNextProgramID = upNextProgramID
        _position = State(initialValue: .region(Self.region(fitting: programs)))
    }

    /// All programs that share one site, so overlapping pins become a single pin.
    private struct Site: Identifiable, Hashable {
        let name: String
        let coordinate: CLLocationCoordinate2D
        let programs: [Program]
        var id: String { name }

        static func == (lhs: Site, rhs: Site) -> Bool { lhs.id == rhs.id }
        func hash(into hasher: inout Hasher) { hasher.combine(id) }
    }

    private var sites: [Site] {
        var order: [String] = []
        var grouped: [String: [Program]] = [:]
        for program in programs {
            if grouped[program.site] == nil { order.append(program.site) }
            grouped[program.site, default: []].append(program)
        }
        return order.compactMap { name in
            guard let members = grouped[name], let first = members.first else { return nil }
            return Site(name: name, coordinate: first.coordinate, programs: members)
        }
    }

    var body: some View {
        Map(position: $position) {
            ForEach(sites) { site in
                Annotation(site.name, coordinate: site.coordinate, anchor: .bottom) {
                    pin(for: site)
                }
            }
        }
        .mapControls {
            MapCompass()
            MapScaleView()
        }
        .overlay(alignment: .bottom) {
            if let selectedSite {
                SiteCard(site: selectedSite.name, programs: selectedSite.programs) {
                    self.selectedSite = nil
                }
                .padding(16)
            }
        }
        .animation(.default, value: selectedSite)
    }

    @ViewBuilder
    private func pin(for site: Site) -> some View {
        let isUpNext = site.programs.contains { $0.id == upNextProgramID }
        if let only = site.programs.first, site.programs.count == 1 {
            NavigationLink(value: only) {
                MapPin(symbol: only.category.symbol, count: 1, isUpNext: isUpNext)
            }
            .accessibilityLabel(pinLabel(site: site, isUpNext: isUpNext))
            .accessibilityHint("Opens program details")
        } else {
            Button {
                selectedSite = site
            } label: {
                MapPin(symbol: site.programs[0].venue.symbol, count: site.programs.count, isUpNext: isUpNext)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(pinLabel(site: site, isUpNext: isUpNext))
            .accessibilityHint("Shows the programs at this site")
        }
    }

    private func pinLabel(site: Site, isUpNext: Bool) -> String {
        let names = site.programs.map(\.name).formatted(.list(type: .and))
        return (isUpNext ? "Up next. " : "") + "\(site.name): \(names)"
    }

    /// A region that shows every program with some breathing room.
    private static func region(fitting programs: [Program]) -> MKCoordinateRegion {
        let lats = programs.map(\.latitude)
        let lons = programs.map(\.longitude)
        guard let minLat = lats.min(), let maxLat = lats.max(),
              let minLon = lons.min(), let maxLon = lons.max() else {
            // Downtown Detroit
            return MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 42.3314, longitude: -83.0458),
                span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
            )
        }
        return MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2, longitude: (minLon + maxLon) / 2),
            span: MKCoordinateSpan(
                latitudeDelta: (maxLat - minLat) * 1.3 + 0.02,
                longitudeDelta: (maxLon - minLon) * 1.3 + 0.02
            )
        )
    }
}

// MARK: - Pieces

private struct MapPin: View {
    let symbol: String
    let count: Int
    let isUpNext: Bool

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Image(systemName: symbol)
                .font(.body.weight(.semibold))
                .foregroundStyle(isUpNext ? Theme.onHighlight : Theme.onPrimary)
                .frame(width: 44, height: 44)
                .background(isUpNext ? Theme.highlight : Theme.primary, in: Circle())
                .overlay(Circle().strokeBorder(.white, lineWidth: 2))
                .shadow(radius: 2)

            // Extras carry a symbol or number, so the pin never relies on color alone.
            if isUpNext {
                Image(systemName: "star.fill")
                    .font(.caption2)
                    .foregroundStyle(Theme.onHighlight)
                    .padding(4)
                    .background(Theme.highlight, in: Circle())
                    .overlay(Circle().strokeBorder(Theme.onHighlight, lineWidth: 1))
                    .offset(x: 6, y: -6)
            } else if count > 1 {
                Text("\(count)")
                    .font(.caption2.bold())
                    .foregroundStyle(Theme.onHighlight)
                    .frame(minWidth: 20, minHeight: 20)
                    .background(Theme.highlight, in: Circle())
                    .offset(x: 6, y: -6)
            }
        }
    }
}

private struct SiteCard: View {
    let site: String
    let programs: [Program]
    let onClose: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(site)
                    .font(.headline)
                Spacer()
                Button(action: onClose) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                        .frame(width: 44, height: 44)
                }
                .accessibilityLabel("Close")
            }
            ForEach(programs) { program in
                NavigationLink(value: program) {
                    HStack {
                        Text(program.name)
                            .font(.body)
                            .foregroundStyle(.primary)
                        Spacer()
                        PointsPill(points: program.points)
                        Image(systemName: "chevron.right")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(.secondary)
                            .accessibilityHidden(true)
                    }
                    .frame(minHeight: 44)
                    .contentShape(Rectangle())
                }
                .accessibilityLabel("\(program.name), earns \(program.points) points")
                .accessibilityHint("Opens program details")
            }
        }
        .padding(16)
        .background(Color(.systemBackground), in: RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 6)
    }
}
