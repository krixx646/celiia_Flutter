# Release Build Instructions for Android Studio

## Important Notes About Google Sign-In

The app uses Google Sign-In which requires the APK to be signed with a key that matches the SHA-1 fingerprint registered in Firebase. To ensure that Google Sign-In works in your release build, follow these instructions carefully.

## Building a Release APK in Android Studio

### Method 1: Using Android Studio UI (Recommended)

1. Open the project in Android Studio
2. From the menu, select **Build → Build Bundle(s) / APK(s) → Build APK(s)**
3. Wait for the build to complete (you'll see a notification)
4. Click on "locate" in the notification to find the APK

The APK will be generated at: `app/build/outputs/apk/release/app-release.apk`

### Method 2: Using Generate Signed Bundle/APK Wizard

If Method 1 doesn't work, you can try this alternative approach:

1. From the menu, select **Build → Generate Signed Bundle / APK**
2. Select **APK** and click **Next**
3. In the key store path, browse to: `C:\Users\<YourUsername>\.android\debug.keystore`
4. Enter the following details:
   - Key store password: `android`
   - Key alias: `androiddebugkey`
   - Key password: `android`
5. Click **Next**
6. Select **release** build variant
7. Select **V1 (Jar Signature)** and **V2 (Full APK Signature)**
8. Click **Finish** to generate the APK

### Method 3: Using Command Line (Alternative)

You can also build using Gradle from the command line:

```
$env:JAVA_HOME = "C:\Program Files\Android\Android Studio\jbr"
.\gradlew.bat assembleRelease
```

The APK will be generated at: `app/build/outputs/apk/release/app-release.apk`

## Verifying the APK Signature

To verify that the APK is signed with the correct key, you can run:

```
$env:JAVA_HOME = "C:\Program Files\Android\Android Studio\jbr"
.\gradlew.bat signingReport
```

Make sure the SHA1 fingerprint for the release variant matches: `1C:5F:58:A4:52:1E:C0:FE:30:8D:79:D9:4F:4C:AB:38:FE:25:74:12`

## Installing the Release APK

To install the release APK on a connected device:

```
adb install -r app/build/outputs/apk/release/app-release.apk
```

If you get signature mismatch errors, uninstall the app first:

```
adb uninstall eu.thefit.celia
adb install app/build/outputs/apk/release/app-release.apk
```

## Troubleshooting

If Google Sign-In still doesn't work:

1. Make sure you're using the correct keystore (debug.keystore)
2. Verify the SHA-1 hash is registered in Firebase
3. Uninstall any previous versions of the app before installing the new one
4. Clear Google Play Services data on your device
5. Make sure you have the latest version of Google Play Services 