import Foundation

/// Sources for real names: the City of Detroit announcement of the $2.2 million
/// GOAL Line expansion (site list and activity list).
///
/// REAL: site names, activity names, the fact that tutoring runs at the Redford,
///       Parkman, Edison, Sherwood, and Hubbard libraries.
/// SAMPLE: which activity runs at which site, days and times, descriptions,
///         points, tracks, students, and merchants. Show a "sample schedules"
///         note in the app and on the site.
/// Addresses and coordinates came from a map lookup. Spot-check before presenting.
enum MockData {

    // MARK: Staff (fictional)

    static let staffMember = StaffMember(displayName: "Sam R.", role: "Program staff", colorIndex: 3)

    // MARK: Students (fictional, first name and last initial only)

    static let students: [Student] = [
        Student(id: "jordan",  displayName: "Jordan M.",  grade: 7, colorIndex: 0),  // the demo student
        Student(id: "maya",    displayName: "Maya T.",    grade: 6, colorIndex: 1),
        Student(id: "devon",   displayName: "Devon R.",   grade: 8, colorIndex: 2),
        Student(id: "aaliyah", displayName: "Aaliyah W.", grade: 7, colorIndex: 3),
        Student(id: "marcus",  displayName: "Marcus J.",  grade: 8, colorIndex: 4),
        Student(id: "sofia",   displayName: "Sofia G.",   grade: 6, colorIndex: 5)
    ]

    // MARK: Programs (14): 12 sit on tracks, 2 are library tutoring

    static let programs: [Program] = [

        // Tech Builder track
        Program(
            id: "robotics", name: "Robotics", site: "Williams Recreation Center", venue: .recCenter,
            category: .stem,
            summary: "Design, build, and test a robot with your team. No experience needed.",
            address: "8431 Rosa Parks Blvd, Detroit, MI 48206",
            latitude: 42.3708, longitude: -83.0972,
            schedule: "Tuesdays, 4:00 to 5:30 PM", grades: "Grades K to 8", points: 20
        ),
        Program(
            id: "coding", name: "Coding and Tech Club", site: "Conely Library", venue: .library,
            category: .stem,
            summary: "Learn to code by making something you can show your friends and family.",
            address: "4600 Martin St, Detroit, MI 48210",
            latitude: 42.3319, longitude: -83.1273,
            schedule: "Thursdays, 4:00 to 5:30 PM", grades: "Grades K to 8", points: 25
        ),
        Program(
            id: "aicoding", name: "AI Coding", site: "Northwest Activities Center", venue: .recCenter,
            category: .stem,
            summary: "Go a step further and build projects that use artificial intelligence.",
            address: "18100 Meyers Rd, Detroit, MI 48235",
            latitude: 42.4233, longitude: -83.1694,
            schedule: "Wednesdays, 4:00 to 5:30 PM", grades: "Grades K to 8", points: 30
        ),

        // Creator track
        Program(
            id: "artclub", name: "Art Club", site: "Lincoln Library", venue: .library,
            category: .arts,
            summary: "Draw, paint, and try new materials. Bring your own ideas.",
            address: "1221 Seven Mile E, Detroit, MI 48203",
            latitude: 42.4328, longitude: -83.0910,
            schedule: "Mondays, 4:00 to 5:30 PM", grades: "Grades K to 8", points: 20
        ),
        Program(
            id: "music", name: "Music Studio: Music Creation", site: "Helen Moore Recreation Center", venue: .recCenter,
            category: .music,
            summary: "Make your own beats and songs, then mix and finish a track.",
            address: "11825 Dexter Ave, Detroit, MI 48206",
            latitude: 42.3805, longitude: -83.1251,
            schedule: "Wednesdays, 4:00 to 5:30 PM", grades: "Grades K to 8", points: 25
        ),
        Program(
            id: "podcast", name: "Podcasting", site: "Chaney Library", venue: .library,
            category: .arts,
            summary: "Plan, record, and edit your own podcast episode.",
            address: "16101 Grand River Ave, Detroit, MI 48227",
            latitude: 42.3952, longitude: -83.2054,
            schedule: "Fridays, 3:30 to 5:00 PM", grades: "Grades K to 8", points: 30
        ),

        // Maker and Entrepreneur track
        Program(
            id: "leather", name: "Leather Making", site: "Heilmann Recreation Center", venue: .recCenter,
            category: .arts,
            summary: "Cut, stitch, and finish something you made with your own hands.",
            address: "19601 Brock Ave, Detroit, MI 48205",
            latitude: 42.4408, longitude: -82.9632,
            schedule: "Tuesdays, 4:00 to 5:30 PM", grades: "Grades K to 8", points: 20
        ),
        Program(
            id: "finlit", name: "Financial Literacy", site: "A.B. Ford Recreation Center", venue: .recCenter,
            category: .business,
            summary: "Learn to budget, save, and price what you make.",
            address: "100 Lenox St, Detroit, MI 48215",
            latitude: 42.3573, longitude: -82.9409,
            schedule: "Thursdays, 4:00 to 5:30 PM", grades: "Grades K to 8", points: 25
        ),
        Program(
            id: "content", name: "Content Creation", site: "Patton Recreation Center", venue: .recCenter,
            category: .business,
            summary: "Shoot, edit, and share content that tells people about what you made.",
            address: "2301 Woodmere St, Detroit, MI 48209",
            latitude: 42.3095, longitude: -83.1379,
            schedule: "Fridays, 4:00 to 5:30 PM", grades: "Grades K to 8", points: 30
        ),

        // Athlete track
        Program(
            id: "basketball", name: "Basketball Drills", site: "Williams Recreation Center", venue: .recCenter,
            category: .sports,
            summary: "Work on ball handling, shooting, and teamwork with a coach.",
            address: "8431 Rosa Parks Blvd, Detroit, MI 48206",
            latitude: 42.3708, longitude: -83.0972,
            schedule: "Mondays, 4:00 to 5:30 PM", grades: "Grades K to 8", points: 20
        ),
        Program(
            id: "track", name: "Track and Field", site: "Heilmann Recreation Center", venue: .recCenter,
            category: .sports,
            summary: "Sprints, relays, and jumps. Find the event that fits you.",
            address: "19601 Brock Ave, Detroit, MI 48205",
            latitude: 42.4408, longitude: -82.9632,
            schedule: "Wednesdays, 4:00 to 5:30 PM", grades: "Grades K to 8", points: 25
        ),
        Program(
            id: "swim", name: "Swimming", site: "Coleman A. Young Recreation Center", venue: .recCenter,
            category: .sports,
            summary: "Build your strokes and water safety skills with instructors.",
            address: "2751 Robert Bradby Dr, Detroit, MI 48207",
            latitude: 42.3461, longitude: -83.0247,
            schedule: "Thursdays, 4:00 to 5:30 PM", grades: "Grades K to 8", points: 30
        ),

        // Tutoring (GOAL Line runs tutoring at these libraries)
        Program(
            id: "tutor-redford", name: "Tutoring", site: "Redford Library", venue: .library,
            category: .academics,
            summary: "Homework help and extra practice with a tutor.",
            address: "21200 Grand River Ave, Detroit, MI 48219",
            latitude: 42.4141, longitude: -83.2501,
            schedule: "Mondays and Wednesdays, 4:00 to 5:30 PM", grades: "Grades K to 8", points: 20
        ),
        Program(
            id: "tutor-parkman", name: "Tutoring", site: "Parkman Library", venue: .library,
            category: .academics,
            summary: "Homework help and extra practice with a tutor.",
            address: "1766 Oakman Blvd, Detroit, MI 48238",
            latitude: 42.3968, longitude: -83.1274,
            schedule: "Tuesdays and Thursdays, 4:00 to 5:30 PM", grades: "Grades K to 8", points: 20
        )
    ]

    // MARK: Interest tracks

    static let tracks: [Track] = [
        Track(
            id: "tech", name: "Tech Builder",
            tagline: "Build robots, write code, and make AI work for you.",
            symbol: "cpu.fill",
            payoff: "Show your project at a Tech Showcase night at a library.",
            levels: [
                TrackLevel(title: "Explore", programID: "robotics", sessionsRequired: 2, bonusPoints: 25),
                TrackLevel(title: "Build",   programID: "coding",   sessionsRequired: 2, bonusPoints: 40),
                TrackLevel(title: "Launch",  programID: "aicoding", sessionsRequired: 2, bonusPoints: 60)
            ]
        ),
        Track(
            id: "creator", name: "Creator",
            tagline: "Make art, music, and stories people want to hear.",
            symbol: "sparkles",
            payoff: "Get your art or podcast featured at a community showcase.",
            levels: [
                TrackLevel(title: "Explore", programID: "artclub", sessionsRequired: 2, bonusPoints: 25),
                TrackLevel(title: "Build",   programID: "music",   sessionsRequired: 2, bonusPoints: 40),
                TrackLevel(title: "Launch",  programID: "podcast", sessionsRequired: 2, bonusPoints: 60)
            ]
        ),
        Track(
            id: "maker", name: "Maker and Entrepreneur",
            tagline: "Make something, price it, and tell people about it.",
            symbol: "hammer.fill",
            payoff: "Sell what you made at a neighborhood pop-up market.",
            levels: [
                TrackLevel(title: "Explore", programID: "leather", sessionsRequired: 2, bonusPoints: 25),
                TrackLevel(title: "Build",   programID: "finlit",  sessionsRequired: 2, bonusPoints: 40),
                TrackLevel(title: "Launch",  programID: "content", sessionsRequired: 2, bonusPoints: 60)
            ]
        ),
        Track(
            id: "athlete", name: "Athlete",
            tagline: "Get stronger, faster, and more confident in the game.",
            symbol: "figure.run",
            payoff: "Help coach younger students at a weekend clinic.",
            levels: [
                TrackLevel(title: "Explore", programID: "basketball", sessionsRequired: 2, bonusPoints: 25),
                TrackLevel(title: "Build",   programID: "track",      sessionsRequired: 2, bonusPoints: 40),
                TrackLevel(title: "Launch",  programID: "swim",       sessionsRequired: 2, bonusPoints: 60)
            ]
        )
    ]

    // MARK: Which track each student picked

    static let studentTracks: [String: String] = [
       "jordan": "tech",
        "maya": "creator",
        "sofia": "creator",
        "aaliyah": "maker",
        "devon": "athlete",
        "marcus": "athlete"
    ]

    // MARK: Roster (who is signed up for what)

    static let enrollments: [String: [String]] = [
        "robotics":      ["jordan", "maya", "devon", "aaliyah"],
        "coding":        ["maya", "marcus"],
        "aicoding":      ["marcus"],
        "artclub":       ["jordan", "sofia", "maya"],
        "music":         ["sofia", "maya"],
        "podcast":       ["sofia"],
        "leather":       ["aaliyah"],
        "finlit":        ["aaliyah", "devon"],
        "content":       ["aaliyah"],
        "basketball":    ["jordan", "devon", "marcus"],
        "track":         ["devon", "marcus"],
        "swim":          ["marcus", "devon"],
        "tutor-redford": ["maya"],
        "tutor-parkman": ["sofia"]
    ]

    // MARK: Merchants (fictional local businesses)

    static let merchants: [Merchant] = [
        Merchant(id: "slice", name: "Motor City Slice", neighborhood: "Corktown",
                 kind: .food, symbol: "fork.knife", tagline: "Big New York-style slices"),
        Merchant(id: "wings", name: "Woodward Wings", neighborhood: "Midtown",
                 kind: .food, symbol: "flame.fill", tagline: "Wings, fries, and sauce flights"),
        Merchant(id: "bakery", name: "Bagley Bakehouse", neighborhood: "Southwest Detroit",
                 kind: .treat, symbol: "birthday.cake.fill", tagline: "Cookies and hot chocolate"),
        Merchant(id: "smoothie", name: "Eastern Market Smoothies", neighborhood: "Eastern Market",
                 kind: .food, symbol: "cup.and.saucer.fill", tagline: "Fruit from the market, blended"),
        Merchant(id: "books", name: "Cass Books and Beats", neighborhood: "Midtown",
                 kind: .shop, symbol: "books.vertical.fill", tagline: "Books, records, and headphones"),
        Merchant(id: "sneaker", name: "313 Sneaker Lab", neighborhood: "Downtown",
                 kind: .shop, symbol: "shoe.fill", tagline: "Kicks, laces, and clean-ups"),
        Merchant(id: "creamery", name: "Rivertown Creamery", neighborhood: "Jefferson Chalmers",
                 kind: .treat, symbol: "snowflake", tagline: "Small-batch ice cream")
    ]

    // MARK: Rewards

    static let rewards: [Reward] = [
        Reward(id: "cookie",   merchantID: "bakery",   title: "Cookie and hot chocolate",
               detail: "One cookie and a hot chocolate.", cost: 40),
        Reward(id: "icecream", merchantID: "creamery", title: "Double scoop",
               detail: "Two scoops in a cup or cone.", cost: 45),
        Reward(id: "smoothie", merchantID: "smoothie", title: "Any smoothie",
               detail: "One smoothie of your choice.", cost: 50),
        Reward(id: "slice",    merchantID: "slice",    title: "Slice and a drink",
               detail: "One slice and a fountain drink.", cost: 60),
        Reward(id: "wings",    merchantID: "wings",    title: "Six-piece wing combo",
               detail: "Six wings, fries, and a drink.", cost: 80),
        Reward(id: "books15",  merchantID: "books",    title: "$15 gift card",
               detail: "Good for books, records, or accessories.", cost: 150),
        Reward(id: "pie",      merchantID: "slice",    title: "Whole pie for the crew",
               detail: "One large pizza to share with friends.", cost: 250),
        Reward(id: "sneaker25", merchantID: "sneaker", title: "$25 gift card",
               detail: "Good toward any pair or clean-up service.", cost: 300),
        Reward(id: "sneaker50", merchantID: "sneaker", title: "$50 gift card",
               detail: "Good toward any pair or clean-up service.", cost: 550)
    ]

    // MARK: Badges

    static let badges: [Badge] = [
        Badge(id: "first-steps", name: "First Steps",
              detail: "Attend your first program.",
              symbol: "figure.walk", rule: .attendances(1)),
        Badge(id: "explorer", name: "Explorer",
              detail: "Try programs in 3 different categories.",
              symbol: "safari.fill", rule: .categories(3)),
        Badge(id: "regular", name: "Regular",
              detail: "Attend 5 programs.",
              symbol: "calendar.badge.checkmark", rule: .attendances(5)),
        Badge(id: "century", name: "Century Club",
              detail: "Earn 100 points.",
              symbol: "100.circle.fill", rule: .lifetimePoints(100)),
        Badge(id: "rising-star", name: "Rising Star",
              detail: "Earn 250 points.",
              symbol: "star.circle.fill", rule: .lifetimePoints(250)),
        Badge(id: "first-reward", name: "First Reward",
              detail: "Redeem your first reward.",
              symbol: "gift.fill", rule: .redemptions(1)),
        Badge(id: "local-hero", name: "Local Hero",
              detail: "Redeem rewards from 3 different local businesses.",
              symbol: "building.2.fill", rule: .merchants(3)),
        Badge(id: "all-in", name: "All In",
              detail: "Attend 10 programs.",
              symbol: "flame.fill", rule: .attendances(10))
    ]

    // MARK: Seed history
    //
    // Demo setup: Jordan is on the Tech Builder track with one Robotics session done,
    // plus Basketball Drills and Art Club, so 60 points, three categories, and the
    // First Steps and Explorer badges already earned.
    //
    // In the demo, staff confirm Jordan's second Robotics session (+20):
    //   1. Level 1 (Explore) completes, +25 bonus points
    //   2. Points reach 105, which unlocks the Century Club badge
    //   3. "Up next" moves to Coding and Tech Club at Conely Library
    // Jordan can then redeem the wing combo (80) or the slice (60).

    static var seedAttendances: [Attendance] {
        let day: TimeInterval = 86_400
        return [
            Attendance(id: UUID(), studentID: "jordan", programID: "robotics",
                       date: Date().addingTimeInterval(-6 * day), points: 20),
            Attendance(id: UUID(), studentID: "jordan", programID: "basketball",
                       date: Date().addingTimeInterval(-4 * day), points: 20),
            Attendance(id: UUID(), studentID: "jordan", programID: "artclub",
                       date: Date().addingTimeInterval(-2 * day), points: 20),
            Attendance(id: UUID(), studentID: "maya", programID: "coding",
                       date: Date().addingTimeInterval(-3 * day), points: 25),
            Attendance(id: UUID(), studentID: "devon", programID: "basketball",
                       date: Date().addingTimeInterval(-5 * day), points: 20)
        ]
    }
}
