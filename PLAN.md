# Tap In 313: Build Plan

Read CLAUDE.md first for the locked scope, data rules, brand rules, and conventions. This file is the schedule and the status tracker. When you finish a task, tick its checkbox. Do not add tasks or features that are not listed here or in CLAUDE.md without asking.

**Window:** Saturday, September 19, 2026 at 1:00 PM to Monday, September 21, 2026 at 8:00 AM (Detroit time). About 43 hours.
**Deliverables:** a working iOS demo and a public site.

## Rules for working through this plan
- Work top to bottom. Finish and build each item before starting the next.
- The project must compile at the end of every task. Commit after each working screen with a short message.
- One screen per file. Semantic SwiftUI fonts only. `Theme` colors only.
- After creating new Swift files, list them for the developer. This Xcode project may not pick up files created outside Xcode, so she may need to add them to the `TapIn313` target by hand.
- If a task will take much longer than its block, stop and say so instead of cutting corners silently.

## Cut line
If Sunday noon arrives and the full loop is not working, drop map polish and the badge and level unlock animation first. Never cut: the track path, the "Up next" card, staff attendance confirmation, or the earn-then-redeem loop.

## Status so far
- [x] Data model, mock data (14 programs with real GOAL Line site and activity names), 4 tracks, store logic, and skeleton app written (`Models.swift`, `MockData.swift`, `AppStore.swift`, `TapIn313App.swift`)
- [x] App name chosen: Tap In 313 (Xcode project `TapIn313`, display name "Tap In")
- [x] City of Detroit brand palette applied in `Theme.swift`, app set to light mode
- [x] GitHub repo created and connected
- [x] Skeleton builds and runs in the simulator (four tabs, Jordan at 60 points)

## Schedule

### Saturday 1:00 to 3:00 PM: Foundation
- [x] Lock the data model
- [x] Write mock data
- [x] SwiftUI skeleton
- [x] Name and palette
- [x] CLAUDE.md
- [x] Confirm the skeleton compiles and runs; fix compile errors only

### Saturday 3:00 to 8:00 PM: Core screens
- [x] Program list with search or category filter, showing site, venue type, points, and a "Free ride from your school" tag
- [x] Program detail: site, venue type, schedule, grades, address, points, join button
- [x] Programs map with pins for all 14 programs, tapping a pin opens the detail
- [x] "Your next step starts here" card at the top of the Programs tab, driven by `store.upNext(for:)`
- [x] Footer note on the Programs screen (sample data and independent project disclaimer)

### Saturday 8:00 to 11:00 PM: Profile and My Path
- [x] Profile screen: avatar (`Theme.avatarStyle`), points balance, badges grid, activity history with "Checked in by staff at [time]"
- [ ] My Path tab: track picker cards ("What sounds like you?"), level progress ("1 of 2 sessions"), what unlocks next, track payoff
- [ ] Switching tracks keeps earned progress and bonuses

### Saturday 11:00 PM to Sunday 7:00 AM: Sleep
No work planned.

### Sunday 7:00 AM to 12:00 PM: Rewards and staff mode
- [ ] Rewards catalog grouped by local merchant with point costs and a locked state when the balance is too low
- [ ] Redeem flow: confirm, deduct points, show the digital gift card code (`TAP-XXXX-XXXX`)
- [ ] Redemption history on the profile
- [ ] Staff mode: pick a program, see the roster, tap a student to confirm attendance, show a confirmation
- [ ] Staff mode uses `Theme.staff` (City Green) so it is clearly different from student mode
- [ ] Demo controls: switch between student and staff, and reset the demo (`store.resetDemo()`)

### Sunday 12:00 to 2:00 PM: Wire the full loop
- [ ] Staff confirms Jordan's second Robotics session, then the student side shows: level complete moment (+25), Century Club badge, and "Up next" moves to Coding and Tech Club at Conely Library
- [ ] Unlock sheets present in order: level, track, badge
- [ ] Jordan redeems the wing combo or slice and sees the code
- [ ] Reset returns to the exact starting state
- [ ] Fix what breaks

### Sunday 2:00 to 4:00 PM: Polish
- [ ] Unlock animation (respect Reduce Motion)
- [ ] Empty states (no track chosen, no redemptions yet, not enough points)
- [ ] App icon using brand colors (no City logo, no "Rise Higher")
- [ ] Accessibility pass: labels, 44 pt targets, Dynamic Type, never color alone, contrast per `Theme` pairings

### Sunday 4:00 to 8:00 PM: Public site
Can be built in parallel with the app. Static site, deployable anywhere free.
- [ ] Page structure: hero, the problem, the solution (points, badges, tracks, local rewards), how it works (3 steps), roadmap, footer
- [ ] "Why now" section using the City announcement facts in CLAUDE.md, with a link to the source
- [ ] Brand: City palette, Montserrat for headlines and body, Roboto for tables and forms (Google Fonts), body text 16px or larger, no light font weights for body, WCAG AA contrast
- [ ] Real screenshots of the app and a short demo video. No stock or AI-generated images.
- [ ] Footer: "Tap In 313 is an independent project and is not an official City of Detroit app." Sample data note. No City logo, no "Rise Higher."
- [ ] Waitlist or contact form (simple, no personal data about minors)
- [ ] Deploy and open it on a phone
- [ ] Swap placeholder images for final screenshots

### Sunday 8:00 to 10:00 PM: Bug bash and rehearsal
- [ ] Run the full demo path 3 times from reset
- [ ] Record a backup screen recording of the whole demo
- [ ] Rehearse the 3-minute story twice, out loud

### Sunday 10:00 PM to Monday 6:00 AM: Sleep and buffer
Anything that slipped goes here, after sleep.

### Monday 6:00 to 8:00 AM: Final checks
- [ ] Run the demo once on the phone that will be used
- [ ] Charge devices
- [ ] Open the public site and the backup video
- [ ] No new features

## Demo script (3 minutes)
1. Jordan (grade 7, Tech Builder, 60 points) opens the app. The top card says "Your next step starts here" with Robotics and a free-ride tag.
2. Browse programs on the map and the list. Open a program detail.
3. Switch to staff mode. Confirm Jordan's second Robotics session.
4. Switch back. Level complete (+25 bonus), then Century Club badge at 105 points. "Up next" now shows Coding and Tech Club at Conely Library.
5. Rewards: redeem a local restaurant reward and show the code.
6. Close on the roadmap: parent notifications, "near my school" distance, waitlists, grades 9 to 12, real partners.

## Roadmap items (slide only, do not build)
Real login and backend, real merchant integrations, push notifications, leaderboards, parent accounts and "arrived safely" notifications, "Near my school" distance and 2-mile filter, waitlists and spots left, streak badges, parental consent flow, grades 9 to 12, dark palette.
