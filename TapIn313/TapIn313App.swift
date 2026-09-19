import SwiftUI

// App name: Tap In 313. Xcode project and target: TapIn313. Home screen display name: Tap In.
@main
struct TapIn313App: App {
    @State private var store = AppStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(store)
                .tint(Theme.primary)
                // The City palette is defined for light backgrounds, so the demo stays in light mode.
                .preferredColorScheme(.light)
        }
    }
}

struct RootView: View {
    @Environment(AppStore.self) private var store

    var body: some View {
        switch store.mode {
        case .student: StudentTabs()
        case .staff: StaffHomeView()
        }
    }
}

// MARK: - Student tabs (placeholders, replaced block by block)

struct StudentTabs: View {
    @Environment(AppStore.self) private var store

    var body: some View {
        TabView {
            ProgramsScreen()
                .tabItem { Label("Programs", systemImage: "map.fill") }
            PathScreen()
                .tabItem { Label("My path", systemImage: "signpost.right.fill") }
            RewardsScreen()
                .tabItem { Label("Rewards", systemImage: "gift.fill") }
            ProfileScreen()
                .tabItem { Label("Profile", systemImage: "person.crop.circle.fill") }
        }
        // Presents pending celebrations one at a time. Dismissing shows the next one.
        .sheet(item: Binding(
            get: { store.pendingUnlocks.first },
            set: { _ in store.dismissUnlock() }
        )) { unlock in
            UnlockPlaceholder(unlock: unlock)
        }
    }
}

struct PathScreen: View {
    @Environment(AppStore.self) private var store

    var body: some View {
        NavigationStack {
            List {
                if let track = store.currentTrack(for: store.currentStudentID) {
                    Section(track.name) {
                        ForEach(Array(track.levels.enumerated()), id: \.offset) { index, level in
                            let progress = store.levelProgress(track, levelIndex: index, studentID: store.currentStudentID)
                            let done = store.isLevelComplete(track, levelIndex: index, studentID: store.currentStudentID)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(level.title).font(.headline)
                                Text(store.program(level.programID)?.name ?? "")
                                    .font(.subheadline)
                                Text(done
                                     ? "Complete"
                                     : "\(progress.done) of \(progress.required) sessions, +\(level.bonusPoints) bonus points")
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        Text("At the end: \(track.payoff)")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                Section("Switch track") {
                    ForEach(store.tracks) { track in
                        Button(track.name) {
                            store.chooseTrack(track.id, for: store.currentStudentID)
                        }
                    }
                }
            }
            .navigationTitle("My path")
        }
    }
}

struct RewardsScreen: View {
    @Environment(AppStore.self) private var store

    var body: some View {
        NavigationStack {
            List(store.merchants) { merchant in
                Text(merchant.name).font(.headline)
            }
            .navigationTitle("Rewards")
        }
    }
}

// MARK: - Celebration placeholder (replaced by the real unlock moment)

struct UnlockPlaceholder: View {
    @Environment(AppStore.self) private var store
    let unlock: Unlock

    var body: some View {
        VStack(spacing: 12) {
            Text(headline).font(.title).multilineTextAlignment(.center)
            Text(detail).font(.body).multilineTextAlignment(.center)
            Button("Keep going") { store.dismissUnlock() }
                .buttonStyle(.borderedProminent)
        }
        .padding()
        .presentationDetents([.medium])
    }

    private var headline: String {
        switch unlock {
        case .level(let trackID, let levelIndex):
            let title = store.track(trackID)?.levels[safe: levelIndex]?.title ?? "Level"
            return "\(title) level complete!"
        case .track(let trackID):
            return "\(store.track(trackID)?.name ?? "Track") complete!"
        case .badge(let badge):
            return "New badge: \(badge.name)"
        }
    }

    private var detail: String {
        switch unlock {
        case .level(let trackID, let levelIndex):
            let bonus = store.track(trackID)?.levels[safe: levelIndex]?.bonusPoints ?? 0
            return "You earned \(bonus) bonus points."
        case .track(let trackID):
            return store.track(trackID)?.payoff ?? ""
        case .badge(let badge):
            return badge.detail
        }
    }
}

extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

// MARK: - Staff mode (placeholder)

struct StaffHomeView: View {
    @Environment(AppStore.self) private var store

    var body: some View {
        NavigationStack {
            List {
                Text("Staff mode: pick a program, then confirm attendance.")
                    .font(.body)
                Button("Back to student mode") { store.mode = .student }
            }
            .navigationTitle("Staff")
        }
    }
}
