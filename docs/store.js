/*
 * The Tap In 313 rules, in plain JavaScript. This is a port of TapIn313/AppStore.swift so the
 * web demo behaves like the iOS app:
 *  - The points balance is always derived: attendance points plus level bonuses minus redemptions.
 *  - A level bonus is recorded once and never paid twice.
 *  - Celebrations queue in order: level complete, track complete, then badges.
 *  - Confirming the same student at the same program twice on one day does nothing.
 * Nothing here touches the page, so it can be tested on its own.
 */
function createStore(DATA) {
  const DAY = 86400000;
  const CODE_CHARS = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // skips look-alike characters
  let nextId = 1;
  const uid = () => nextId++;

  const store = {
    currentStudentId: 'jordan',
    studentTracks: {},
    enrollments: {},
    attendances: [],
    redemptions: [],
    earnedBadges: [],
    levelCompletions: [],
    /** Celebrations the current student has not seen yet, shown one at a time. */
    pendingUnlocks: []
  };

  // ---------- Lookups ----------
  const byId = (list, id) => list.find(item => item.id === id);
  store.program = id => byId(DATA.programs, id);
  store.track = id => byId(DATA.tracks, id);
  store.merchant = id => byId(DATA.merchants, id);
  store.reward = id => byId(DATA.rewards, id);
  store.student = id => byId(DATA.students, id);
  store.badge = id => byId(DATA.badges, id);
  store.currentStudent = () => store.student(store.currentStudentId);
  store.rewardsFor = merchantId => DATA.rewards.filter(r => r.merchantId === merchantId);
  store.roster = programId => (store.enrollments[programId] || []).map(store.student).filter(Boolean);

  // ---------- Points ----------
  store.pointsFromAttendance = sid =>
    store.attendances.filter(a => a.studentId === sid).reduce((n, a) => n + a.points, 0);
  store.pointsFromLevels = sid =>
    store.levelCompletions.filter(c => c.studentId === sid).reduce((n, c) => n + c.bonus, 0);
  store.pointsEarned = sid => store.pointsFromAttendance(sid) + store.pointsFromLevels(sid);
  store.pointsSpent = sid =>
    store.redemptions.filter(r => r.studentId === sid).reduce((n, r) => n + r.cost, 0);
  /** Never stored. Always derived, so it cannot drift. */
  store.pointsBalance = sid => store.pointsEarned(sid) - store.pointsSpent(sid);

  store.attendancesFor = sid =>
    store.attendances.filter(a => a.studentId === sid).sort((a, b) => b.date - a.date);
  store.redemptionsFor = sid =>
    store.redemptions.filter(r => r.studentId === sid).sort((a, b) => b.date - a.date);
  store.earnedBadgeIds = sid =>
    new Set(store.earnedBadges.filter(b => b.studentId === sid).map(b => b.badgeId));

  // ---------- Tracks ----------
  store.currentTrack = sid => {
    const trackId = store.studentTracks[sid];
    return trackId ? store.track(trackId) : null;
  };

  store.sessionsCompleted = (sid, programId) =>
    store.attendances.filter(a => a.studentId === sid && a.programId === programId).length;

  store.levelProgress = (track, index, sid) => {
    const level = track.levels[index];
    if (!level) return { done: 0, required: 0 };
    const done = store.sessionsCompleted(sid, level.programId);
    return { done: Math.min(done, level.sessions), required: level.sessions };
  };

  store.isLevelComplete = (track, index, sid) => {
    if (!track.levels[index]) return false;
    const p = store.levelProgress(track, index, sid);
    return p.done >= p.required;
  };

  store.isTrackComplete = (track, sid) =>
    track.levels.every((_, i) => store.isLevelComplete(track, i, sid));

  /** 'complete' | 'current' | 'locked' for each level. The first unfinished level is current. */
  store.levelStates = (track, sid) => {
    let foundCurrent = false;
    return track.levels.map((_, i) => {
      if (store.isLevelComplete(track, i, sid)) return 'complete';
      if (!foundCurrent) { foundCurrent = true; return 'current'; }
      return 'locked';
    });
  };

  /** The first level not finished yet. This powers the "Up next" card. */
  store.upNext = sid => {
    const track = store.currentTrack(sid);
    if (!track) return null;
    for (let i = 0; i < track.levels.length; i++) {
      if (!store.isLevelComplete(track, i, sid)) {
        const level = track.levels[i];
        const program = store.program(level.programId);
        if (program) return { track, levelIndex: i, level, program };
      }
    }
    return null;
  };

  const hasRecordedCompletion = (sid, trackId, index) =>
    store.levelCompletions.some(c => c.studentId === sid && c.trackId === trackId && c.levelIndex === index);

  function awardLevelCompletions(sid, notify) {
    const track = store.currentTrack(sid);
    if (!track) return [];
    const unlocks = [];
    track.levels.forEach((level, index) => {
      if (!hasRecordedCompletion(sid, track.id, index) && store.isLevelComplete(track, index, sid)) {
        store.levelCompletions.push({
          id: uid(), studentId: sid, trackId: track.id, levelIndex: index, date: new Date(), bonus: level.bonus
        });
        unlocks.push({ kind: 'level', trackId: track.id, levelIndex: index });
      }
    });
    if (unlocks.length && store.isTrackComplete(track, sid)) {
      unlocks.push({ kind: 'track', trackId: track.id });
    }
    if (notify && sid === store.currentStudentId) store.pendingUnlocks.push(...unlocks);
    return unlocks;
  }

  /** Picks or switches a track. Progress and bonuses already earned are kept. */
  store.chooseTrack = (trackId, sid) => {
    store.studentTracks[sid] = trackId;
    awardLevelCompletions(sid, true);
  };

  // ---------- Student actions ----------
  store.isEnrolled = (sid, programId) => (store.enrollments[programId] || []).includes(sid);

  store.join = (sid, programId) => {
    if (store.isEnrolled(sid, programId)) return;
    (store.enrollments[programId] = store.enrollments[programId] || []).push(sid);
  };

  store.redeem = (reward, sid) => {
    if (store.pointsBalance(sid) < reward.cost) return null;
    const chunk = () => Array.from({ length: 4 }, () => CODE_CHARS[Math.floor(Math.random() * CODE_CHARS.length)]).join('');
    const redemption = {
      id: uid(), studentId: sid, rewardId: reward.id,
      code: `TAP-${chunk()}-${chunk()}`, date: new Date(), cost: reward.cost
    };
    store.redemptions.push(redemption);
    awardNewBadges(sid, true);
    return redemption;
  };

  // ---------- Staff actions ----------
  const sameDay = (a, b) => a.toDateString() === b.toDateString();

  store.hasAttended = (sid, programId, date) =>
    store.attendances.some(a => a.studentId === sid && a.programId === programId && sameDay(a.date, date));

  /**
   * Confirms a student attended and awards the program's points. Level completions are checked
   * first, then badges, so celebrations play in that order.
   */
  store.confirmAttendance = (sid, programId, date = new Date()) => {
    const program = store.program(programId);
    if (!program || store.hasAttended(sid, programId, date)) return [];
    store.attendances.push({ id: uid(), studentId: sid, programId, date, points: program.points });
    const levelUnlocks = awardLevelCompletions(sid, true);
    const badgeUnlocks = awardNewBadges(sid, true);
    return [...levelUnlocks, ...badgeUnlocks];
  };

  // ---------- Badges ----------
  store.dismissUnlock = () => { store.pendingUnlocks.shift(); };

  function isMet(rule, sid) {
    const [kind, n] = rule;
    const attended = store.attendances.filter(a => a.studentId === sid);
    const redeemed = store.redemptions.filter(r => r.studentId === sid);
    switch (kind) {
      case 'attendances': return attended.length >= n;
      case 'categories': return new Set(attended.map(a => store.program(a.programId)?.cat)).size >= n;
      case 'lifetimePoints': return store.pointsEarned(sid) >= n;
      case 'redemptions': return redeemed.length >= n;
      case 'merchants': return new Set(redeemed.map(r => store.reward(r.rewardId)?.merchantId)).size >= n;
      default: return false;
    }
  }

  function awardNewBadges(sid, notify) {
    const already = store.earnedBadgeIds(sid);
    const unlocks = [];
    DATA.badges.forEach(badge => {
      if (!already.has(badge.id) && isMet(badge.rule, sid)) {
        store.earnedBadges.push({ id: uid(), studentId: sid, badgeId: badge.id, date: new Date() });
        unlocks.push({ kind: 'badge', badgeId: badge.id });
      }
    });
    if (notify && sid === store.currentStudentId) store.pendingUnlocks.push(...unlocks);
    return unlocks;
  }

  // ---------- Demo controls ----------
  /** Puts everything back to the starting demo state. */
  store.reset = () => {
    const now = Date.now();
    store.currentStudentId = 'jordan';
    store.studentTracks = { ...DATA.studentTracks };
    store.enrollments = Object.fromEntries(Object.entries(DATA.enrollments).map(([k, v]) => [k, [...v]]));
    store.attendances = DATA.seedAttendances.map(([daysAgo, studentId, programId]) => ({
      id: uid(), studentId, programId,
      date: new Date(now - daysAgo * DAY),
      points: store.program(programId).points
    }));
    store.redemptions = [];
    store.earnedBadges = [];
    store.levelCompletions = [];
    store.pendingUnlocks = [];
    DATA.students.forEach(s => {
      awardLevelCompletions(s.id, false);
      awardNewBadges(s.id, false);
    });
  };

  store.reset();
  return store;
}

if (typeof module !== 'undefined') module.exports = createStore;
