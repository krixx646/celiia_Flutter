## Celia Integral Coach (Flutter)

Production Flutter app for The Fit – chat-based nutrition/fitness guidance with image upload, Firebase auth (Email/Google/Apple), and Botpress backend. Android is built locally; iOS is built via Codemagic (no Mac required).

### Tech stack
- **Flutter** (Material 3)
- **Firebase**: Auth, Firestore, Storage
- **Botpress**: chat API
- **Codemagic**: iOS CI/CD (simulator .app and signed .ipa)

### Project structure (high-level)
```
lib/
  main.dart
  services/        # firebase_service.dart (init), API clients
  repositories/    # auth/chat/history data access
  providers/       # app state (provider)
  ui/              # screens and widgets (auth, chat, history)
android/           # Gradle, signing, google-services.json
ios/               # Xcode project, Info.plist, GoogleService-Info.plist
```

## Prerequisites
- Flutter SDK 3.x (Dart >= 3.0)
- Android Studio or Android SDK + device/emulator
- Firebase project with iOS and Android apps created
- For iOS device/TestFlight: Apple Developer Program account and App Store Connect access

## Quick start
1) Install deps
```bash
flutter pub get
```

2) Firebase config files (download from Firebase Console → Project settings → Your apps)
- Android: place `android/app/google-services.json`
- iOS: place `ios/Runner/GoogleService-Info.plist`

3) Run on Android (debug)
```bash
flutter run -d <android-device-id>
```

4) iOS via Codemagic (simulator or signed device build). See “iOS builds with Codemagic” below.

## Firebase initialization notes
- The app initializes with bundled configs by default. See `lib/services/firebase_service.dart`.
- On iOS simulators (e.g., Appetize) you may optionally pass Firebase options via `--dart-define` if the plist isn’t bundled:
```bash
flutter build ios --simulator \
  --dart-define=FIREBASE_API_KEY=... \
  --dart-define=FIREBASE_IOS_APP_ID=... \
  --dart-define=FIREBASE_MESSAGING_SENDER_ID=... \
  --dart-define=FIREBASE_PROJECT_ID=... \
  --dart-define=FIREBASE_STORAGE_BUCKET=...
```

## Android setup
### App ID and versioning
- App ID: `eu.thefit.celia` (see `android/app/build.gradle.kts`)
- Version is read from `pubspec.yaml` (e.g., `version: 1.1.4+17`)

### Signing (release)
Keep the keystore **outside this repository** and never commit it or its
password. A previous release key was committed here in a public repo, with its
password in plain text in `legacy_android/build.gradle.kts`, and had to be
replaced. `.gitignore` covers `*.jks` and `key.properties`, but that only helps
for files git is not already tracking.

1) Create `android/key.properties` (untracked) pointing at a keystore stored
   elsewhere on the machine, e.g. `C:/Users/<you>/celia-keys/`:
```
storeFile=<absolute-path-to-release-jks-outside-the-repo>
storePassword=<password>
keyAlias=<alias>
keyPassword=<password>
```
2) The path must be the upload key Play expects for `eu.thefit.celia`. Check it
   matches Play Console → Setup → App integrity → upload key certificate:
```bash
keytool -list -v -keystore <path-to-jks> -alias <alias>
```
3) Build AAB for Play Console:
```bash
flutter build appbundle --release
```

### Firebase and Google Sign-In
- Add your release SHA-1 and SHA-256 in Firebase → Project settings → Android app.
- Download and replace `android/app/google-services.json` after updating fingerprints.

## iOS setup (no Mac required)
### Bundle ID and device support
- Bundle ID: `eu.thefit.celia`
- iPhone-only: `TARGETED_DEVICE_FAMILY = 1` and `UIRequiresFullScreen = true`; iPad orientations removed in `Info.plist`.

### Privacy purpose strings (Info.plist)
Clear, review-friendly text (already added):
- Camera: “Celia uses the camera so you can take a food photo to analyze calories and upload it in chat.”
- Photo Library: “Celia needs photo library access so you can choose an existing meal image to upload for calorie analysis.”
- Photo Library Add: “Celia may save processed images (e.g., analysis snapshots) back to your library when you choose to download them.”
- Microphone: “Celia uses the microphone only when you record video with sound for upload; audio is not recorded otherwise.”

### Sign in with Apple
- Enabled via Firebase’s native Apple provider on iOS.
- Entitlement `com.apple.developer.applesignin` is configured in `Runner.entitlements`.

## iOS builds with Codemagic
You can build two kinds of artifacts:
- Simulator `.app` (unsigned) for Appetize/browser preview
- Signed `.ipa` for TestFlight or real-device testing services

Minimal simulator workflow:
```yaml
workflows:
  ios-simulator:
    name: iOS Simulator (unsigned)
    environment:
      flutter: stable
    scripts:
      - name: Pub get
        script: flutter pub get
      - name: Build simulator app
        script: flutter build ios --simulator
    artifacts:
      - build/ios/iphonesimulator/*.app
```

Minimal signed device build:
```yaml
workflows:
  ios-device:
    name: iOS Device (signed .ipa)
    environment:
      flutter: stable
      ios_signing:
        distribution_type: app_store
        bundle_identifier: eu.thefit.celia
    scripts:
      - name: Pub get
        script: flutter pub get
      - name: Build IPA
        script: flutter build ipa --release --build-number=$BUILD_NUMBER
    artifacts:
      - build/ios/ipa/*.ipa
```

Codemagic signing prerequisites:
- App Store Connect API key or uploaded P12 + provisioning profile
- Team ID and automatic code signing enabled in Codemagic

## Environment variables
Some optional variables can be injected at build time:
- `IMGBB_KEY` (used by image upload feature)
- `SUPABASE_URL` and `SUPABASE_ANON_KEY` (used by routines/library)
- `CELIA_BACKEND_BASE_URL` (used by server-side AI routine generation and calorie scanner)
- `FIREBASE_*` values as shown above (only needed if not bundling plist for sims)

Pass with `--dart-define=KEY=VALUE` or configure in Codemagic UI as secure variables.

## Release checklists
### App Store Connect (iOS)
- App Information complete (name, subtitle, primary category)
- Screenshots for required sizes (iPhone only, iPad not required since app is iPhone-only)
- App Privacy questionnaire complete
- Export compliance answered (standard encryption → `ITSAppUsesNonExemptEncryption=false`)
- Content rights, age rating
- Privacy policy URL set
- TestFlight notes and demo credentials if sign-in required

### Google Play Console (Android)
- AAB signed with the correct key (matches Play-registered certificate)
- Store listing, content rating, privacy policy URL
- App content declarations

## Troubleshooting
- Firebase not initialized (iOS sim): ensure `GoogleService-Info.plist` is in `ios/Runner/` or pass `--dart-define` Firebase options.
- Apple Sign-In fails on hosted simulators: expected limitation (Keychain/Apple ID); works on TestFlight or real devices.
- “Wrong key” on Play upload: verify your release keystore and that `key.properties` points to the correct JKS used by Play.
- Duplicate quick-reply buttons: already de-duplicated in repository/provider/UI logic.
- Version mismatch (UI vs store): bump `version:` in `pubspec.yaml` and/or pass `--build-number` in CI.

## Security and keys
- Config files (`google-services.json`, `GoogleService-Info.plist`) contain API keys that must be RESTRICTED in Google Cloud/Firebase. They are not secrets but should be scoped to your app IDs and platforms.
- Avoid committing private keystores or P12 passwords. Use environment variables and CI key stores where possible.

## Commands (reference)
```bash
# Android release AAB
flutter build appbundle --release

# iOS simulator .app (for Appetize)
flutter build ios --simulator

# iOS signed .ipa (Codemagic or local macOS)
flutter build ipa --release --build-number=$BUILD_NUMBER
```

## License
Proprietary – © 2025 The Fit. All rights reserved.
