/*
 * Sample data for the Tap In 313 web demo. This mirrors TapIn313/Models/MockData.swift.
 *
 * REAL: GOAL Line site names, GOAL Line activity names, and the libraries that host tutoring.
 * SAMPLE: which activity runs at which site, days and times, descriptions, points, tracks,
 *         track payoffs, students, and every merchant.
 * Addresses and coordinates came from a map lookup. Spot-check before presenting.
 */
const TAP_DATA = {
  staff: { name: 'Sam R.', role: 'Program staff' },

  // Fictional. First name and last initial only.
  students: [
    { id: 'jordan',  name: 'Jordan M.',  grade: 7, look: 0 },
    { id: 'maya',    name: 'Maya T.',    grade: 6, look: 1 },
    { id: 'devon',   name: 'Devon R.',   grade: 8, look: 2 },
    { id: 'aaliyah', name: 'Aaliyah W.', grade: 7, look: 3 },
    { id: 'marcus',  name: 'Marcus J.',  grade: 8, look: 4 },
    { id: 'sofia',   name: 'Sofia G.',   grade: 6, look: 5 }
  ],

  categories: {
    sports: 'Sports',
    arts: 'Arts and media',
    music: 'Music',
    stem: 'STEM',
    academics: 'Academics',
    business: 'Money and business'
  },

  venues: { rec: 'Recreation center', library: 'Library' },

  programs: [
    // Tech Builder
    { id: 'robotics', name: 'Robotics', site: 'Williams Recreation Center', venue: 'rec', cat: 'stem',
      summary: 'Design, build, and test a robot with your team. No experience needed.',
      address: '8431 Rosa Parks Blvd, Detroit, MI 48206', lat: 42.3708, lon: -83.0972,
      schedule: 'Tuesdays, 4:00 to 5:30 PM', points: 20 },
    { id: 'coding', name: 'Coding and Tech Club', site: 'Conely Library', venue: 'library', cat: 'stem',
      summary: 'Learn to code by making something you can show your friends and family.',
      address: '4600 Martin St, Detroit, MI 48210', lat: 42.3319, lon: -83.1273,
      schedule: 'Thursdays, 4:00 to 5:30 PM', points: 25 },
    { id: 'aicoding', name: 'AI Coding', site: 'Northwest Activities Center', venue: 'rec', cat: 'stem',
      summary: 'Go a step further and build projects that use artificial intelligence.',
      address: '18100 Meyers Rd, Detroit, MI 48235', lat: 42.4233, lon: -83.1694,
      schedule: 'Wednesdays, 4:00 to 5:30 PM', points: 30 },

    // Creator
    { id: 'artclub', name: 'Art Club', site: 'Lincoln Library', venue: 'library', cat: 'arts',
      summary: 'Draw, paint, and try new materials. Bring your own ideas.',
      address: '1221 Seven Mile E, Detroit, MI 48203', lat: 42.4328, lon: -83.0910,
      schedule: 'Mondays, 4:00 to 5:30 PM', points: 20 },
    { id: 'music', name: 'Music Studio: Music Creation', site: 'Helen Moore Recreation Center', venue: 'rec', cat: 'music',
      summary: 'Make your own beats and songs, then mix and finish a track.',
      address: '11825 Dexter Ave, Detroit, MI 48206', lat: 42.3805, lon: -83.1251,
      schedule: 'Wednesdays, 4:00 to 5:30 PM', points: 25 },
    { id: 'podcast', name: 'Podcasting', site: 'Chaney Library', venue: 'library', cat: 'arts',
      summary: 'Plan, record, and edit your own podcast episode.',
      address: '16101 Grand River Ave, Detroit, MI 48227', lat: 42.3952, lon: -83.2054,
      schedule: 'Fridays, 3:30 to 5:00 PM', points: 30 },

    // Maker and Entrepreneur
    { id: 'leather', name: 'Leather Making', site: 'Heilmann Recreation Center', venue: 'rec', cat: 'arts',
      summary: 'Cut, stitch, and finish something you made with your own hands.',
      address: '19601 Brock Ave, Detroit, MI 48205', lat: 42.4408, lon: -82.9632,
      schedule: 'Tuesdays, 4:00 to 5:30 PM', points: 20 },
    { id: 'finlit', name: 'Financial Literacy', site: 'A.B. Ford Recreation Center', venue: 'rec', cat: 'business',
      summary: 'Learn to budget, save, and price what you make.',
      address: '100 Lenox St, Detroit, MI 48215', lat: 42.3573, lon: -82.9409,
      schedule: 'Thursdays, 4:00 to 5:30 PM', points: 25 },
    { id: 'content', name: 'Content Creation', site: 'Patton Recreation Center', venue: 'rec', cat: 'business',
      summary: 'Shoot, edit, and share content that tells people about what you made.',
      address: '2301 Woodmere St, Detroit, MI 48209', lat: 42.3095, lon: -83.1379,
      schedule: 'Fridays, 4:00 to 5:30 PM', points: 30 },

    // Athlete
    { id: 'basketball', name: 'Basketball Drills', site: 'Williams Recreation Center', venue: 'rec', cat: 'sports',
      summary: 'Work on ball handling, shooting, and teamwork with a coach.',
      address: '8431 Rosa Parks Blvd, Detroit, MI 48206', lat: 42.3708, lon: -83.0972,
      schedule: 'Mondays, 4:00 to 5:30 PM', points: 20 },
    { id: 'track', name: 'Track and Field', site: 'Heilmann Recreation Center', venue: 'rec', cat: 'sports',
      summary: 'Sprints, relays, and jumps. Find the event that fits you.',
      address: '19601 Brock Ave, Detroit, MI 48205', lat: 42.4408, lon: -82.9632,
      schedule: 'Wednesdays, 4:00 to 5:30 PM', points: 25 },
    { id: 'swim', name: 'Swimming', site: 'Coleman A. Young Recreation Center', venue: 'rec', cat: 'sports',
      summary: 'Build your strokes and water safety skills with instructors.',
      address: '2751 Robert Bradby Dr, Detroit, MI 48207', lat: 42.3461, lon: -83.0247,
      schedule: 'Thursdays, 4:00 to 5:30 PM', points: 30 },

    // Tutoring
    { id: 'tutor-redford', name: 'Tutoring', site: 'Redford Library', venue: 'library', cat: 'academics',
      summary: 'Homework help and extra practice with a tutor.',
      address: '21200 Grand River Ave, Detroit, MI 48219', lat: 42.4141, lon: -83.2501,
      schedule: 'Mondays and Wednesdays, 4:00 to 5:30 PM', points: 20 },
    { id: 'tutor-parkman', name: 'Tutoring', site: 'Parkman Library', venue: 'library', cat: 'academics',
      summary: 'Homework help and extra practice with a tutor.',
      address: '1766 Oakman Blvd, Detroit, MI 48238', lat: 42.3968, lon: -83.1274,
      schedule: 'Tuesdays and Thursdays, 4:00 to 5:30 PM', points: 20 }
  ],

  // Four tracks, three levels each. Every level is one program and 2 sessions.
  tracks: [
    { id: 'tech', name: 'Tech Builder',
      tagline: 'Build robots, write code, and make AI work for you.',
      payoff: 'Show your project at a Tech Showcase night at a library.',
      levels: [
        { title: 'Explore', programId: 'robotics', sessions: 2, bonus: 25 },
        { title: 'Build',   programId: 'coding',   sessions: 2, bonus: 40 },
        { title: 'Launch',  programId: 'aicoding', sessions: 2, bonus: 60 }
      ] },
    { id: 'creator', name: 'Creator',
      tagline: 'Make art, music, and stories people want to hear.',
      payoff: 'Get your art or podcast featured at a community showcase.',
      levels: [
        { title: 'Explore', programId: 'artclub', sessions: 2, bonus: 25 },
        { title: 'Build',   programId: 'music',   sessions: 2, bonus: 40 },
        { title: 'Launch',  programId: 'podcast', sessions: 2, bonus: 60 }
      ] },
    { id: 'maker', name: 'Maker and Entrepreneur',
      tagline: 'Make something, price it, and tell people about it.',
      payoff: 'Sell what you made at a neighborhood pop-up market.',
      levels: [
        { title: 'Explore', programId: 'leather', sessions: 2, bonus: 25 },
        { title: 'Build',   programId: 'finlit',  sessions: 2, bonus: 40 },
        { title: 'Launch',  programId: 'content', sessions: 2, bonus: 60 }
      ] },
    { id: 'athlete', name: 'Athlete',
      tagline: 'Get stronger, faster, and more confident in the game.',
      payoff: 'Help coach younger students at a weekend clinic.',
      levels: [
        { title: 'Explore', programId: 'basketball', sessions: 2, bonus: 25 },
        { title: 'Build',   programId: 'track',      sessions: 2, bonus: 40 },
        { title: 'Launch',  programId: 'swim',       sessions: 2, bonus: 60 }
      ] }
  ],

  studentTracks: {
    jordan: 'tech', maya: 'creator', sofia: 'creator',
    aaliyah: 'maker', devon: 'athlete', marcus: 'athlete'
  },

  enrollments: {
    robotics: ['jordan', 'maya', 'devon', 'aaliyah'],
    coding: ['maya', 'marcus'],
    aicoding: ['marcus'],
    artclub: ['jordan', 'sofia', 'maya'],
    music: ['sofia', 'maya'],
    podcast: ['sofia'],
    leather: ['aaliyah'],
    finlit: ['aaliyah', 'devon'],
    content: ['aaliyah'],
    basketball: ['jordan', 'devon', 'marcus'],
    track: ['devon', 'marcus'],
    swim: ['marcus', 'devon'],
    'tutor-redford': ['maya'],
    'tutor-parkman': ['sofia']
  },

  // Fictional local businesses. None of these are real or confirmed.
  merchants: [
    { id: 'slice',    name: 'Motor City Slice',         area: 'Corktown',           tagline: 'Big New York-style slices' },
    { id: 'wings',    name: 'Woodward Wings',           area: 'Midtown',            tagline: 'Wings, fries, and sauce flights' },
    { id: 'bakery',   name: 'Bagley Bakehouse',         area: 'Southwest Detroit',  tagline: 'Cookies and hot chocolate' },
    { id: 'smoothie', name: 'Eastern Market Smoothies', area: 'Eastern Market',     tagline: 'Fruit from the market, blended' },
    { id: 'books',    name: 'Cass Books and Beats',     area: 'Midtown',            tagline: 'Books, records, and headphones' },
    { id: 'sneaker',  name: '313 Sneaker Lab',          area: 'Downtown',           tagline: 'Kicks, laces, and clean-ups' },
    { id: 'creamery', name: 'Rivertown Creamery',       area: 'Jefferson Chalmers', tagline: 'Small-batch ice cream' }
  ],

  rewards: [
    { id: 'cookie',    merchantId: 'bakery',   title: 'Cookie and hot chocolate', detail: 'One cookie and a hot chocolate.',        cost: 40 },
    { id: 'icecream',  merchantId: 'creamery', title: 'Double scoop',             detail: 'Two scoops in a cup or cone.',           cost: 45 },
    { id: 'smoothie',  merchantId: 'smoothie', title: 'Any smoothie',             detail: 'One smoothie of your choice.',           cost: 50 },
    { id: 'slice',     merchantId: 'slice',    title: 'Slice and a drink',        detail: 'One slice and a fountain drink.',        cost: 60 },
    { id: 'wings',     merchantId: 'wings',    title: 'Six-piece wing combo',     detail: 'Six wings, fries, and a drink.',         cost: 80 },
    { id: 'books15',   merchantId: 'books',    title: '$15 gift card',            detail: 'Good for books, records, or accessories.', cost: 150 },
    { id: 'pie',       merchantId: 'slice',    title: 'Whole pie for the crew',   detail: 'One large pizza to share with friends.', cost: 250 },
    { id: 'sneaker25', merchantId: 'sneaker',  title: '$25 gift card',            detail: 'Good toward any pair or clean-up service.', cost: 300 },
    { id: 'sneaker50', merchantId: 'sneaker',  title: '$50 gift card',            detail: 'Good toward any pair or clean-up service.', cost: 550 }
  ],

  // rule: [kind, n]
  badges: [
    { id: 'first-steps', name: 'First Steps',  detail: 'Attend your first program.',                        mark: '1',    rule: ['attendances', 1] },
    { id: 'explorer',    name: 'Explorer',     detail: 'Try programs in 3 different categories.',           mark: '3',    rule: ['categories', 3] },
    { id: 'regular',     name: 'Regular',      detail: 'Attend 5 programs.',                                mark: '5',    rule: ['attendances', 5] },
    { id: 'century',     name: 'Century Club', detail: 'Earn 100 points.',                                  mark: '100',  rule: ['lifetimePoints', 100] },
    { id: 'rising-star', name: 'Rising Star',  detail: 'Earn 250 points.',                                  mark: '250',  rule: ['lifetimePoints', 250] },
    { id: 'first-reward', name: 'First Reward', detail: 'Redeem your first reward.',                        mark: 'gift', rule: ['redemptions', 1] },
    { id: 'local-hero',  name: 'Local Hero',   detail: 'Redeem rewards from 3 different local businesses.', mark: '3x',   rule: ['merchants', 3] },
    { id: 'all-in',      name: 'All In',       detail: 'Attend 10 programs.',                               mark: '10',   rule: ['attendances', 10] }
  ],

  // Jordan starts with one Robotics session, plus Basketball Drills and Art Club:
  // 60 points, three categories, and the First Steps and Explorer badges.
  // days ago, student, program
  seedAttendances: [
    [6, 'jordan', 'robotics'],
    [4, 'jordan', 'basketball'],
    [2, 'jordan', 'artclub'],
    [3, 'maya', 'coding'],
    [5, 'devon', 'basketball']
  ]
};

if (typeof module !== 'undefined') module.exports = TAP_DATA;
