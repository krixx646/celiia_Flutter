# Celia: September 2026 release (1.2.2, build 49)

## Summary

September turned onboarding into something that changes what Celia does, added a
How to library for equipment exercises, made workouts bodyweight-only, and finished
the body scanner's results. Backend changes are already deployed on Vercel; the app
changes ship with this build.

## Shipped in the app

### Onboarding v2
- Questions cover registration and consent, physical data, goal, nutrition, training,
  life coaching, notification preferences, and a summary with calorie targets.
- Saved to the server after every step, so an abandoned run keeps its answers.
- Existing users are kept. They are asked only the questions they have not answered.
- The wearable question is no longer offered, because no device integration exists.

### Library: new "How to" tab
- 84 full-length equipment demonstrations (dumbbell, barbell, cable, machine, smith,
  bench) with English, Spanish and French names.
- Type an exercise ("dumbbell row") to find it, or a series ("dumbbell chest and
  triceps") to get a "Play series" button.
- A single demo plays once from start to finish and is never looped.
- A series plays up to 8 demos in turn, each once, with a rest between them
  (20 seconds, 40 after every third). The user can tap any exercise to choose what
  plays next.

### Workouts are bodyweight only
- The equipment chooser is removed from the Create Routine sheet.
- Equipment demos are never used in routines. Existing bodyweight workouts keep
  their looping demos and the 20s / 40s rest policy.

### Body scanner
- Results show a body drawing with chest, waist, hip and thigh marks, replacing the
  3D model.
- A "More measurements" section lists neck, under bust, belly, upper arm, forearm,
  wrist, thigh, mid-thigh, knee and calf when the scan returns them.
- Copy in all 18 languages no longer promises a 3D model. Photos are not stored;
  new scans save measurements only.

## Shipped on the backend (already live)
- Onboarding answers are stored in `user_profiles` and read server-side by chat,
  Avatar Mode and routine generation. Allergies, injuries and conditions cannot be
  edited through the request body.
- Calorie targets follow the goal and training intensity. A reported history of
  disordered eating pins the target to maintenance.
- Celia and routine generation only use bodyweight clips. When someone asks how to do
  an equipment exercise, Celia explains briefly and points to the How to tab.
- Body-scan history returns the full measurement set. No 3D mesh is uploaded.

## Tested
- Body scanner and onboarding verified on a device.
- Flutter analyzer clean; related unit tests pass (including new tests for the
  How to search and the profile rules). Backend production build passes.

## Known and deferred
- Notification preferences are stored; nothing sends notifications yet.
- Wearable or health sync is not built. Direct Garmin access is closed to new apps.
- 37 clips from the original filmed packs that use a dumbbell, band or ball stay out
  of new workouts; existing routines that use them still play.
- The guided workout player and How to series have not had a full device pass.
- Two test routines built on equipment clips were deleted, along with one saved by a
  real user that used dumbbell clips.

## Club link
- Profile > The Fit Club opens a sheet explaining the link is an early version, with a button that opens https://preview.builtwithrocket.new/thefitclub-0ewx?p=c in the browser.
- Backend route /api/mobile/club-link returns {enabled, url}; set CLUB_APP_URL to change the link or CLUB_APP_ENABLED=false to hide the entry without a release. The app falls back to the built-in URL if the route is unreachable.

## Play Store update prompt
- After login, Android installs from Play Store ask Play if a newer build exists. Soft prompt: Update / Later (3-day snooze). High-priority updates can force an immediate in-app update. No Vercel version env vars.

