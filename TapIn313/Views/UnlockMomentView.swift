import SwiftUI

/// The celebration a student sees when something unlocks: a level, a track, or a badge.
/// Shown full height on Rise Blue, one at a time, in the order the store queued them.
/// With Reduce Motion on, there is no confetti or movement, only quick fades.
struct UnlockMomentView: View {
    @Environment(AppStore.self) private var store
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    let unlock: Unlock
    @State private var revealed = false

    /// How many more celebrations are waiting after this one.
    private var remaining: Int { max(store.pendingUnlocks.count - 1, 0) }

    var body: some View {
        ZStack {
            Theme.primary.ignoresSafeArea()

            if !reduceMotion {
                PixelConfetti()
                    .ignoresSafeArea()
            }

            // Short screens sit in the middle. Long ones (or big text sizes) scroll.
            GeometryReader { proxy in
                ScrollView {
                    VStack(spacing: 24) {
                        Spacer(minLength: 0)

                        content

                        if remaining > 0 {
                            Text("\(remaining) more to see")
                                .font(.footnote.weight(.semibold))
                                .reveal(revealed, order: 6)
                        }

                        Button {
                            store.dismissUnlock()
                        } label: {
                            Text(remaining > 0 ? "Next" : "Keep going")
                                .font(.headline)
                                .foregroundStyle(Theme.onHighlight)
                                .frame(maxWidth: .infinity, minHeight: 44)
                                .padding(.vertical, 6)
                                .background(Theme.highlight, in: RoundedRectangle(cornerRadius: 14))
                        }
                        .buttonStyle(.plain)
                        .reveal(revealed, order: 7)

                        Spacer(minLength: 0)
                    }
                    .padding(24)
                    .frame(maxWidth: 560)
                    .frame(maxWidth: .infinity, minHeight: proxy.size.height)
                }
                .scrollBounceBehavior(.basedOnSize)
            }
        }
        .foregroundStyle(Theme.onPrimary)
        .multilineTextAlignment(.center)
        .presentationDetents([.large])
        .sensoryFeedback(.success, trigger: revealed)
        .onAppear {
            withAnimation { revealed = true }
            AccessibilityNotification.Announcement(spokenSummary).post()
        }
    }

    @ViewBuilder
    private var content: some View {
        switch unlock {
        case .level(let trackID, let levelIndex):
            LevelUnlockContent(trackID: trackID, levelIndex: levelIndex, revealed: revealed)
        case .track(let trackID):
            TrackUnlockContent(trackID: trackID, revealed: revealed)
        case .badge(let badge):
            BadgeUnlockContent(badge: badge, revealed: revealed)
        }
    }

    private var spokenSummary: String {
        switch unlock {
        case .level(let trackID, let levelIndex):
            let level = store.track(trackID)?.levels[safe: levelIndex]
            return "Level complete. \(level?.title ?? "Level") complete. \(level?.bonusPoints ?? 0) bonus points."
        case .track(let trackID):
            return "Track complete. \(store.track(trackID)?.name ?? "Track") complete."
        case .badge(let badge):
            return "New badge. \(badge.name). \(badge.detail)"
        }
    }
}

// MARK: - Shared pieces for the unlock content views

extension View {
    /// Fades and slides up into place. `order` staggers the timing so items arrive one after another.
    func reveal(_ revealed: Bool, order: Int = 0) -> some View {
        modifier(RevealModifier(revealed: revealed, order: order))
    }

    /// Springs in from small, like a stamp landing.
    func popIn(_ revealed: Bool) -> some View {
        modifier(PopInModifier(revealed: revealed))
    }
}

private struct RevealModifier: ViewModifier {
    let revealed: Bool
    let order: Int
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .opacity(revealed ? 1 : 0)
            .offset(y: revealed || reduceMotion ? 0 : 18)
            .animation(
                reduceMotion ? .easeIn(duration: 0.2) : .easeOut(duration: 0.5).delay(0.15 * Double(order)),
                value: revealed
            )
    }
}

private struct PopInModifier: ViewModifier {
    let revealed: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .scaleEffect(revealed || reduceMotion ? 1 : 0.2)
            .opacity(revealed ? 1 : 0)
            .animation(
                reduceMotion ? .easeIn(duration: 0.2) : .spring(response: 0.55, dampingFraction: 0.5).delay(0.1),
                value: revealed
            )
    }
}

/// A big yellow tile with a pixel picture on it. The picture uses the same colors as an earned badge.
struct HeroTile: View {
    let rows: [String]
    let revealed: Bool
    @ScaledMetric(relativeTo: .largeTitle) private var side: CGFloat = 132

    var body: some View {
        PixelSprite(rows: rows, colors: ["#": Theme.onHighlight, "w": .white, "g": Theme.staff])
            .padding(side * 0.12)
            .frame(width: side, height: side)
            .background(Theme.highlight, in: RoundedRectangle(cornerRadius: side * 0.2))
            .popIn(revealed)
            .accessibilityHidden(true)
    }
}

/// "+25 bonus points" that counts up from zero. Jumps straight to the number with Reduce Motion on.
struct BonusCountUp: View {
    let points: Int
    let suffix: String
    let revealed: Bool
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var shown = 0

    var body: some View {
        Label {
            Text("+\(shown) \(suffix)")
                .contentTransition(.numericText(value: Double(shown)))
        } icon: {
            Image(systemName: "star.fill")
        }
        .font(.title2.bold())
        .foregroundStyle(Theme.onHighlight)
        .padding(.horizontal, 18)
        .padding(.vertical, 10)
        .background(Theme.highlight, in: Capsule())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Plus \(points) \(suffix)")
        .onChange(of: revealed) { _, isRevealed in
            guard isRevealed else { return }
            if reduceMotion {
                shown = points
            } else {
                Task { @MainActor in
                    try? await Task.sleep(for: .seconds(0.7))
                    withAnimation(.easeOut(duration: 0.9)) { shown = points }
                }
            }
        }
    }
}

/// A soft panel for grouping content on the Rise Blue background.
struct UnlockPanel<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        VStack(spacing: 8) {
            content
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(Theme.onPrimary.opacity(0.12), in: RoundedRectangle(cornerRadius: 16))
    }
}
