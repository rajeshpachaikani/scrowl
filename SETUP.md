# Scrowl Setup Guide

This guide will walk you through setting up the Scrowl app from scratch.

## Prerequisites

Before you begin, ensure you have the following installed:
- Flutter SDK 3.0.0 or higher
- Dart SDK (included with Flutter)
- Android Studio or VS Code with Flutter extension
- Xcode (for iOS development, macOS only)
- Node.js 18 or higher
- Firebase CLI
- Git

## Step-by-Step Setup

### 1. Clone the Repository

```bash
git clone https://github.com/rajeshpachaikani/scrowl.git
cd scrowl
```

### 2. Install Flutter Dependencies

```bash
flutter pub get
```

### 3. Create a Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add Project"
3. Enter project name: `scrowl` (or your preferred name)
4. Disable Google Analytics (optional)
5. Click "Create Project"

### 4. Enable Firebase Services

In your Firebase project:

#### Firestore Database
1. Go to Firestore Database
2. Click "Create Database"
3. Choose "Start in test mode"
4. Select a location
5. Click "Enable"

#### Authentication
1. Go to Authentication
2. Click "Get Started"
3. Enable "Anonymous" sign-in method

#### Storage
1. Go to Storage
2. Click "Get Started"
3. Start in test mode
4. Click "Done"

### 5. Configure Firebase for Flutter

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Make sure it's in your PATH
export PATH="$PATH:$HOME/.pub-cache/bin"

# Configure Firebase
flutterfire configure

# Follow the prompts:
# - Select your Firebase project
# - Choose platforms (Android, iOS, Web)
# - This will generate lib/firebase_options.dart
```

### 6. Set Up Firebase Functions

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize Firebase
firebase init

# Select the following:
# ✓ Firestore
# ✓ Functions
# ✓ Hosting (optional)
# ✓ Storage

# When prompted:
# - Use existing project: scrowl
# - Use default file names
# - JavaScript or TypeScript: JavaScript
# - ESLint: No
# - Install dependencies: Yes
```

### 7. Get Gemini AI API Key

1. Go to [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Click "Create API Key"
3. Copy the API key

```bash
# Set up Firebase Functions config
firebase functions:config:set gemini.apikey="YOUR_GEMINI_API_KEY"

# For local development
cd functions
echo "GEMINI_API_KEY=your_api_key_here" > .env
npm install
cd ..
```

### 8. Deploy Firebase Configuration

```bash
# Deploy Firestore rules and indexes
firebase deploy --only firestore

# Deploy storage rules
firebase deploy --only storage

# Deploy functions
firebase deploy --only functions
```

### 9. Update Android Configuration

Edit `android/app/build.gradle`:

```gradle
android {
    compileSdkVersion 33
    
    defaultConfig {
        applicationId "com.scrowl.app"
        minSdkVersion 21
        targetSdkVersion 33
        versionCode 1
        versionName "1.0.0"
        multiDexEnabled true
    }
}
```

Add to `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest ...>
    <uses-permission android:name="android.permission.INTERNET"/>
    <application ...>
        <!-- Your existing configuration -->
    </application>
</manifest>
```

### 10. Update iOS Configuration

Edit `ios/Runner/Info.plist`:

```xml
<dict>
    <!-- Add these keys -->
    <key>NSPhotoLibraryUsageDescription</key>
    <string>We need access to your photo library to upload trivia images</string>
    <key>NSCameraUsageDescription</key>
    <string>We need access to your camera to take photos for trivia</string>
</dict>
```

### 11. Run the App

```bash
# Check for connected devices
flutter devices

# Run on connected device or emulator
flutter run

# Or run in debug mode
flutter run --debug

# Or run in release mode
flutter run --release
```

## Troubleshooting

### Firebase Connection Issues

If you get Firebase connection errors:
```bash
# Re-run configuration
flutterfire configure

# Check firebase_options.dart is generated
cat lib/firebase_options.dart
```

### Function Deployment Issues

If functions fail to deploy:
```bash
cd functions
npm install
npm audit fix
cd ..
firebase deploy --only functions
```

### Gemini API Issues

If AI generation fails:
```bash
# Verify API key is set
firebase functions:config:get

# Test API key manually
# Visit: https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=YOUR_API_KEY
```

### Build Issues

Clear Flutter cache:
```bash
flutter clean
flutter pub get
flutter pub upgrade
```

## Optional: Add Sample Data

You can manually add sample trivia or trigger AI generation:

### Manual Sample Data

Add to Firestore `trivia` collection:
```json
{
  "question": "What is the speed of light?",
  "answer": "The speed of light in vacuum is approximately 299,792,458 meters per second (about 186,282 miles per second).",
  "category": "science",
  "tags": ["physics", "light", "constants"],
  "source": "Scientific consensus",
  "isSponsored": false,
  "likes": 0,
  "createdAt": "2025-10-17T00:00:00.000Z"
}
```

### Trigger AI Generation

From your app, you can call:
```dart
import 'package:cloud_functions/cloud_functions.dart';

// In your code
final functions = FirebaseFunctions.instance;
final result = await functions.httpsCallable('generateTrivia').call({
  'category': 'science',
  'count': 10,
});
```

## Next Steps

1. Test the app thoroughly
2. Add your own trivia content
3. Customize the UI theme
4. Add more features
5. Deploy to production

## Production Deployment

### Android
```bash
flutter build apk --release
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
firebase deploy --only hosting
```

## Support

If you encounter any issues:
1. Check the Flutter logs: `flutter logs`
2. Check Firebase Console for errors
3. Review the Firestore rules
4. Verify API keys are correct
5. Check network connectivity

For more help, open an issue on GitHub.
