# Celia — Feature inventory for UI revamp (Grok brief)

**Purpose:** Give a brainstorming agent (Grok) a complete map of what Celia does today, where each capability sits in the current UI, and what is still unbuilt (no UI slot yet).  
**Audience:** Design / UX brainstorming only. Do **not** implement a redesign from this file until the product owner freezes a “final” layout after feature churn settles.  
**Product reality:** Features keep being added. Expect several redesign passes. Each pass should absorb newly shipped capabilities; the last frozen pass becomes the production UI.  
**Honest constraint:** The current UI works but is **not** considered optimized, sleek, or modern enough for the long-term product. Treat that as a redesign goal, not as an insult to existing work.

**App:** Celia Integral Coach — Flutter (iOS/Android), Firebase Auth, Supabase data, Next.js backend (`celia-admin`).  
**Locales:** 18 languages. Theme: Material 3 orange seed + Urbanist.  
**Inventory date:** 2026-09-21.

---

## How to read this document

| Tag | Meaning |
|-----|---------|
| **LIVE** | Shipped and reachable in the current UI |
| **LIVE — WEAK** | Exists in code / data, but UI is thin, dead, or hard to find |
| **NO UI YET** | Requested or planned; not allocated a screen/tab/entry point |
| **DEFERRED** | Explicitly parked until a month is scheduled |

When proposing a new IA (information architecture), every **LIVE** item must still be reachable. Every **NO UI YET** item needs a proposed home (or an explicit “defer” note).

---

## 1. Current navigation skeleton (LIVE)

There is **no drawer**. Navigation is:

```
App launch
  → Auth gate
  → Email verification (if needed)
  → Display-name setup (if needed)
  → Onboarding (missing steps only)
  → either Avatar Mode shell  OR  Main app (4 tabs)
```

### Main tabs (`lib/screens/main_screen.dart`)

| Index | Tab label | Screen |
|------:|-----------|--------|
| 0 | Home | `lib/screens/home/home_screen.dart` |
| 1 | Library | `lib/screens/library/library_screen.dart` |
| 2 | Chat | `lib/screens/chat_screen.dart` |
| 3 | Profile | `lib/screens/profile/profile_screen.dart` |

Secondary flows are **pushed routes** or **bottom sheets**, not extra tabs.

Optional parallel shell: **Avatar Mode** replaces the 4 tabs entirely while enabled (`lib/screens/avatar/avatar_mode_shell.dart`).

---

## 2. Entry, auth, and onboarding (LIVE)

### 2.1 Auth & account bootstrap

| Functionality | UI position | Notes |
|---------------|-------------|-------|
| Landing / marketing entry into auth | Auth screen | `auth_screen.dart` |
| Email + password sign in | Auth screen | |
| Email + password sign up (+ name) | Auth screen | |
| Google sign-in | Auth screen | |
| Apple sign-in | Auth screen (iOS) | |
| Forgot password | Auth → Forgot password screen | `forgot_password_screen.dart` |
| Email verification + resend | Email verification screen | After signup if unverified |
| Set display name | Name setup screen | If Firebase user has no name |
| Fatal Firebase init error | Full-screen error | Rare; blocks app |

### 2.2 Onboarding v2 (LIVE — multi-step, version-gated)

**Host:** `lib/screens/onboarding/onboarding_flow_screen.dart`  
Only **unanswered** steps are shown. Profile is server-side (`user_profiles`). Onboarding version is currently **2** (equipment preference added).

| Step | Functionality collected | UI position |
|------|-------------------------|-------------|
| Consent | T&Cs + non-medical disclaimer (timestamped) | Onboarding step |
| Physical | Sex, age, weight, height → BMR preview | Onboarding step |
| Goal | Lose weight / gain weight / build muscle | Onboarding step |
| Nutrition | Diet pattern, intolerances, allergies, eating-disorder history flag, auto vs manual meal planning, optional water target | Onboarding step |
| Training | Home / gym / both; **bodyweight vs equipment + kit**; fitness goal; experience; intensity; injuries; conditions; outcomes; planning mode; minutes/session; preferred time | Onboarding step |
| Life coaching seed | Current mood + free-text coaching focus | Onboarding step |
| Notifications prefs | Toggles: meals, workouts, water, progress, coach messages | Onboarding step — **prefs only, no delivery** |
| Wearables | Which provider they use (or “not now”) | Onboarding step — **preference only, no sync** |
| Summary | Profile recap + first-day recommendation + finish | Onboarding step |

After finish: calorie/macro targets sync into the nutrition feature; user enters main app (or Avatar Mode if already enabled).

---

## 3. Tab 0 — Home (LIVE)

**File:** `lib/screens/home/home_screen.dart`

| Functionality | UI position on Home |
|---------------|---------------------|
| Personalized greeting | Header |
| Streak chip | Header |
| Notifications bell | Header icon — **LIVE — WEAK** (`onPressed` empty) |
| Generate AI routine (CTA) | Hero card → opens generate sheet → may open routine detail + jump to Library |
| Daily progress card (kcal/macros eaten vs targets, insight, streak nudge) | Mid-screen card (`DailyProgressCard`) |
| Up Next / continue last workout | Card section → routine detail or start workout |
| Curated routine teaser cards | Same area |
| Quick action: open Chat | Chip / button → tab 2 |
| Quick action: Scan meal | → Calorie scanner screen |
| Quick action: Body scan | → Body scan hub |
| Quick action: Nutrition hub | → Nutrition screen |
| Quick action: Browse library | → tab 1 |
| Quick action: Track progress | → tab 3 (Profile) |

---

## 4. Tab 1 — Library (LIVE)

**File:** `lib/screens/library/library_screen.dart`

| Functionality | UI position |
|---------------|-------------|
| Curated routines grid | Sub-tab “Curated” |
| AI-generated / user routines grid | Sub-tab “AI Generated” |
| How to: search any equipment exercise (dumbbell, barbell, cable, machine…) and watch the full demonstration once, start to finish, never looped | Sub-tab “How to” → `how_to_tab.dart` → `video_player_screen.dart` |
| How-to series: type a series ("dumbbell chest and triceps"); up to 8 matching demos play in turn, each once, with a 20s rest (40s after every third) and auto-advance; the user taps any exercise to choose what plays next | “Play series” pill in How to → `how_to_series_screen.dart` |
| Open routine detail | Tap card |
| Notifications bell | Header — **LIVE — WEAK** (dead) |
| Empty / error / reload states | Full tab |

### Routine detail & workout (pushed from Library / Home / Chat / Avatar)

| Functionality | UI position |
|---------------|-------------|
| Routine metadata, description, duration, difficulty | `routine_detail_screen.dart` |
| Step list / exercise list | Detail screen |
| Preview GIF / clip for a step | Dialog / preview on detail |
| Play a single step video | → `video_player_screen.dart` |
| Start workout | Detail CTA → `workout_launcher.dart` |
| Guided coached workout (sets, reps, holds, rest 20s / block rest 40s, clips, voice coach, pause/quit, completion) | `guided_workout_screen.dart` (default when guided flag on) |
| Legacy playlist-style player | `routine_player_screen.dart` (fallback if guided disabled) |
| Record workout completion / streak contribution | After guided completion |

### Generate routine sheet (LIVE)

**Widget:** `lib/widgets/generate_routine_sheet.dart`  
Opened from Home (and conceptually from Chat tools).

| Field | UI |
|-------|----|
| Free-text workout request | Text field |
| Duration chips | 10–60 min |
| Difficulty | Easy / medium / hard |
Workouts are bodyweight sessions only (a wall, chair, bench or box is allowed). The sheet has no equipment option, and the backend and Celia never put equipment clips into a routine; those clips live in Library → How to.

---

## 5. Tab 2 — Chat / Celia coach (LIVE)

**File:** `lib/screens/chat_screen.dart`

| Functionality | UI position |
|---------------|-------------|
| Streaming text conversation with Celia | Main thread |
| Empty-state suggestion chips | When no messages |
| Conversation history list | Sheet (open / delete) |
| New conversation | Header / sheet action |
| Tool activity indicators | Inline in thread |
| Tool approval cards (save meal, create routine, etc.) | Cards in thread — user confirms |
| Open routine created/saved via tool | Deep link → routine detail |
| Text composer + send | Bottom bar |
| Voice input (STT) + spoken replies (TTS) | Mic / voice — gated by env flag |
| Shortcut to meal scanner | Composer / action |
| Nutrition targets injected into agent context | Invisible to user; affects answers |
| Profile constraints (allergies, injuries, equipment, mood…) injected server-side | Invisible; affects answers |

---

## 6. Tab 3 — Profile / settings (LIVE)

**File:** `lib/screens/profile/profile_screen.dart`

| Functionality | UI position |
|---------------|-------------|
| Avatar + display name | Header |
| Edit profile (name + photo → Firebase Storage) | Edit badge → `edit_profile_screen.dart` |
| Decorative menu icon | Header — not a real drawer |
| Notifications bell | Header — **LIVE — WEAK** (dead) |
| Stats: saved count, streak, workout completions | Stat row (**display only**, not tappable) |
| Account / signed-in email | Menu → dialog |
| Favorite routines | Menu → `saved_routines_screen.dart` (favorites only) |
| Nutrition hub | Menu → Nutrition screen |
| Body scan hub | Menu → Body scan screen |
| Language | Menu → `language_screen.dart` (system + 18 locales) |
| Avatar Mode toggle | Menu switch (if VRM flag enabled) — replaces main tabs |
| Dark mode toggle | Menu switch |
| Help / website | External link `https://the-fit.eu/` |
| Delete account | Menu (may require password reauth) |
| Log out | Menu |
| VRM avatar debug screen | Debug builds / flag only |

### LIVE — WEAK gaps on Profile / Library

| Capability | Issue |
|------------|-------|
| Full saved-routines list (`showFavoritesOnly: false`) | Implemented screen; **no nav entry** except favorites path |
| Explicit “Save / bookmark routine” on detail | Save mostly happens via workout completion / chat tools — **no clear bookmark CTA** on detail |
| Re-edit onboarding answers (allergies, equipment, notification prefs…) | Collected at onboarding; **no dedicated Profile editor** for full `user_profiles` yet |
| Notification prefs after onboarding | Stored once; **no settings screen to change later** |

---

## 7. Nutrition module (LIVE — secondary surfaces)

Entered from Home quick action, Profile menu, Chat shortcut, Avatar actions.

| Functionality | UI position |
|---------------|-------------|
| Nutrition hub: goals, today macros, weekly trend, Celia insights, meal history | `nutrition_screen.dart` |
| Edit / delete logged meal | Hub list actions |
| Edit nutrition goals (body stats → BMR/macros) | Hub → `nutrition_profile_setup_screen.dart` |
| Calorie / food scanner (camera → AI food items → review/edit → log) | `calorie_scanner_screen.dart` |
| Sources / estimate disclaimer citation | Compact citation widgets |

---

## 8. Body scan module (LIVE — secondary surfaces)

| Functionality | UI position |
|---------------|-------------|
| Hub: latest result, history, start CTA, disclaimer | `body_scan_screen.dart` |
| Flow: consent → stats → front + side photos → results (measurements, body fat %, etc.) | `body_scan_flow_screen.dart` |
| Silhouette framing overlay | Flow camera UI |
| Results body drawing with chest, waist, hip, and thigh marks | Result step and latest card (`body_scan_figure.dart`) |
| Full circumference set (neck, arms, thighs, calves, …) | Metrics grid “More measurements” section |
| Quota / eligibility (age 18+) | Enforced in flow + backend |

Photos are not stored. New scans save measurements only. The results screen draws a body figure; there is no 3D mesh viewer.

---

## 9. Avatar Mode shell (LIVE — optional alternate root)

**File:** `lib/screens/avatar/avatar_mode_shell.dart`

| Functionality | UI position |
|---------------|-------------|
| Full-screen 3D VRM Celia (or placeholder) | Entire shell |
| Hold-to-talk voice agent | Gesture on avatar |
| Captions / spoken replies / lip-sync | Overlay |
| Tool approvals | Bottom sheet |
| Navigate into Home / Library / Profile / Nutrition / Scanner / routine / start workout | Avatar action dispatcher (voice/tool driven) |
| Exit Avatar Mode | Control → back to 4-tab main |

---

## 10. Cross-cutting (LIVE)

| Functionality | UI position |
|---------------|-------------|
| Light / dark theme | Profile switch; applies globally |
| 18 languages + follow system | Language screen |
| Streak & progress computation | Home card + Profile stats |
| Haptics / Material chips / stadium buttons | Across onboarding & sheets |
| Feature flags (`Env`) | Guided workouts, voice coach, chat voice, GIF fallback, VRM avatar |

---

## 11. Exercise media & personalization (mostly invisible; affects LIVE flows)

These are not separate tabs, but they shape what users see in Library / Generate / Guided / Chat:

| Capability | How it surfaces |
|------------|-----------------|
| Filmed exercise clip library (`exercise_clips`) | Guided demos, routine steps |
| Premium equipment pack (84 full-length demos, tagged dumbbell/barbell/cable/…) | Library → How to only; never in a workout |
| Equipment preference on profile | Collected at onboarding; Celia mentions How to for owned kit |
| Injuries / conditions / location | Routine generator + agent hard rules |
| Rest policy (20s between exercises, 40s every 3rd = block rest) | Guided workout player |
| Hold vs reps playback (freeze on holds) | Guided workout player |

---

## 12. Features with NO UI YET (or not allocated)

Use these as “must place or consciously defer” in any IA proposal. Grouped by product area.

### 12.1 Community & clubs — DEFERRED (month not allocated)

Source: client spec + `CLIENT_FEATURE_BACKLOG.md` §A; reference site clubthefit.org.

| Item | Tag |
|------|-----|
| User↔user community comments / feed | **NO UI YET** / **DEFERRED** |
| User↔coach / Celia community Q&A channel | **NO UI YET** / **DEFERRED** |
| Admin→coaching team coordination chat | **NO UI YET** / **DEFERRED** |
| Announcements space | **NO UI YET** / **DEFERRED** |
| Dual independent clubs: French + Spanish exclusive spaces | **NO UI YET** / **DEFERRED** |
| Club membership / language gating | **NO UI YET** / **DEFERRED** |

### 12.2 Notifications delivery — prefs LIVE, delivery NO UI YET

| Item | Tag |
|------|-----|
| Push / local notification infrastructure | **NO UI YET** |
| Working notification center (bell currently dead) | **NO UI YET** (bell exists as dead chrome) |
| Re-edit notification prefs in settings | **NO UI YET** |
| Meal / macro gap reminders | **NO UI YET** |
| Over-calorie alerts | **NO UI YET** |
| Water reminders + manual water log UI | **NO UI YET** |
| Daily/weekly progress push summary | **NO UI YET** |
| Daily mood check-in notification | **NO UI YET** |
| Daily “what time do you train?” + usual vs Celia special | **NO UI YET** |
| Proactive Celia open (e.g. 2 days no water / low mood) | **NO UI YET** |

### 12.3 Nutrition depth

| Item | Tag |
|------|-----|
| Full personalized multi-day meal program UI | **NO UI YET** |
| Manual user recipes library | **NO UI YET** |
| Scanner → recipe matching against plan | **NO UI YET** (scanner logs meals only) |
| Dedicated water tracking screen / widget | **NO UI YET** |
| Profile editor for allergies / diet after onboarding | **NO UI YET** |

### 12.4 Training daily loop

| Item | Tag |
|------|-----|
| Daily training check-in flow (time + usual vs special) | **NO UI YET** |
| Explicit calendar / weekly plan board | **NO UI YET** |
| Clear Save/bookmark routine on detail | **NO UI YET** (weak) |
| Full “My routines” list (not only favorites) | **NO UI YET** (screen exists, unlinked) |

### 12.5 Life coaching module

| Item | Tag |
|------|-----|
| Ongoing mood tracking journal (beyond onboarding seed) | **NO UI YET** |
| Meditation / coaching content library (client book DB) | **NO UI YET** |
| Dedicated Life Coaching tab or section | **NO UI YET** |

### 12.6 Wearables

| Item | Tag |
|------|-----|
| Health Connect / Apple Health / Fitbit / Google Fit sync | **NO UI YET** (preference only in onboarding) |
| Sleep-quality → adapt today’s intensity | **NO UI YET** |
| Direct Garmin API | **DEFERRED** / blocked upstream; use Health bridges |

### 12.7 Chat memory & safety

| Item | Tag |
|------|-----|
| Durable long-term memory UI (“Celia remembers”) | **NO UI YET** (tools/partial context only) |
| Emergency risk-keyword protocol + emergency CTA | **NO UI YET** |
| Stronger always-visible medical disclaimer surfaces | **LIVE — WEAK** / strengthen |

### 12.8 Support & widgets

| Item | Tag |
|------|-----|
| In-app technical support chat | **NO UI YET** |
| Feedback / bug report button | **NO UI YET** |
| Home-screen widget (remaining calories / progress) | **NO UI YET** |

### 12.9 Celia V3 / multimodal (from `CLIENT_UPDATE_CELIA_V3.md`)

| Item | Tag |
|------|-----|
| Always-on talking avatar as primary experience | Partial LIVE (opt-in Avatar Mode); polish **NO UI YET** |
| Wake word (“Hey Celia”) | **NO UI YET** |
| Specialist agents (style, travel, wellbeing beyond fitness/food) | **NO UI YET** / vision |
| Smart-home control | Explicitly **not building** |
| Direct Garmin | Explicitly **not pursuing** for now |

---

## 13. Known UI / UX debt (for redesign motivation)

Call these out so Grok does not preserve accidental patterns:

1. **Four tabs + many pushed hubs** — Nutrition and Body Scan are important products but live as side trips from Home/Profile, not first-class IA.
2. **Dead notification bells** on Home, Library, Profile — look clickable, do nothing.
3. **Onboarding collects rich prefs** that later cannot be edited in Profile.
4. **Favorites vs Saved** confusion; full saved list orphaned.
5. **No clear visual system hierarchy** — orange Material chips everywhere; feels utilitarian rather than premium brand.
6. **Avatar Mode vs Chat tab** overlap — two ways to talk to Celia without a unified mental model.
7. **Equipment / injuries / allergies** affect generation but are mostly invisible after onboarding.
8. **Community (FR/ES)** will be large; current skeleton has **zero** place reserved for it.
9. **Life coaching** is a named client module but only a mood question today.
10. Current look is **functional, not sleek/modern** — redesign goal is clarity, brand presence, and room for growth.

---

## 14. Suggested brainstorming constraints for Grok

When proposing a revamp:

1. **Preserve reachability** of every **LIVE** capability (auth, onboarding, 4 current product areas: train, eat, talk to Celia, profile/settings, body scan).
2. Propose **homes** for high-priority **NO UI YET** items (especially: notification center, profile editing, water, life coaching, community placeholder for FR/ES).
3. Prefer **one clear primary path** to talk to Celia (text vs avatar), not two competing roots without a story.
4. Design for **feature accretion**: leave modular slots (e.g. Community, Coaching, Wearables) that can stay hidden until a month is allocated.
5. Assume **another redesign will happen** when the next big feature ships — optimize for a clean IA skeleton, not one-off screens.
6. Do **not** assume community or wearables sync are in the next build unless told otherwise.
7. Output should describe **structure and placement**, not Flutter code.
8. Respect legal/safety: non-medical disclaimer must remain visible in onboarding and sensitive flows.

---

## 15. Source files (for humans maintaining this inventory)

| Area | Paths |
|------|-------|
| Gates / tabs | `lib/main.dart`, `lib/screens/main_screen.dart` |
| Home / Library / Chat / Profile | `lib/screens/home/`, `library/`, `chat_screen.dart`, `profile/` |
| Onboarding | `lib/screens/onboarding/` |
| Workouts | `lib/screens/routines/` |
| Nutrition / scanner | `lib/screens/tools/` |
| Body scan | `lib/screens/body_scan/` |
| Avatar | `lib/screens/avatar/` |
| Client backlog | `CLIENT_FEATURE_BACKLOG.md` |
| V3 vision (plain English) | `CLIENT_UPDATE_CELIA_V3.md` |
| Onboarding plan | `docs/onboarding_v2_plan.md` |

---

## 16. One-paragraph product summary (for Grok)

Celia is a multilingual fitness and nutrition coach app: users authenticate, complete a rich onboarding profile, then use a four-tab shell (Home, Library, Chat, Profile) to generate and play guided bodyweight workouts, look up how to do equipment exercises, log meals via camera, optionally run a photo body scan, and talk to an AI coach (text and optional voice). An opt-in Avatar Mode can replace the tabs with a full-screen talking 3D Celia. Notification bells, wearables sync, community (separate French and Spanish clubs), life-coaching content, water tracking, home widgets, and several daily proactive loops are requested but not yet given real UI homes. The current UI is functional but not considered modern or scalable for the growing feature set; redesigns will iterate as features are allocated month by month until a final IA is frozen for production.

- Profile: 'The Fit Club' menu row (after Body Scan) opens a bottom sheet with an explanation and an 'Open the club' pill button that launches the club app in the external browser. Row hidden when the backend flag is off.
