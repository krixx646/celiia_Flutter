# App Signing Guide for Google Play Store

## Your Release Keystore

A proper signing key has been created for your app at:
```
app/keystore/celia_release_key.jks
```

## Important Security Note

Update the password in `app/build.gradle.kts` with the password you used when creating the keystore. 

**SECURITY CAUTION**: For a production app, DO NOT store your keystore password directly in the build.gradle file. Instead:

1. Create a `keystore.properties` file outside of version control 
2. Store your passwords there
3. Load them in your build script

## Getting the SHA-1 Fingerprint

To get the SHA-1 fingerprint for your new keystore:

1. Run `get_sha1.bat` in the project directory
2. Enter your keystore password when prompted
3. Look for the "SHA1:" line in the output

## Add SHA-1 to Firebase

You must add this SHA-1 fingerprint to your Firebase project for Google Sign-In to work:

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project 
3. Go to Project Settings
4. Add the SHA-1 fingerprint in the "Your apps" section
5. Download the updated `google-services.json` file
6. Replace the file in your app directory

## Building for Google Play Store

To build a signed AAB for the Play Store:

1. In Android Studio, select **Build → Generate Signed Bundle / APK**
2. Select **Android App Bundle**
3. Select your keystore:
   - Keystore path: `app/keystore/celia_release_key.jks`
   - Key alias: `celia`
   - Enter your passwords
4. Click **Next** and complete the wizard

## IMPORTANT: Keep Your Keystore Safe

If you lose this keystore, you **CANNOT** update your app on the Play Store. Make multiple backups in secure locations.

## App Signing by Google Play

For added security, consider using [Play App Signing](https://developer.android.com/studio/publish/app-signing#app-signing-google-play):

1. When uploading your first AAB, opt into Play App Signing
2. Google will manage your app's signing key
3. You'll use an "upload key" to sign your app before sending to Google Play 