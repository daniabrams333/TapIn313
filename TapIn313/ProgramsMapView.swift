import SwiftUI
import MapKit

/// Programs on a map, one pin per site. A site with one program opens its detail page.
/// A site that hosts several programs shows a short list first.
/// Also has a key, a "show my location" button (asks permission only when tapped), and
/// a "show all programs" button that fits every pin back on screen.
/// Must sit inside a NavigationStack that handles `Program` destinations.
struct ProgramsMapView: View {
    let programs: [Program]
    let upNextProgramID: String?

    @Environment(\.openURL) private var openURL
    @State private var position: MapCameraPosition
    /// What the map is showing right now. Zoom buttons scale this.
    @State private var visibleRegion: MKCoordinateRegion?
    @State private var selectedSite: Site?
    @State private var location = LocationAccess()
    @State private var showsKey = false
    @State private var wantsMyLocation = false
    @State private var showsLocationOffAlert = false

    /// Fits every program on screen. Also where the map falls back to if location isn't available.
    private let overview: MapCameraPosition

    init(programs: [Program], upNextProgramID: String?) {
        self.programs = programs
        self.upNextProgramID = upNextProgramID
        let overview = MapCameraPosition.region(Self.region(fitting: programs))
        self.overview = overview
        _position = State(initialValue: overview)
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
            if location.isAuthorized {
                UserAnnotation()
            }
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
        .overlay(alignment: .topLeading) {
            Text("\(sites.count) sites · \(programs.count) programs")
                .font(.footnote.weight(.semibold))
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(.regularMaterial, in: Capsule())
                .padding(12)
        }
        .overlay(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 8) {
                        if showsKey {
                            MapKeyView()
                        }
                        keyButton
                    }
                    Spacer(minLength: 8)
                    VStack(spacing: 8) {
                        MapCircleButton(symbol: "plus", label: "Zoom in") {
                            zoom(by: 0.5)
                        }
                        MapCircleButton(symbol: "minus", label: "Zoom out") {
                            zoom(by: 2)
                        }
                        MapCircleButton(symbol: "location.fill", label: "Show my location") {
                            showMyLocation()
                        }
                        MapCircleButton(symbol: "arrow.up.left.and.arrow.down.right", label: "Show all programs") {
                            withAnimation { position = overview }
                        }
                    }
                }
                if let selectedSite {
                    SiteCard(site: selectedSite.name, programs: selectedSite.programs) {
                        self.selectedSite = nil
                    }
                }
            }
            .padding(16)
        }
        .onMapCameraChange(frequency: .onEnd) { context in
            visibleRegion = context.region
        }
        .animation(.default, value: selectedSite)
        .animation(.default, value: showsKey)
        .onChange(of: location.status) {
            // The student just answered the permission prompt after tapping "Show my location".
            guard wantsMyLocation else { return }
            wantsMyLocation = false
            if location.isAuthorized {
                withAnimation { position = .userLocation(fallback: overview) }
            }
        }
        .alert("Location is off", isPresented: $showsLocationOffAlert) {
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) { openURL(url) }
            }
            Button("Not now", role: .cancel) {}
        } message: {
            Text("Turn on Location for Tap In in Settings to see where you are on the map.")
        }
    }

    // MARK: Zoom

    /// A factor below 1 zooms in, above 1 zooms out. Keeps the same center and stays within sensible limits.
    private func zoom(by factor: Double) {
        guard let region = visibleRegion else { return }
        let span = MKCoordinateSpan(
            latitudeDelta: min(max(region.span.latitudeDelta * factor, 0.002), 1.0),
            longitudeDelta: min(max(region.span.longitudeDelta * factor, 0.002), 1.0)
        )
        withAnimation {
            position = .region(MKCoordinateRegion(center: region.center, span: span))
        }
    }

    // MARK: Location

    private func showMyLocation() {
        if location.isAuthorized {
            withAnimation { position = .userLocation(fallback: overview) }
        } else if location.isDenied {
            showsLocationOffAlert = true
        } else {
            wantsMyLocation = true
            location.request()
        }
    }

    // MARK: Pins

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

    private var keyButton: some View {
        Button {
            showsKey.toggle()
        } label: {
            Label(showsKey ? "Hide key" : "Key", systemImage: "list.bullet.rectangle")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Theme.primary)
                .padding(.horizontal, 14)
                .frame(minHeight: 44)
                .background(Color(.systemBackground), in: Capsule())
                .shadow(radius: 3)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(showsKey ? "Hide map key" : "Show map key")
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

private struct MapCircleButton: View {
    let symbol: String
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.body.weight(.semibold))
                .foregroundStyle(Theme.primary)
                .frame(width: 44, height: 44)
                .background(Color(.systemBackground), in: Circle())
                .shadow(radius: 3)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
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
