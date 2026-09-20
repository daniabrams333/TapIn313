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
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var showsSplash = true

    var body: some View {
        ZStack {
            switch store.mode {
            case .student: StudentTabs()
            case .staff: StaffHomeView()
            }

            if showsSplash {
                SplashScreen()
                    .transition(.opacity)
            }
        }
        .task {
            try? await Task.sleep(for: .seconds(1.3))
            // With Reduce Motion on, the splash just disappears instead of fading.
            withAnimation(reduceMotion ? nil : .easeOut(duration: 0.4)) {
                showsSplash = false
            }
        }
    }
}

// MARK: - Student tabs (placeholders, replaced block by block)

struct StudentTabs: View {
    @Environment(AppStore.self) private var store

    var body: some View {
        TabView(selection: Binding(
            get: { store.studentTab },
            set: { store.studentTab = $0 }
        )) {
            ProgramsScreen()
                .tabItem { Label("Programs", systemImage: "map.fill") }
                .tag(StudentTab.programs)
            PathScreen()
                .tabItem { Label("My path", systemImage: "signpost.right.fill") }
                .tag(StudentTab.path)
            RewardsScreen()
                .tabItem { Label("Rewards", systemImage: "gift.fill") }
                .tag(StudentTab.rewards)
            ProfileScreen()
                .tabItem { Label("Profile", systemImage: "person.crop.circle.fill") }
                .tag(StudentTab.profile)
        }
        // Presents pending celebrations one at a time. Dismissing shows the next one.
        .sheet(item: Binding(
            get: { store.pendingUnlocks.first },
            set: { _ in store.dismissUnlock() }
        )) { unlock in
            // .id makes each celebration start fresh, so its animation plays again for the next one.
            UnlockMomentView(unlock: unlock)
                .id(unlock.id)
        }
    }
}

extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

