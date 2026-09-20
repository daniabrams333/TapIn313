/*
 * Tap In 313 web demo: a phone-sized simulation of the iOS app.
 * It runs the same rules (store.js) on the same sample data (data.js) as the SwiftUI app.
 * All data is sample data. Nothing is sent anywhere. Refreshing the page resets the demo.
 */
(function () {
  'use strict';

  const D = TAP_DATA;
  const S = createStore(D);

  // ---------- UI state (not part of the store) ----------
  const fresh = () => ({
    mode: 'student',          // 'student' | 'staff'
    tab: 'programs',          // programs | path | rewards | profile
    stack: [],                // pushed screens: { type: 'detail' | 'gift', id }
    showMap: false,
    category: null,
    site: null,               // selected map site name
    sheet: null,              // reward id being confirmed
    staffProgram: null,       // program id open in staff mode
    toast: null,
    mapOpened: false,
    detailOpened: false
  });
  let ui = fresh();
  let tour = { s1: false, s2: false };
  let lastKey = '';


  // ---------- Small helpers ----------
  const esc = s => String(s).replace(/[&<>"']/g, c => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c]));
  const fmtTime = d => d.toLocaleTimeString('en-US', { hour: 'numeric', minute: '2-digit' });
  const fmtDay = d => d.toLocaleDateString('en-US', { weekday: 'short', month: 'short', day: 'numeric' });
  const fmtShort = d => d.toLocaleDateString('en-US', { month: 'short', day: 'numeric' });
  const plural = (n, one, many) => (n === 1 ? one : many);

  const ICONS = {
    check: '<path d="M5 12.5l4.5 4.5L19 7.5"/>',
    lock: '<rect x="5" y="11" width="14" height="9" rx="2"/><path d="M8 11V8a4 4 0 0 1 8 0v3"/>',
    star: '<path d="M12 3.5l2.6 5.4 5.9.8-4.3 4.1 1 5.9L12 16.9l-5.2 2.8 1-5.9L3.5 9.7l5.9-.8z"/>',
    bus: '<rect x="4" y="4" width="16" height="13" rx="3"/><path d="M4 11h16M8 20v-3M16 20v-3"/>',
    flag: '<path d="M6 21V4M6 5h11l-2 4 2 4H6"/>',
    gift: '<rect x="4" y="9" width="16" height="11" rx="1.5"/><path d="M12 9v11M3 9h18M12 9c-1-3-5-4-5-1.5S10 9 12 9zM12 9c1-3 5-4 5-1.5S14 9 12 9z"/>',
    list: '<path d="M8 6h12M8 12h12M8 18h12M4 6h.01M4 12h.01M4 18h.01"/>',
    map: '<path d="M9 4L3 6v14l6-2 6 2 6-2V4l-6 2zM9 4v14M15 6v14"/>',
    user: '<circle cx="12" cy="8" r="4"/><path d="M4 21c1-4 4-6 8-6s7 2 8 6"/>',
    path: '<path d="M12 3v18M12 6h7l2 2.5-2 2.5h-7M12 13H5l-2 2.5L5 18h7"/>',
    chevron: '<path d="M9 6l6 6-6 6"/>',
    back: '<path d="M15 6l-6 6 6 6"/>',
    close: '<path d="M6 6l12 12M18 6L6 18"/>',
    trophy: '<path d="M8 4h8v5a4 4 0 0 1-8 0zM8 6H4c0 3 1 4 4 4M16 6h4c0 3-1 4-4 4M12 13v4M8 21h8M9 17h6"/>',
    pin: '<path d="M12 21s-6-5.6-6-11a6 6 0 0 1 12 0c0 5.4-6 11-6 11z"/><circle cx="12" cy="10" r="2"/>',
    book: '<path d="M4 5a2 2 0 0 1 2-2h13v16H6a2 2 0 0 0-2 2zM4 19V5"/>',
    run: '<circle cx="14" cy="5" r="2"/><path d="M6 21l3-6 3 2v5M9 15l1-5 4 1 3 3M10 10L7 12"/>',
    cal: '<rect x="4" y="5" width="16" height="15" rx="2"/><path d="M4 10h16M9 3v4M15 3v4"/>',
    people: '<circle cx="9" cy="8" r="3"/><path d="M3 20c.5-3.5 3-5 6-5s5.5 1.5 6 5M16 5.5a3 3 0 0 1 0 5M18 15c2 .5 3 2 3.5 5"/>',
    home: '<path d="M4 11l8-7 8 7v9H4z"/>'
  };
  const icon = (name, cls = '') =>
    `<svg class="ic ${cls}" viewBox="0 0 24 24" aria-hidden="true" focusable="false" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">${ICONS[name] || ''}</svg>`;

  const LOOKS = [
    ['var(--rise)', '#fff'], ['var(--city)', '#fff'], ['var(--light)', 'var(--rise)'],
    ['var(--yellow)', 'var(--rise)'], ['var(--spirit)', '#0b1220']
  ];
  const avatar = (student, size = '') => {
    const [bg, fg] = LOOKS[student.look % LOOKS.length];
    const initials = student.name.split(' ').map(p => p[0]).join('');
    return `<span class="avatar ${size}" style="background:${bg};color:${fg}" role="img" aria-label="${esc(student.name)} avatar">${initials}</span>`;
  };

  const pill = (points, o = {}) =>
    `<span class="pill${o.lg ? ' pill--lg' : ''}">${icon('star', 'ic--fill')}${o.sign || '+'}${points}${o.suffix ? ' ' + esc(o.suffix) : ''}</span>`;

  const venueIcon = p => (p.venue === 'library' ? 'book' : 'run');
  const sid = () => S.currentStudentId;

  // ---------- Screens: student ----------

  function programsScreen() {
    const next = S.upNext(sid());
    let h = `<h2 class="ltitle" data-title tabindex="-1">Programs</h2>`;
    h += `<div class="seg-wrap" role="group" aria-label="Show programs as">
      <button class="seg-i" data-action="view" data-id="list" aria-pressed="${!ui.showMap}">${icon('list')}List</button>
      <button class="seg-i" data-action="view" data-id="map" aria-pressed="${ui.showMap}">${icon('map')}Map</button>
    </div>`;
    if (ui.showMap) {
      h += mapView(next);
    } else {
      h += `<h3 class="g-title">Your next step starts here</h3>`;
      h += next ? upNextCard(next) : noNextCard();
      h += listView();
    }
    h += `<p class="foot">Site and activity names come from GOAL Line Detroit. Schedules and details are samples for this demo. Tap In 313 is an independent project and is not an official City of Detroit app.</p>`;
    return h;
  }

  function upNextCard(n) {
    const p = n.program;
    const label = `Up next: ${p.name} at ${p.site}, ${p.schedule}. ${n.track.name}, ${n.level.title} level. Opens program details.`;
    return `<button class="row-btn blue" data-action="open" data-id="${p.id}" aria-label="${esc(label)}">
      <span class="small dim" style="display:block">${esc(n.track.name)} · ${esc(n.level.title)}</span>
      <span class="h2" style="display:block">${esc(p.name)}</span>
      <span class="small" style="display:block">${esc(p.site)} · ${esc(p.schedule)}</span>
      <span class="tag-i" style="margin-top:6px">${icon('bus')}Free ride from your school</span>
    </button>`;
  }

  /** Empty state: no track chosen yet, or every level on the track is finished. */
  function noNextCard() {
    const track = S.currentTrack(sid());
    return `<div class="card-blue">
      <div class="h2" style="font-size:20px">${track ? `You finished the ${esc(track.name)} track` : 'Pick a track to get started'}</div>
      <p class="small" style="margin:6px 0 12px">${track ? 'Nice work. Pick another track in My path and keep going.' : 'A track links programs into a path, so you always know what comes next.'}</p>
      <button class="btn-i btn-yellow" data-action="tab" data-id="path">${track ? 'See other tracks' : 'Choose a track'}</button>
    </div>`;
  }

  function listView() {
    const chip = (id, label) =>
      `<button class="chip-i" data-action="category" data-id="${id}" aria-pressed="${(ui.category || 'all') === id}">${label}</button>`;
    const chips = chip('all', 'All') + Object.entries(D.categories).map(([id, t]) => chip(id, esc(t))).join('');
    const list = D.programs.filter(p => !ui.category || p.cat === ui.category);
    return `<h3 class="g-title">All programs</h3>
      <div class="chips-i" role="group" aria-label="Filter by category">${chips}</div>
      ${list.map(programRow).join('') || '<p class="dim">No programs in this category yet.</p>'}`;
  }

  function programRow(p) {
    const label = `${p.name} at ${p.site}. Earns ${p.points} points. Free ride from your school.`;
    return `<button class="row-btn" data-action="open" data-id="${p.id}" aria-label="${esc(label)}">
      <span class="rowline"><span class="h">${esc(p.name)}</span>${pill(p.points)}</span>
      <span class="small dim flex" style="margin-top:2px">${icon(venueIcon(p))}${esc(p.site)}</span>
      <span class="tiny dim flex" style="margin-top:2px">${icon('bus')}Free ride from your school</span>
    </button>`;
  }

  // Map: a sketch that places each site by its coordinates. It is not a real map.
  const LAT = [42.30, 42.45], LON = [-83.27, -82.92];
  const project = (lat, lon) => [
    Math.min(94, Math.max(6, ((lon - LON[0]) / (LON[1] - LON[0])) * 100)),
    Math.min(92, Math.max(14, ((LAT[1] - lat) / (LAT[1] - LAT[0])) * 100))
  ];

  function groupSites() {
    const order = [];
    const groups = {};
    D.programs.forEach(p => {
      if (!groups[p.site]) { groups[p.site] = { name: p.site, lat: p.lat, lon: p.lon, programs: [] }; order.push(p.site); }
      groups[p.site].programs.push(p);
    });
    return order.map(n => groups[n]);
  }

  function mapView(next) {
    const sites = groupSites();
    const pins = sites.map(site => {
      const [x, y] = project(site.lat, site.lon);
      const isNext = !!next && site.programs.some(p => p.id === next.program.id);
      const single = site.programs.length === 1;
      const names = site.programs.map(p => p.name).join(' and ');
      const label = `${isNext ? 'Up next. ' : ''}${site.name}: ${names}`;
      const badge = isNext
        ? `<span class="pin-star" aria-hidden="true">${icon('star', 'ic--fill')}</span>`
        : (!single ? `<span class="pin-count" aria-hidden="true">${site.programs.length}</span>` : '');
      const action = single ? `data-action="open" data-id="${site.programs[0].id}"` : `data-action="site" data-id="${esc(site.name)}" aria-pressed="${ui.site === site.name}"`;
      return `<button class="pin${isNext ? ' pin--next' : ''}" style="left:${x.toFixed(1)}%;top:${y.toFixed(1)}%" ${action}
        aria-label="${esc(label)}">${icon(venueIcon(site.programs[0]))}${badge}</button>`;
    }).join('');

    const selected = sites.find(s => s.name === ui.site);
    const card = selected ? `<div class="site-card">
      <div class="rowline"><span class="h">${esc(selected.name)}</span>
        <button class="close" data-action="close-site" aria-label="Close">${icon('close')}</button></div>
      ${selected.programs.map(p => `<button class="row-btn" data-action="open" data-id="${p.id}"
        aria-label="${esc(`${p.name}, earns ${p.points} points. Opens program details.`)}">
        <span class="rowline"><span>${esc(p.name)}</span>${pill(p.points)}</span></button>`).join('')}
    </div>` : '';

    return `<div class="map" role="group" aria-label="Map of ${sites.length} sites and ${D.programs.length} programs">
        <span class="map-note">${sites.length} sites · ${D.programs.length} programs</span>${pins}</div>
      <div class="key"><span>Star pin: your Up next</span><span>Number: programs at one site</span></div>
      <p class="tiny dim" style="margin:6px 0 0">A sketch, not a real map. Pin spots are approximate.</p>
      ${card}`;
  }

  function detailScreen(id) {
    const p = S.program(id);
    if (!p) return '';
    const enrolled = S.isEnrolled(sid(), p.id);
    const row = (ic, title, value) => `<div class="detail-row">${icon(ic)}<div><small>${title}</small>${esc(value)}</div></div>`;
    return `<button class="back" data-action="back">${icon('back')}Back</button>
      <div class="dim small flex">${esc(D.categories[p.cat])}</div>
      <h2 class="ltitle" data-title tabindex="-1" style="margin-top:4px">${esc(p.name)}</h2>
      ${pill(p.points, { suffix: 'each time you attend' })}
      <p style="margin:14px 0 0">${esc(p.summary)}</p>
      ${row('pin', 'Site', p.site)}
      ${row(venueIcon(p), 'Venue type', D.venues[p.venue])}
      ${row('cal', 'Schedule', p.schedule)}
      ${row('people', 'Grades', 'Grades K to 8')}
      ${row('home', 'Address', p.address)}
      <div class="tag-soft gap" style="margin-top:16px">${icon('bus')}Free ride from your school</div>
      <div style="margin-top:14px">${enrolled
        ? `<div class="checked" style="margin:0">${icon('check')}You joined this program</div>`
        : `<button class="btn-i btn-yellow" data-action="join" data-id="${p.id}" aria-label="Join ${esc(p.name)}">Join this program</button>`}</div>
      <p class="foot">Site and activity names come from GOAL Line Detroit. Schedules and details are samples for this demo.</p>`;
  }

  // The path: Explore, Build, Launch. Every state has a word, so it never relies on color.
  function pathNodes(track, student) {
    const states = S.levelStates(track, student.id);
    const items = track.levels.map((lv, i) => {
      const st = states[i];
      const pr = S.levelProgress(track, i, student.id);
      const status = st === 'complete' ? 'Done' : st === 'locked' ? 'Locked' : `${pr.done} of ${pr.required} sessions`;
      const before = i > 0 && states[i - 1] === 'complete';
      const after = i < states.length - 1 && st === 'complete';
      const box = st === 'complete' ? icon('check') : st === 'locked' ? icon('lock') : avatar(student);
      return `<li class="pnode pnode--${st}${before ? ' before-done' : ''}${after ? ' after-done' : ''}">
        <span class="pnode-box">${box}</span><b>${esc(lv.title)}</b>
        <span class="st">${esc(status)}</span><span class="pg">${esc(S.program(lv.programId).name)}</span></li>`;
    });
    return `<ol class="pathnodes" aria-label="${esc(track.name)} path">${items.join('')}</ol>`;
  }

  const blocks = pr =>
    `<span class="blocks" aria-hidden="true">${Array.from({ length: pr.required }, (_, i) => `<span class="block${i < pr.done ? ' block--on' : ''}"></span>`).join('')}</span>`;

  function pathScreen() {
    const student = S.currentStudent();
    const track = S.currentTrack(sid());
    let h = `<h2 class="ltitle" data-title tabindex="-1">My path</h2>`;
    if (track) {
      const totalBonus = track.levels.reduce((n, l) => n + l.bonus, 0);
      const states = S.levelStates(track, sid());
      const done = S.isTrackComplete(track, sid());
      h += `<div class="card-blue">
        <div class="h2">${esc(track.name)}</div>
        <p class="small" style="margin:4px 0">${esc(track.tagline)}</p>
        <p class="tiny h" style="margin:0">${track.levels.length} levels · ${totalBonus} bonus points</p>
        ${pathNodes(track, student)}
        ${done ? `<p class="small h flex gap">${icon('check')}Track complete</p>` : ''}
      </div>`;

      h += `<h3 class="g-title">Your levels</h3>`;
      h += track.levels.map((lv, i) => {
        const p = S.program(lv.programId);
        const st = states[i];
        const pr = S.levelProgress(track, i, sid());
        const word = st === 'complete' ? 'Complete' : st === 'current' ? 'In progress' : 'Locked';
        const tag = st === 'complete' ? `${icon('check')}Complete` : st === 'current' ? `${icon('run')}You are here` : `${icon('lock')}Locked`;
        const label = `${lv.title}: ${p.name} at ${p.site}. ${word}. ${pr.done} of ${pr.required} sessions. ${lv.bonus} bonus points. Opens program details.`;
        return `<button class="level level--${st}" data-action="open" data-id="${p.id}" aria-label="${esc(label)}">
          <span class="rowline"><span class="h">${esc(lv.title)}</span><span class="tag-i">${tag}</span></span>
          <span class="h2" style="display:block;font-size:19px">${esc(p.name)}</span>
          <span class="small" style="display:block">${esc(p.site)} · ${esc(p.schedule)}</span>
          <span class="flex gap">${blocks(pr)}<span class="small h">${pr.done} of ${pr.required} sessions</span></span>
          <span class="gap" style="display:block">${pill(lv.bonus, { suffix: st === 'complete' ? 'bonus earned' : 'bonus points' })}</span>
        </button>`;
      }).join('');

      const next = S.upNext(sid());
      if (next) {
        const pr = S.levelProgress(track, next.levelIndex, sid());
        const remaining = Math.max(pr.required - pr.done, 0);
        const following = track.levels[next.levelIndex + 1];
        h += `<h3 class="g-title">What unlocks next</h3><div class="card-i">
          <div>${remaining} more ${plural(remaining, 'session', 'sessions')} of ${esc(next.program.name)} finishes ${esc(next.level.title)} and earns +${next.level.bonus} bonus points.</div>
          ${following ? `<div class="small dim" style="margin-top:6px">Then you move on to ${esc(following.title)}: ${esc(S.program(following.programId).name)}.</div>` : ''}
        </div>`;
      }

      h += `<h3 class="g-title">At the end of the track</h3><div class="${done ? 'card-soft' : 'card-i'}">
        ${done ? `<div class="h flex">${icon('check')}Track complete</div>` : ''}
        <div>${esc(track.payoff)}</div>
        ${done ? '' : `<div class="small dim" style="margin-top:6px">Finish all ${track.levels.length} levels to get here.</div>`}
        <div class="tiny dim" style="margin-top:6px">A sample idea for this demo, not a confirmed event or offer.</div>
      </div>`;
    } else {
      h += `<div class="h2" style="font-size:22px">What sounds like you?</div>
        <p style="margin:6px 0 0">Pick a track and your path shows up here. Each track has three levels, and each level is one program.</p>`;
    }

    h += `<h3 class="g-title">${track ? 'Switch track' : 'Choose a track'}</h3>`;
    if (track) h += `<p class="small dim" style="margin:0 0 8px">Switching keeps the points and levels you already earned.</p>`;
    h += D.tracks.map(t => {
      const isCurrent = track && t.id === track.id;
      const levelsDone = t.levels.filter((_, i) => S.isLevelComplete(t, i, sid())).length;
      const progress = levelsDone === 0 ? 'Not started' : `${levelsDone} of ${t.levels.length} levels done`;
      const names = t.levels.map(l => S.program(l.programId).name);
      const label = `${t.name}. ${t.tagline} ${names.join(', then ')}. ${progress}.${isCurrent ? ' Your current track.' : ' Switches your path to this track. Progress you already earned is kept.'}`;
      return `<button class="trackcard${isCurrent ? ' trackcard--on' : ''}" data-action="choose" data-id="${t.id}" aria-label="${esc(label)}">
        <span class="t-ic" aria-hidden="true">${esc(t.name[0])}</span>
        <span style="flex:1;min-width:0">
          <span class="h" style="display:block">${esc(t.name)}</span>
          <span class="small" style="display:block">${esc(t.tagline)}</span>
          <span class="tiny dim" style="display:block;margin-top:2px">${names.map(esc).join(' → ')}</span>
          <span class="tiny h" style="display:block;margin-top:2px">${progress}</span>
        </span>
        ${isCurrent ? `<span class="here">${icon('check')}Your track</span>` : icon('chevron')}
      </button>`;
    }).join('');
    h += `<p class="foot">Tracks, payoffs, and schedules are samples for this demo.</p>`;
    return h;
  }

  function rewardsScreen() {
    const balance = S.pointsBalance(sid());
    const cheapest = Math.min(...D.rewards.map(r => r.cost));
    const merchants = D.merchants
      .filter(m => S.rewardsFor(m.id).length)
      .sort((a, b) => Math.min(...S.rewardsFor(a.id).map(r => r.cost)) - Math.min(...S.rewardsFor(b.id).map(r => r.cost)));

    let hint = '';
    if (balance < cheapest) {
      const first = S.redemptionsFor(sid()).length === 0;
      hint = `<div class="hint"><div class="flex">${icon('lock')}<div><div class="h">Your ${first ? 'first' : 'next'} reward is ${cheapest - balance} points away</div>
        <div class="small dim">Get checked in by staff at a program to earn points.</div></div></div>
        <button class="btn-i btn-blue" data-action="tab" data-id="programs">Find a program</button></div>`;
    } else if (S.redemptionsFor(sid()).length === 0) {
      hint = `<div class="hint"><div class="flex">${icon('gift')}<div><div class="h">No rewards redeemed yet</div>
        <div class="small dim">Pick one below and confirm to get a digital gift card code. Your codes are saved on your profile.</div></div></div></div>`;
    }

    let h = `<h2 class="ltitle" data-title tabindex="-1">Rewards</h2>
      <div class="balance"><span>You have</span>${pill(balance, { sign: '', suffix: 'points', lg: true })}</div>${hint}`;

    h += merchants.map(m => {
      const rewards = S.rewardsFor(m.id).slice().sort((a, b) => a.cost - b.cost);
      return `<div class="merchant"><span class="m-ic" aria-hidden="true">${esc(m.name[0])}</span>
          <div><div class="h">${esc(m.name)}</div><div class="small dim">${esc(m.area)} · ${esc(m.tagline)}</div></div></div>
        ${rewards.map(r => {
          const can = balance >= r.cost;
          return `<div class="reward"><div class="rowline"><span class="h">${esc(r.title)}</span>${pill(r.cost, { sign: '', suffix: 'points' })}</div>
            <div class="small dim" style="margin:2px 0 10px">${esc(r.detail)}</div>
            ${can
              ? `<button class="btn-i btn-yellow" data-action="redeem" data-id="${r.id}" aria-label="Redeem ${esc(r.title)} for ${r.cost} points">Redeem</button>`
              : `<div class="locked" aria-label="Locked. You need ${r.cost - balance} more points.">${icon('lock')}Need ${r.cost - balance} more points</div>`}
          </div>`;
        }).join('')}`;
    }).join('');
    h += `<p class="foot">Merchants and rewards are made-up examples for this demo. No real businesses are involved.</p>`;
    return h;
  }

  function sheetHTML() {
    const reward = ui.sheet && S.reward(ui.sheet);
    if (!reward) return '';
    const m = S.merchant(reward.merchantId);
    const balance = S.pointsBalance(sid());
    return `<div class="backdrop"><div class="sheet" role="dialog" aria-modal="true" aria-labelledby="sheet-title">
      <h2 id="sheet-title" data-title tabindex="-1">Spend ${reward.cost} points?</h2>
      <div class="h">${esc(reward.title)}</div>
      <div class="small dim">${esc(m.name)} · ${esc(m.area)}</div>
      <div class="calc" aria-label="You have ${balance} points. This costs ${reward.cost}. You will have ${balance - reward.cost} points.">
        <div><span>You have</span><span>${balance} points</span></div>
        <div><span>This costs</span><span>−${reward.cost} points</span></div>
        <div class="total"><span>You will have</span><span>${balance - reward.cost} points</span></div>
      </div>
      <button class="btn-i btn-blue" data-action="confirm-redeem">Confirm and get my code</button>
      <button class="btn-i btn-plain" data-action="cancel">Cancel</button>
    </div></div>`;
  }

  function giftScreen(id) {
    const r = S.redemptions.find(x => String(x.id) === String(id));
    if (!r) return '';
    const reward = S.reward(r.rewardId);
    const m = S.merchant(reward.merchantId);
    const spoken = r.code.split('').map(c => (c === '-' ? 'dash' : c)).join(' ');
    return `<button class="back" data-action="back">${icon('back')}Back</button>
      <h2 class="ltitle" data-title tabindex="-1" style="margin-top:0">Gift card</h2>
      <div class="gift">
        <div class="flex"><span class="m-ic" style="background:var(--light);color:var(--rise)" aria-hidden="true">${esc(m.name[0])}</span>
          <div><div class="h">${esc(m.name)}</div><div class="small dim">${esc(m.area)}</div></div></div>
        <div class="h2" style="margin-top:14px">${esc(reward.title)}</div>
        <div class="small dim">${esc(reward.detail)}</div>
        <div class="code"><div class="tiny h">Your code</div><strong aria-label="Gift card code: ${spoken}">${esc(r.code)}</strong></div>
      </div>
      <div style="margin-top:16px" class="h flex">${icon('star', 'ic--fill')}${r.cost} points spent</div>
      <div class="small dim">Redeemed ${fmtShort(r.date)}, ${fmtTime(r.date)}</div>
      <div class="small" style="margin-top:4px">Your balance now: ${S.pointsBalance(r.studentId)} points</div>
      <p class="foot">Demo code. It is not valid at any store. Merchants and rewards are made-up examples for this demo.</p>`;
  }

  function profileScreen() {
    const student = S.currentStudent();
    const track = S.currentTrack(student.id);
    const earned = S.earnedBadgeIds(student.id);

    let h = `<h2 class="ltitle" data-title tabindex="-1">Profile</h2>
      <div class="card-blue">
        <div class="flex" style="gap:14px">${avatar(student, 'avatar--lg')}
          <div><div class="h2">${esc(student.name)}</div><div class="small">Grade ${student.grade}</div>
          <div style="margin-top:6px">${pill(S.pointsBalance(student.id), { sign: '', suffix: 'points', lg: true })}</div></div></div>
        <div style="border-top:1px solid rgba(255,255,255,.3);margin-top:14px;padding-top:6px">
          ${track ? `<div class="small h flex" style="margin-top:8px">${esc(track.name)} path</div>${pathNodes(track, student)}`
                  : '<p class="small">Pick a track in My path and your path will show up here.</p>'}
        </div>
      </div>`;

    h += `<h3 class="g-title">Badges · ${earned.size} of ${D.badges.length}</h3><div class="badges">` + D.badges.map(b => {
      const rec = S.earnedBadges.find(e => e.studentId === student.id && e.badgeId === b.id);
      const got = earned.has(b.id);
      const mark = b.mark === 'gift' ? icon('gift') : esc(b.mark);
      return `<div class="badge${got ? '' : ' badge--locked'}" role="group" aria-label="${esc(b.name)}, ${got ? 'earned' : 'locked'}. ${esc(b.detail)}">
        <span class="badge-tile" aria-hidden="true">${mark}${got ? '' : `<span class="badge-lock">${icon('lock')}</span>`}</span>
        <div class="h small">${esc(b.name)}</div>
        <div class="tiny dim">${got ? `Earned ${fmtShort(rec.date)}` : `Locked · ${esc(b.detail)}`}</div></div>`;
    }).join('') + '</div>';

    const items = [];
    S.attendancesFor(student.id).forEach(a => items.push({
      date: a.date, ic: 'check', title: S.program(a.programId).name,
      sub: `Checked in by staff at ${fmtTime(a.date)}`, points: a.points, sign: '+'
    }));
    S.levelCompletions.filter(c => c.studentId === student.id).forEach(c => {
      const t = S.track(c.trackId);
      items.push({ date: c.date, ic: 'flag', title: `Level complete: ${t.levels[c.levelIndex].title}`, sub: t.name, points: c.bonus, sign: '+' });
    });
    S.redemptionsFor(student.id).forEach(r => {
      const reward = S.reward(r.rewardId);
      items.push({ date: r.date, ic: 'gift', title: `Redeemed: ${reward.title}`, sub: S.merchant(reward.merchantId).name, points: r.cost, sign: '−', gift: r.id });
    });
    items.sort((a, b) => b.date - a.date);
    h += `<h3 class="g-title">Activity</h3>` + (items.length ? `<div>` + items.map(it => {
      const body = `${icon(it.ic)}<div class="hist-body"><div class="h">${esc(it.title)}</div><div class="small">${esc(it.sub)}</div>
        <div class="tiny dim">${fmtDay(it.date)}</div></div>${pill(it.points, { sign: it.sign })}`;
      return it.gift
        ? `<button class="hist" data-action="gift" data-id="${it.gift}" aria-label="${esc(`${it.title} at ${it.sub} on ${fmtDay(it.date)}. Spent ${it.points} points. Opens the gift card.`)}">${body}</button>`
        : `<div class="hist" role="group" aria-label="${esc(`${it.title}. ${it.sub} on ${fmtDay(it.date)}. ${it.sign === '+' ? 'Earned' : 'Spent'} ${it.points} points.`)}">${body}</div>`;
    }).join('') + `</div>` : `<p class="dim">No activity yet. Join a program and get checked in to earn points.</p>`);

    h += `<h3 class="g-title">About</h3><p class="foot" style="margin-top:0">Tap In 313 is an independent project and is not an official City of Detroit app. Site and activity names come from GOAL Line Detroit. Schedules, rewards, and merchants are samples for this demo.</p>`;
    return h;
  }

  // ---------- Screens: staff ----------

  const today = d => d.toDateString() === new Date().toDateString();

  function staffHome() {
    const now = Date.now();
    const todays = S.attendances.filter(a => today(a.date));
    const bonusToday = S.levelCompletions.filter(c => today(c.date)).reduce((n, c) => n + c.bonus, 0);
    const week = S.attendances.filter(a => now - a.date.getTime() <= 7 * 86400000).length;
    const withRosters = D.programs.filter(p => S.roster(p.id).length).length;
    const programsToday = new Set(todays.map(a => a.programId)).size;
    const enrolled = new Set(Object.values(S.enrollments).flat()).size;
    const tile = (value, label, detail, hero) =>
      `<div class="tile${hero ? ' tile--hero' : ''}" role="group" aria-label="${esc(`${label}: ${value}. ${detail}.`)}"><b>${value}</b><span>${label}</span><small>${detail}</small></div>`;
    const programs = D.programs.slice().sort((a, b) => a.name.localeCompare(b.name) || a.site.localeCompare(b.site));

    return `<h2 class="ltitle" data-title tabindex="-1">Staff</h2>
      <div class="card-staff"><div class="h2" style="font-size:20px">Tap to confirm attendance</div>
        <p class="small" style="margin:4px 0 0">${esc(D.staff.name)} · ${esc(D.staff.role)}. Pick a program, then confirm each student who showed up.</p></div>
      <h3 class="g-title">At a glance</h3>
      <div class="tiles">
        ${tile(todays.length, 'Checked in today', `${programsToday} of ${withRosters} programs`, true)}
        ${tile(todays.reduce((n, a) => n + a.points, 0) + bonusToday, 'Points awarded today', 'Attendance and level bonuses')}
        ${tile(week, 'Check-ins, last 7 days', 'Across all programs')}
        ${tile(enrolled, 'Students enrolled', 'In at least one program')}
      </div>
      <h3 class="g-title">Pick a program</h3>
      ${programs.map(p => {
        const n = S.roster(p.id).length;
        return `<button class="row-btn" data-action="staff-open" data-id="${p.id}" aria-label="${esc(`${p.name} at ${p.site}. ${n} ${plural(n, 'student', 'students')}.`)}">
          <span class="rowline"><span class="h">${esc(p.name)}</span>${icon('chevron')}</span>
          <span class="small dim" style="display:block">${esc(p.site)} · ${esc(p.schedule)}</span>
          <span class="tiny dim" style="display:block">${n} ${plural(n, 'student', 'students')}</span></button>`;
      }).join('')}
      <p class="foot">Sample students and history, plus any check-ins you confirm in this demo.</p>`;
  }

  function checkInTime(student, program) {
    const a = S.attendancesFor(student.id).find(x => x.programId === program.id && today(x.date));
    return a ? a.date : null;
  }

  function trackNote(student, program) {
    const track = S.currentTrack(student.id);
    if (!track) return '';
    const i = track.levels.findIndex(l => l.programId === program.id);
    if (i < 0) return '';
    const pr = S.levelProgress(track, i, student.id);
    const status = pr.done >= pr.required ? 'level complete' : `${pr.done} of ${pr.required} sessions`;
    return `${track.name} · ${track.levels[i].title}: ${status}`;
  }

  function staffRoster(id) {
    const p = S.program(id);
    const roster = S.roster(p.id);
    const checkedIn = roster.filter(s => checkInTime(s, p)).length;
    return `<button class="back" data-action="staff-back" style="color:var(--city)">${icon('back')}Programs</button>
      <div class="card-staff">
        <h2 class="h2" data-title tabindex="-1" style="margin:0;color:#fff">${esc(p.name)}</h2>
        <div class="small" style="margin-top:4px">${esc(p.site)} · ${esc(p.schedule)}</div>
        <div class="small">Today, ${new Date().toLocaleDateString('en-US', { weekday: 'long', month: 'long', day: 'numeric' })}</div>
        <div class="small h" style="margin-top:6px">${checkedIn} of ${roster.length} checked in · +${p.points} points each</div>
      </div>
      <h3 class="g-title">Roster · ${roster.length} ${plural(roster.length, 'student', 'students')}</h3>
      ${roster.length ? '' : '<p class="dim">No students have signed up for this program yet.</p>'}
      ${roster.map(s => {
        const time = checkInTime(s, p);
        const note = trackNote(s, p);
        return `<div class="student"><div class="flex" style="gap:12px">${avatar(s, 'avatar--sm')}
            <div><div class="h">${esc(s.name)}</div><div class="small dim">Grade ${s.grade}</div>${note ? `<div class="tiny dim">${esc(note)}</div>` : ''}</div></div>
          ${time
            ? `<div class="checked">${icon('check')}Checked in at ${fmtTime(time)}</div>`
            : `<button class="btn-i btn-staff" data-action="confirm" data-id="${s.id}" style="margin-top:12px"
                aria-label="Confirm attendance for ${esc(s.name)}">Confirm attendance</button>`}
        </div>`;
      }).join('')}
      <p class="foot">Sample students. Confirming can't be undone in this demo. Use Reset demo above the phone to start over.</p>`;
  }

  // ---------- Celebrations ----------

  function unlockHTML() {
    const u = S.pendingUnlocks[0];
    if (!u) return '';
    const student = S.currentStudent();
    const remaining = S.pendingUnlocks.length - 1;
    const colors = ['var(--yellow)', '#fff', 'var(--light)', 'var(--spirit)'];
    const confetti = Array.from({ length: 24 }, (_, i) =>
      `<i style="left:${(i * 37 + 11) % 100}%;background:${colors[i % 4]};animation-delay:${((i * 13) % 10) / 10}s"></i>`).join('');
    let inner = '';

    if (u.kind === 'level') {
      const track = S.track(u.trackId);
      const lv = track.levels[u.levelIndex];
      const next = S.upNext(student.id);
      inner = `<span class="u-label">${icon('check')}Level complete</span>
        <div class="u-tile" aria-hidden="true">${icon('flag')}</div>
        <div><h2 id="unlock-title" data-title tabindex="-1">${esc(lv.title)} complete!</h2>
          <p class="dim" style="margin:6px 0 0">${esc(S.program(lv.programId).name)} · ${esc(track.name)}</p></div>
        <span class="u-bonus">${icon('star')}+${lv.bonus} bonus points</span>
        <div class="u-panel">${pathNodes(track, student)}</div>
        ${next ? `<div class="u-panel"><div class="tiny h">Up next</div><div class="h">${esc(next.level.title)}: ${esc(next.program.name)}</div>
          <div class="small">${esc(next.program.site)} · ${esc(next.program.schedule)}</div></div>` : ''}`;
    } else if (u.kind === 'track') {
      const track = S.track(u.trackId);
      const total = track.levels.reduce((n, l) => n + l.bonus, 0);
      inner = `<span class="u-label">${icon('flag')}Track complete</span>
        <div class="u-tile" aria-hidden="true">${icon('trophy')}</div>
        <div><h2 id="unlock-title" data-title tabindex="-1">${esc(track.name)} complete!</h2>
          <p class="dim" style="margin:6px 0 0">You finished all ${track.levels.length} levels.</p></div>
        <span class="u-bonus">${icon('star')}+${total} bonus points in all</span>
        <div class="u-panel"><div class="tiny h">At the end of the track</div><div>${esc(track.payoff)}</div>
          <div class="tiny" style="margin-top:6px">A sample idea for this demo, not a confirmed event or offer.</div></div>`;
    } else {
      const b = S.badge(u.badgeId);
      const count = S.earnedBadgeIds(student.id).size;
      inner = `<span class="u-label">${icon('star')}New badge</span>
        <div class="u-tile" role="img" aria-label="${esc(b.name)} badge">${b.mark === 'gift' ? icon('gift') : esc(b.mark)}</div>
        <div><h2 id="unlock-title" data-title tabindex="-1">${esc(b.name)}</h2><p class="dim" style="margin:6px 0 0">${esc(b.detail)}</p></div>
        <p class="u-more">${count} of ${D.badges.length} badges earned</p>`;
    }

    return `<div class="unlock" role="dialog" aria-modal="true" aria-labelledby="unlock-title">
      <div class="confetti" aria-hidden="true">${confetti}</div>
      <div class="unlock-inner">${inner}
        ${remaining > 0 ? `<p class="u-more">${remaining} more to see</p>` : ''}
        <button class="btn-i btn-yellow" data-action="unlock-next">${remaining > 0 ? 'Next' : 'Keep going'}</button>
      </div></div>`;
  }

  // ---------- App frame ----------

  function screenHTML() {
    if (ui.mode === 'staff') return ui.staffProgram ? staffRoster(ui.staffProgram) : staffHome();
    const top = ui.stack[ui.stack.length - 1];
    if (top) return top.type === 'detail' ? detailScreen(top.id) : giftScreen(top.id);
    return { programs: programsScreen, path: pathScreen, rewards: rewardsScreen, profile: profileScreen }[ui.tab]();
  }

  function tabbarHTML(inert) {
    const tab = (id, label, ic) =>
      `<button class="tab" data-action="tab" data-id="${id}" ${ui.tab === id ? 'aria-current="page"' : ''}>${icon(ic)}${label}</button>`;
    return `<nav class="tabbar" aria-label="Tap In 313 tabs"${inert}>${tab('programs', 'Programs', 'map')}${tab('path', 'My path', 'path')}${tab('rewards', 'Rewards', 'gift')}${tab('profile', 'Profile', 'user')}</nav>`;
  }

  function appHTML() {
    const student = ui.mode === 'student';
    const overlay = student && (S.pendingUnlocks.length > 0 || ui.sheet);
    const inert = overlay ? ' inert' : '';
    return `<div class="app app--${ui.mode}">
      <header class="appbar"><span class="mark" aria-hidden="true">313</span><span class="name">Tap In 313</span>${student ? '' : '<span class="badge-staff">Staff mode</span>'}</header>
      <div class="app-body" id="app-body"${inert}>${screenHTML()}</div>
      ${student ? tabbarHTML(inert) : ''}
      ${student ? sheetHTML() : ''}
      ${student ? unlockHTML() : ''}
      ${!student && ui.toast ? `<div class="toast" aria-hidden="true">${icon('check')}<span>${esc(ui.toast)}</span></div>` : ''}
    </div>`;
  }

  // ---------- Guided story ----------

  const STEPS = [
    { title: 'Meet Jordan', text: 'Grade 7, Tech Builder track, 60 points. The Programs tab opens on "Your next step starts here": Robotics, with a free ride tag.',
      done: () => tour.s1,
      go: () => { ui = Object.assign(fresh(), { mode: 'student' }); tour.s1 = true; } },
    { title: 'Browse the map and the list', text: 'Switch to Map, tap a pin, and open a program to see its site, schedule, address, and points.',
      done: () => tour.s2 || ui.mapOpened || ui.detailOpened,
      go: () => { ui.mode = 'student'; ui.tab = 'programs'; ui.stack = []; ui.showMap = true; ui.mapOpened = true; tour.s2 = true; } },
    { title: 'Staff confirm the second Robotics session', text: 'Staff mode is a separate view. Open Robotics and tap Confirm attendance for Jordan M.',
      done: () => S.sessionsCompleted('jordan', 'robotics') >= 2,
      go: () => { ui.mode = 'staff'; ui.staffProgram = 'robotics'; ui.toast = null; } },
    { title: 'Watch the celebrations', text: 'Back in Student view: Explore level complete (+25), then the Century Club badge at 105 points. Up next moves to Coding and Tech Club at Conely Library.',
      // Done once the level and Century Club celebrations have been seen. A later reward badge does not undo it.
      done: () => S.levelCompletions.some(c => c.studentId === 'jordan' && c.trackId === 'tech' && c.levelIndex === 0)
        && !S.pendingUnlocks.some(u => u.kind === 'level' || (u.kind === 'badge' && u.badgeId === 'century')),
      go: () => { ui.mode = 'student'; ui.tab = 'programs'; ui.stack = []; ui.showMap = false; } },
    { title: 'Redeem a reward', text: 'Open Rewards, redeem a slice or the wing combo, and see the digital gift card code.',
      done: () => S.redemptionsFor('jordan').length > 0,
      go: () => { ui.mode = 'student'; ui.tab = 'rewards'; ui.stack = []; } }
  ];

  function tourHTML() {
    const currentIndex = STEPS.findIndex(s => !s.done());
    return STEPS.map((s, i) => {
      const done = s.done();
      const state = done ? `${icon('check')}Done` : i === currentIndex ? 'Next up' : 'Not yet';
      return `<li class="step${done ? ' step--done' : ''}${i === currentIndex ? ' step--current' : ''}">
        <span class="step-num" aria-hidden="true">${i + 1}</span>
        <div><span class="step-state">${state}</span><h4>${esc(s.title)}</h4><p>${esc(s.text)}</p>
        <button class="btn-small" data-tour="${i}">Show me</button></div></li>`;
    }).join('') + (currentIndex === -1 ? `<li class="step step--done"><span class="step-num" aria-hidden="true">${icon('check')}</span><div><h4>That is the whole loop</h4>
      <p>Attend, get confirmed, level up, earn a badge, redeem. Use Reset demo to run it again.</p></div></li>` : '');
  }

  // ---------- Actions ----------

  function announce(msg) {
    const live = document.getElementById('live');
    if (!live) return;
    live.textContent = '';
    setTimeout(() => { live.textContent = msg; }, 40);
  }

  function confirmAttendance(studentId) {
    const p = S.program(ui.staffProgram);
    const student = S.student(studentId);
    if (!p || !student || S.hasAttended(studentId, p.id, new Date())) return;
    const unlocks = S.confirmAttendance(studentId, p.id);
    let msg = `${student.name} checked in. +${p.points} points.`;
    if (unlocks.length) msg += ' New achievements unlocked.';
    ui.toast = msg;
    announce(msg);
    clearTimeout(confirmAttendance.timer);
    confirmAttendance.timer = setTimeout(() => { if (ui.toast === msg) { ui.toast = null; render(); } }, 3500);
  }

  function act(action, id) {
    switch (action) {
      case 'tab': ui.tab = id; ui.stack = []; ui.site = null; break;
      case 'view': ui.showMap = id === 'map'; ui.site = null; if (ui.showMap) ui.mapOpened = true; break;
      case 'category': ui.category = id === 'all' ? null : id; break;
      case 'open': ui.stack.push({ type: 'detail', id }); ui.detailOpened = true; break;
      case 'back': ui.stack.pop(); break;
      case 'join': S.join(sid(), id); break;
      case 'site': ui.site = ui.site === id ? null : id; break;
      case 'close-site': ui.site = null; break;
      case 'choose': S.chooseTrack(id, sid()); break;
      case 'redeem': ui.sheet = id; break;
      case 'cancel': ui.sheet = null; break;
      case 'confirm-redeem': {
        const reward = S.reward(ui.sheet);
        ui.sheet = null;
        const r = reward && S.redeem(reward, sid());
        if (r) { ui.stack.push({ type: 'gift', id: r.id }); announce(`Redeemed. Your code is ${r.code.split('').join(' ')}.`); }
        break;
      }
      case 'gift': ui.stack.push({ type: 'gift', id }); break;
      case 'unlock-next': S.dismissUnlock(); break;
      case 'staff-open': ui.staffProgram = id; ui.toast = null; break;
      case 'staff-back': ui.staffProgram = null; ui.toast = null; break;
      case 'confirm': confirmAttendance(id); break;
      default: return;
    }
    render();
  }

  function setMode(mode) {
    ui.mode = mode;
    if (mode === 'staff') ui.toast = null;
    render();
  }

  function resetDemo() {
    S.reset();
    ui = fresh();
    tour = { s1: false, s2: false };
    lastKey = '';
    render();
    announce('Demo reset. Jordan is back at 60 points.');
  }

  // ---------- Rendering ----------

  function viewKey() {
    const top = ui.stack[ui.stack.length - 1];
    return [ui.mode, ui.tab, top ? top.type + top.id : '', ui.staffProgram || '', S.pendingUnlocks[0] ? S.pendingUnlocks.length + S.pendingUnlocks[0].kind : '', ui.sheet || ''].join('|');
  }

  const fidOf = el => (el && el.dataset && el.dataset.action ? el.dataset.action + '|' + (el.dataset.id || '') : null);

  function render(initial) {
    const host = document.getElementById('phone');
    if (!host) return;
    const oldBody = host.querySelector('.app-body');
    const scroll = oldBody ? oldBody.scrollTop : 0;
    const active = document.activeElement;
    const fid = host.contains(active) ? fidOf(active) : null;
    const key = viewKey();

    host.innerHTML = appHTML();

    const body = host.querySelector('.app-body');
    if (key === lastKey && body) body.scrollTop = scroll;
    if (!initial) {
      if (key !== lastKey) {
        const title = host.querySelector('.unlock [data-title], .sheet [data-title]') || host.querySelector('[data-title]');
        if (title) title.focus({ preventScroll: true });
      } else if (fid) {
        const same = Array.from(host.querySelectorAll('[data-action]')).find(el => fidOf(el) === fid);
        if (same) same.focus({ preventScroll: true });
      }
    }
    lastKey = key;

    document.querySelectorAll('[data-mode]').forEach(b => b.setAttribute('aria-pressed', String(b.dataset.mode === ui.mode)));
    const list = document.getElementById('tour-steps');
    if (list) list.innerHTML = tourHTML();
  }

  function init() {
    const host = document.getElementById('phone');
    if (!host) return;


    host.addEventListener('click', e => {
      const t = e.target.closest('[data-action]');
      if (t) act(t.dataset.action, t.dataset.id);
    });
    host.addEventListener('keydown', e => {
      if (e.key === 'Escape' && ui.sheet) { ui.sheet = null; render(); }
    });
    document.querySelectorAll('[data-mode]').forEach(b => b.addEventListener('click', () => setMode(b.dataset.mode)));
    const reset = document.getElementById('reset');
    if (reset) reset.addEventListener('click', resetDemo);
    const list = document.getElementById('tour-steps');
    if (list) list.addEventListener('click', e => {
      const b = e.target.closest('[data-tour]');
      if (!b) return;
      STEPS[Number(b.dataset.tour)].go();
      render();
      const reduce = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;
      host.scrollIntoView({ behavior: reduce ? 'auto' : 'smooth', block: 'center' });
    });

    render(true);
  }

  // Handles for testing in a script host with no page.
  globalThis.__tapDemo = { S, D, act, appHTML, tourHTML, setMode, resetDemo, get ui() { return ui; }, set ui(v) { ui = v; }, STEPS };

  if (typeof document !== 'undefined' && document.getElementById) init();
})();
