# Onboarding v2 — personalization plan (this month)

Scope: the onboarding from the client spec (the wearable step, 8, is no longer offered), plus the plumbing that makes the
collected data actually change what the user gets (nutrition targets, routines, Celia).

Status: equipment preference added 2026-09-20 (onboarding v2). See §8.

---

## 1. Decision: do NOT wipe existing accounts

The app is live in the stores, so account deletion is not a neutral action: it removes
logins, streaks, logged meals, saved routines and body scans from real people, and it is
irreversible.

It is also unnecessary. The reason a wipe feels attractive is "everyone should have a
complete profile" — that is achieved by **versioning onboarding** instead:

- Store `onboardingVersion` on the user profile (server-side, not the device).
- On launch, if `onboardingVersion < CURRENT`, route the user into onboarding and show
  **only the steps whose data is missing**.
- Existing users keep their history and finish the new questions once.

This gives the same end state as a wipe, without destroying data or forcing a support
conversation with live users.

### What we can clean up instead

Live user-scoped rows are small (14 users with saved routines, 4 with logged meals), so
most accounts are internal test accounts. A targeted cleanup is reasonable:

- Delete **known internal/test accounts** by uid (explicit allowlist, not a blanket wipe).
- Keep the App Store review demo account (`tool/create_app_review_demo_user.py`).
- Never delete an account we cannot positively identify as ours.

---

## 2. Blocking problem to fix first: where the profile lives

Today:

- Profile lives in **Firebase Auth + Firestore** `users/{uid}.nutritionProfile`
  (weight, height, age, gender + computed macro targets).
- Onboarding completion is a **local `SharedPreferences`** flag
  (`onboarding_complete_{uid}`) — per device, lost on reinstall.
- The backend cannot read Firestore, so Flutter ships a `UserStateSnapshot`
  (name, body stats, macro targets) on every chat/avatar turn.

That does not scale to allergies, injuries, goals, coaching mood and notification
preferences: each new field would have to be re-sent by the client on every request, and
the routine generator would still not see it.

**Plan:** introduce a server-side `user_profiles` table in Supabase (keyed by Firebase
uid, same pattern as `user_meals` / `body_scans`), written through the existing
authenticated mobile API. Firestore keeps working for what it already stores; the new
personalization fields go to Supabase where the agent and routine generator can read them.

---

## 3. Steps: what we store and what it changes

| Step | Collected | What it must actually drive |
|------|-----------|-----------------------------|
| 1 Registration | name, email/password or social, T&C + medical disclaimer accepted | legal record (timestamp + version of terms) |
| 2 Physical data | sex, age, weight, height | BMR (Mifflin–St Jeor, already implemented) |
| 3 General goal | gain weight / lose weight / build muscle | calorie target offset (today TDEE is BMR × 1.55 flat, goal-blind) |
| 4 Nutrition | vegan/vegetarian/celiac/lactose, specific allergies, eating-disorder or diet-anxiety history, auto vs manual mode | meal suggestions, scanner→recipe, Celia hard constraints; the history flag suppresses aggressive deficits |
| 5 Exercise | home/gym, injuries + conditions, physical goal, secondary outcome, intensity, experience, auto/manual planning, minutes per day | routine generator + Celia `create_routine` (exclude contraindicated movements) |
| 6 Life coaching | current mood, what they want to work on | seeds coaching module + Celia tone |
| 7 Notifications | per-type toggles | stored now; **delivery is a later month** (no notification package in the app today) |
| 8 Wearables | optional connect | **defer** — no integration exists; show as optional/skip, do not promise |
| 9 Welcome | profile summary + first recommendation | generated from everything above |

### Honest scope flags

- **Step 7** — we can store preferences this month. Actually sending notifications needs
  push/local-notification infrastructure that does not exist yet. That is its own month.
- **Step 8** — connecting Google Fit / Health Connect / Fitbit / Garmin is a month of work
  on its own. This month it should be a skippable screen, or dropped until that month.
- Everything else in steps 1–6, 9 is realistic for this month.

---

## 4. Personalization wiring (the part that makes onboarding worth it)

1. **Calorie target respects the goal.** Today activity is hardcoded at 1.55 and the goal
   is ignored. Add goal-based offset and (optionally) a real activity-level question.
2. **Agent context grows.** Extend `UserStateSnapshot` / `buildUserStateSection` in
   `celia-admin/src/lib/celiaAgent/agent.ts` with allergies, injuries/conditions, training
   location, goal and equipment, so Celia stops asking what we already know.
3. **Routine generation respects injuries.** The generator and `create_routine` must
   filter the clip library against the user's injuries and training location.
4. **Safety copy.** The eating-disorder flag and the injuries list both need the
   "not a medical service" disclaimer reinforced, not just stored.

---

## 5. Suggested order of work

1. `user_profiles` table + authenticated read/write API + move the onboarding-complete
   flag off `SharedPreferences` onto the profile (`onboardingVersion`).
2. Onboarding v2 UI: steps 1–6, 9 (7 = store prefs only, 8 = skip/defer).
3. Version-gated re-entry for existing users (missing steps only).
4. Wire personalization: calorie goal offset, agent context, routine filtering.
5. Targeted cleanup of internal test accounts (explicit uid list).

---

## 6. Open questions for the client

- **Step 8**: confirm we defer wearables to its own month rather than shipping a dead screen.
- **Step 7**: confirm preferences-only this month, delivery later.
- Should onboarding be **skippable** for existing users, or a hard gate until complete?
- Does the club launch need a language/club field captured at onboarding (FR vs ES),
  given the two-club community that is coming later?

---

## 7. What shipped (2026-09-14)

**Data**

- `celia-admin/supabase/migrations/20260914_user_profiles.sql` — one row per Firebase uid
  with every answer from steps 1–8 plus `onboarding_version` and the computed targets.
  RLS on, no anon policy: reads and writes go through the backend service role, matching
  `user_meals` and `body_scans`.
- `GET/PUT /api/mobile/profile` — PUT is a partial update keyed on field name, so the app
  saves after every step and an abandoned run keeps its answers. Values that fail
  validation are skipped and reported in `rejected` rather than failing the save.

**App**

- `UserProfile` (`lib/models/user_profile.dart`) owns the step-completion rules:
  `missingSteps` is what makes version-gated re-entry ask one question instead of nine.
- `UserProfileProvider` + `UserProfileService`.
- Flow in `lib/screens/onboarding/` — host plus one file per step.
- The launch gate in `main.dart` now asks the server profile, and falls back to the old
  `SharedPreferences` flag only when the profile cannot be fetched, so an offline
  returning user is not marched through onboarding again with no way to save.
- The old single-screen `onboarding_screen.dart` is gone; its body-stats questions and
  targets preview are steps 2 and 9.

**Personalization**

- Calorie target: activity factor now comes from the training-intensity answer and the
  goal applies a deficit or surplus (`UserProfile.calorieMultiplier`). A reported history
  of disordered eating pins the target to maintenance.
- Agent: `loadOnboardingFacts` reads the profile server-side for both the chat and avatar
  routes. Allergies and injuries are read from the database rather than the request body
  on purpose — a constraint the client can edit is not a constraint.
- Routine generation: injuries, conditions, training location, experience and intensity
  are appended to the generator prompt as hard rules.

**Still outstanding**

- The migration has to be run in the Supabase SQL editor (the service key cannot run
  DDL). `scripts/verify_user_profiles_migration.py` confirms it afterwards.
- Notification delivery (step 7 stores consent only) and wearable integrations (step 8
  records the answer only) remain their own months, as flagged above.
- No widget test covers the flow end to end; the step-gating and wire-format rules are
  covered by `test/models/user_profile_test.dart` and
  `test/services/user_profile_service_test.dart`.

---

## 8. Equipment preference (2026-09-20)

- Profile columns: `uses_equipment` (null / false / true) and `available_equipment` (text[]).
  Migration: `celia-admin/supabase/migrations/20260920_user_profiles_equipment.sql`.
- Onboarding v2 (`kOnboardingVersion = 2`): training step asks bodyweight vs with equipment,
  then which kit. Existing v1 users are gated back for that question only.
- Generate Routine sheet: same bodyweight / with-equipment choice, prefills from profile.
- Routine generator synonyms now unlock barbell, cable, machine, smith, kettlebell, etc.
- Celia `search_exercises` filters by the stored preference; agent prompt asks when unknown.
- Premium equipment pack ingest: `tool/workout_clips/upload_premium_equipment.py`
  (source `premium_equipment_v1`, ~84 usable demos after skipping mistake/form-check reels).

