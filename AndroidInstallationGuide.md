# Android APK Installation Guide

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Setting up Android Environment](#setting-up-android-environment)
3. [Configuring App Signing](#configuring-app-signing)
4. [Building the APK](#building-the-apk)
5. [Installing on Android Device](#installing-on-android-device)
6. [Alternative: Google Play Store Distribution](#alternative-google-play-store-distribution)

## Prerequisites

Before building your Flutter app for Android, ensure you have:
- A computer with Windows, macOS, or Linux
- Flutter SDK installed and working
- Android Studio installed (required for Android SDK)
- An Android device or emulator for testing

## Setting up Android Environment

### 1. Install Android Studio
1. Download and install Android Studio from: https://developer.android.com/studio/index.html
2. During installation, allow Android Studio to install the Android SDK, SDK platform tools, and SDK build tools
3. On first launch, Android Studio will assist you in installing additional Android SDK components

### 2. Configure Environment Variables
1. Set ANDROID_HOME environment variable pointing to your Android SDK location
2. Add Android SDK tools to your PATH:
   - Windows: `%ANDROID_HOME%\tools` and `%ANDROID_HOME%\platform-tools`
   - macOS/Linux: `$ANDROID_HOME/tools` and `$ANDROID_HOME/platform-tools`

### 3. Configure Flutter
Run the following command to point Flutter to your Android SDK:
```bash
flutter config --android-sdk <path-to-your-android-sdk>
```

### 4. Verify Setup
Check that Flutter recognizes your Android setup:
```bash
flutter doctor
```
All Android-related items should show a checkmark.

## Configuring App Signing

### 1. Create a Keystore
Generate a signing key for release builds:
```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

### 2. Configure Key Properties
Create a file `android/key.properties` in your Flutter project and add:
```
storePassword=<password from previous step>
keyPassword=<password from previous step>
keyAlias=upload
storeFile=<location of the key store file>
```

### 3. Configure Gradle
In `android/app/build.gradle`, add the following to reference your key properties:

```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    // ...
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

## Building the APK

### 1. Build Release APK
To build a release version of your app:
```bash
flutter build apk --release
```

### 2. Build Split APKs (Optional)
To generate smaller APKs for different CPU architectures:
```bash
flutter build apk --split-per-abi
```

### 3. Locate Your APK
After building, you'll find your APK files in:
- `build/app/outputs/flutter-apk/app-release.apk` (for single APK)
- `build/app/outputs/flutter-apk/` (for split APKs)

## Installing on Android Device

### 1. Enable USB Debugging
On your Android device:
1. Go to Settings > About Phone
2. Tap "Build Number" 7 times to enable Developer Options
3. Go back to Settings > Developer Options
4. Enable "USB Debugging"

### 2. Connect Your Device
1. Connect your Android device to your computer using a USB cable
2. Approve any USB debugging authorization dialogs on your device

### 3. Verify Device Connection
Check if Flutter recognizes your connected device:
```bash
flutter devices
```

### 4. Install Directly (Development Only)
To install the app directly to your connected device:
```bash
flutter install
```

### 5. Manual Installation
To manually install the APK:
1. Transfer the APK file to your Android device (via email, cloud storage, etc.)
2. Open the APK file on your device
3. Follow the installation prompts (you may need to allow installation from "Unknown sources")

## Alternative: Google Play Store Distribution

Instead of distributing APKs directly, consider uploading to Google Play Store using Android App Bundle:

### 1. Build App Bundle
```bash
flutter build appbundle --release
```

### 2. Upload to Google Play Console
1. Create a developer account on Google Play Console
2. Upload the generated app bundle (`build/app/outputs/bundle/release/app.aab`)
3. Complete the store listing and publish your app

## Troubleshooting

### Common Issues:
- **"Android license status unknown"**: Run `flutter doctor --android-licenses` and accept the licenses
- **"No connected devices"**: Ensure USB debugging is enabled and cables are properly connected
- **"Gradle build failed"**: Try cleaning the project with `flutter clean` and rebuild

### Verifying Your Installation
Once installed, open the app on your Android device to ensure everything works correctly, especially the connection to the backend server at `https://coachwriting.vercel.app`.

## Notes
- Our app is configured to connect to `https://coachwriting.vercel.app` as the backend server
- Make sure your Android device has internet connectivity to access the backend services