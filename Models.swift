import Foundation
import CoreLocation

// MARK: - Programs

enum ProgramCategory: String, CaseIterable, Identifiable, Hashable {
    case sports, arts, music, stem, academics, business

    var id: String { rawValue }

    var title: String {
        switch self {
        case .sports: "Sports"
        case .arts: "Arts and media"
        case .music: "Music"
        case .stem: "STEM"
        case .academics: "Academics"
        case .business: "Money and business"
        }
    }

    /// SF Symbol name
    var symbol: String {
        switch self {
        case .sports: "figure.basketball"
        case .arts: "paintpalette.fill"
        case .music: "music.note"
        case .stem: "gearshape.2.fill"
        case .academics: "book.fill"
        case .business: "dollarsign.circle.fill"
        }
    }
}

enum VenueType: String, Hashable {
    case recCenter, library, school, partner

    var title: String {
        switch self {
        case .recCenter: "Recreation center"
        case .library: "Library"
        case .school: "School"
        case .partner: "Community partner"
        }
    }

    var symbol: String {
        switch self {
        case .recCenter: "figure.run"
        case .library: "books.vertical.fill"
        case .school: "graduationcap.fill"
        case .partner: "person.3.fill"
        }
    }
}

struct Program: Identifiable, Hashable {
    let id: String
    let name: String            // real GOAL Line activity name
    let site: String            // real GOAL Line location name
    let venue: VenueType
    let category: ProgramCategory
    let summary: String         // our own generic description
    let address: String
    let latitude: Double
    let longitude: Double
    let schedule: String        // SAMPLE schedule, not the real one
    let grades: String
    let points: Int             // points earned per confirmed attendance
    var provider = "GOAL Line Detroit"
    var offersFreeRide = true   // GOAL Line provides transportation to its locations

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

// MARK: - Interest tracks

/// One step on a track. Complete it by attending `programID` enough times.
struct TrackLevel: Hashable {
    let title: String           // Explore, Build, Launch
    let programID: String
    let sessionsRequired: Int
    let bonusPoints: Int        // awarded once when the level is completed
}

struct Track: Identifiable, Hashable {
    let id: String
    let name: String
    let tagline: String
    let symbol: String          // SF Symbol name
    let payoff: String          // what finishing the track leads to (roadmap, not real yet)
    let levels: [TrackLevel]
}

struct LevelCompletion: Identifiable, Hashable {
    let id: UUID
    let studentID: String
    let trackID: String
    let levelIndex: Int
    let date: Date
    let bonus: Int
}

/// Something worth a celebration screen. Shown one at a time, in order.
enum Unlock: Identifiable, Hashable {
    case level(trackID: String, levelIndex: Int)
    case track(trackID: String)
    case badge(Badge)

    var id: String {
        switch self {
        case .level(let trackID, let levelIndex): "level-\(trackID)-\(levelIndex)"
        case .track(let trackID): "track-\(trackID)"
        case .badge(let badge): "badge-\(badge.id)"
        }
    }
}

// MARK: - Merchants and rewards

enum MerchantKind: String, Hashable {
    case food, shop, treat
}

struct Merchant: Identifiable, Hashable {
    let id: String
    let name: String
    let neighborhood: String
    let kind: MerchantKind
    let symbol: String          // SF Symbol name
    let tagline: String
}

struct Reward: Identifiable, Hashable {
    let id: String
    let merchantID: String
    let title: String
    let detail: String
    let cost: Int               // points
}

// MARK: - Badges

enum BadgeRule: Hashable {
    case attendances(Int)       // total confirmed attendances
    case categories(Int)        // distinct program categories attended
    case lifetimePoints(Int)    // total points ever earned (attendance plus level bonuses)
    case redemptions(Int)       // total rewards redeemed
    case merchants(Int)         // distinct merchants redeemed from
}

struct Badge: Identifiable, Hashable {
    let id: String
    let name: String
    let detail: String          // how to earn it, in plain language
    let symbol: String          // SF Symbol name
    let rule: BadgeRule
}

// MARK: - Students and activity

struct Student: Identifiable, Hashable {
    let id: String
    let displayName: String     // first name and last initial only
    let grade: Int
    let colorIndex: Int         // picks an avatar color

    var initials: String {
        displayName
            .split(separator: " ")
            .compactMap { $0.first }
            .map(String.init)
            .joined()
    }
}

struct Attendance: Identifiable, Hashable {
    let id: UUID
    let studentID: String
    let programID: String
    let date: Date              // shown to families as the staff check-in time
    let points: Int
}

struct EarnedBadge: Identifiable, Hashable {
    let id: UUID
    let studentID: String
    let badgeID: String
    let date: Date
}

struct Redemption: Identifiable, Hashable {
    let id: UUID
    let studentID: String
    let rewardID: String
    let code: String            // the digital gift card code shown in the app
    let date: Date
    let cost: Int
}
