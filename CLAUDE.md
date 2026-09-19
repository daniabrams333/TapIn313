# Tap In 313

App name: **Tap In 313** (the 313 is Detroit's area code). Xcode project and target: `TapIn313`. Home screen display name: "Tap In". Gift card codes start with `TAP-`. The name also matches the core mechanic: staff tap to confirm a student's attendance.

A mobile rewards app that gets Detroit students into after-school programs and shows them what to do next. Students earn points and badges by attending programs, follow an interest track that connects programs into a path, and redeem points for digital gift cards at local restaurants and stores.

**Deadline:** working demo and public site by Monday, September 21, 2026 at 8:00 AM. Scope is locked. Do not add features that are not listed here.

See PLAN.md for the hour-by-hour schedule and status checklist. Tick checkboxes in PLAN.md as tasks are finished.

## The problem we address
The City is expanding access to after-school programming. Our job is participation: getting students through the door and giving them a clear path so programs stop feeling disjointed. We complement GOAL Line Detroit. We do not compete with it and we do not claim a partnership with it.

## Audience
Students in grades 6 to 8 (the older end of GOAL Line's K-8 range), with a parent or guardian involved. Grades 9 to 12 and parent accounts are roadmap.

## Locked scope

One iOS app with two modes on one in-memory store. When staff confirm attendance, the student's points, level progress, and badges update instantly. No backend.

**Student mode**
- Programs as a map and a list. Detail page shows site, venue type, schedule, grades, address, points earned, and a "Free ride from your school" tag.
- **Interest tracks:** four tracks, three levels each (Explore, Build, Launch), each level tied to one program and 2 sessions. Finishing a level pays bonus points and plays an unlock moment. Finishing a track shows its payoff.
- **"Up next" card** at the top of the Programs tab shows the next program on the student's path. This is the answer to "what's next."
- **My path** tab shows the tracks, level progress ("1 of 2 sessions"), and a way to switch tracks.
- Join a program.
- Profile with avatar, points balance, badges, and activity history. History shows "Checked in by staff at [time]."
- Rewards catalog grouped by local merchant. Redeeming deducts points and shows a digital gift card code.
- Unlock moments, shown in order: level complete, track complete, then badges.

**Staff mode**
- Pick a program, see its roster, tap to confirm a student's attendance. Confirming awards the program's points.

**Out of scope (roadmap slide only):** real login, live backend, real merchant integrations, push notifications, leaderboards, parent accounts and "arrived safely" notifications, "Near my school" distance and 2-mile filter, waitlists and spots left, streak badges, parental consent flow, grades 9 to 12.

## Data honesty (important)
Real: GOAL Line site names, GOAL Line activity names, the list of libraries that host tutoring.
Sample: which activity runs at which site, days and times, descriptions, points, tracks, track payoffs, students, and all merchants.
- Programs screen and the public site must say: "Site and activity names come from GOAL Line Detroit. Schedules and details are samples for this demo."
- Never present a track payoff, merchant, or schedule as real or confirmed.
- Addresses and coordinates came from a map lookup. Spot-check before presenting.

## Tracks
| Track | Explore | Build | Launch |
|---|---|---|---|
| Tech Builder | Robotics | Coding and Tech Club | AI Coding |
| Creator | Art Club | Music Studio: Music Creation | Podcasting |
| Maker and Entrepreneur | Leather Making | Financial Literacy | Content Creation |
| Athlete | Basketball Drills | Track and Field | Swimming |

Level bonuses: 25, 40, 60 points. Level completion is recorded once and never paid twice.

## Demo story (3 minutes)
1. Jordan (grade 7, Tech Builder, 60 points) opens the app and sees "Up next: Robotics" with a free-ride tag.
2. Browse programs on the map and in the list.
3. Staff mode: confirm Jordan's second Robotics session.
4. Student mode: level complete moment (+25), then Century Club badge (105 points), and "Up next" moves to Coding and Tech Club at Conely Library.
5. Jordan redeems a reward from a local restaurant and sees the code.

If time runs short, cut map polish and the badge animation first. Never cut the track path, "Up next," or the earn-then-redeem loop.

## Architecture
- SwiftUI, iOS 17+, `@Observable` store injected with `.environment(store)`.
- `AppStore` (AppStore.swift) is the single source of truth. Points balance is always derived: attendance points plus level bonuses minus redemptions. Never store a balance separately.
- Mock data lives in MockData.swift.
- `store.resetDemo()` restores the starting demo state.
- Do not add SwiftData, CloudKit, or a network layer for this build.

## Conventions
- Use semantic SwiftUI font styles (`.headline`, `.body`, `.title2`). Never hardcode font sizes. Support Dynamic Type.
- Use `Theme` colors only. Never hardcode hex values in views. Use the paired text colors (`Theme.onPrimary`, `Theme.onHighlight`, and so on) so contrast stays accessible.
- The app stays in light mode (`.preferredColorScheme(.light)`) because the City palette is defined for light backgrounds. A dark palette is roadmap.
- Use `Theme.highlight` (Accent Yellow) sparingly, for points, badges, and key calls to action, with Rise Blue text.
- Never convey meaning with color alone. Pair color with an icon or text (for example a checkmark and the word "Complete").
- Every tappable element needs an accessibility label and a minimum 44 pt hit target.
- One screen per file. Keep it compiling at every step. Commit after each working screen.

## Brand and colors
Palette follows the City of Detroit Brand Guide Standards v2.0 (June 2026). This is an independent project. It is not an official City app and must not look like one.
- Rise Blue `#1D3A6B`: app tint, primary buttons, student headers (white text).
- City Green `#004445`: staff mode (white text).
- Spirit Green `#279989`: progress bars and checkmarks. Never small text on white (only about 3.5:1). Dark text only on top of it.
- Light Green `#9FD5B3`: soft fills such as a completed level card (Rise Blue text).
- Accent Yellow `#FEB70D`: points, badges, calls to action (Rise Blue text, never white).
- Neutrals: use iOS system grays. The guide names light grey and beige for merchandise but gives no hex values.
- Do NOT use the City of Detroit logo or the "Rise Higher" tagline anywhere. The guide limits them to City departments, partners, and authorized vendors.
- The City's accessibility standard is WCAG 2.1 AA: 4.5:1 text contrast, no light-weight fonts for body text, 16 pt or larger on the web.
- Voice: sincere, jargon-free, neighbor to neighbor. Example: "Your next step starts here." The Up next section uses that line.
- Fonts: the app uses system fonts (Dynamic Type) for the demo. The public site uses Montserrat for headlines and body and Roboto for tables and forms, both from Google Fonts. Avoid other fonts.
- Photos: the City discourages AI-generated and stock imagery. Use real screenshots of the app on the site.

## Privacy note
Students are minors. Mock data uses first name and last initial only. Do not add fields for full names, photos, home address, or precise location. Under-13 use would need verified parental consent, which is roadmap.

## Facts for the public site (from the City of Detroit announcement)
- $2.2 million City investment (not $22 million) to expand GOAL Line Detroit after-school programming.
- Seven new sites: Helen Moore, Coleman A. Young, Williams, and A.B. Ford Recreation Centers, and Conely, Lincoln, and Chaney Libraries. Added to 33 existing locations and partners for a total of 40.
- GOAL Line has served 2,708 K-8 students since 2018. The expansion adds up to 1,000 more, for about 3,700 total. Use the City's wording ("since 2018"). Some news coverage says "currently serves"; do not repeat that.
- Nearly 60 programs and activities. Locations in every City Council district. New sites were chosen for areas that were previously underserved.
- Transportation to and from school is part of GOAL Line. Two behavioral specialists support students' social and emotional needs.
- Benefits the City lists: academic improvement, socioemotional improvement, drug and violence prevention, character development, leadership development.
- Framing: the City is opening the doors. We help students walk through them and know where to go next.

## Build order
1. Program list, detail, and map (with Up next card)
2. Profile, points, badges, history
3. My path: track picker, level progress, unlock moments
4. Rewards catalog and redeem flow
5. Staff attendance mode
6. Full loop wiring, then polish (unlock animation, empty states, app icon, accessibility)
