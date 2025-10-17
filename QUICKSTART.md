# Scrowl Quick Start Guide

Get Scrowl up and running in 15 minutes!

## Prerequisites

✅ Flutter SDK installed (3.0.0+)  
✅ Git installed  
✅ Firebase account created  
✅ Code editor (VS Code recommended)

## Step 1: Clone and Setup (2 min)

```bash
# Clone repository
git clone https://github.com/rajeshpachaikani/scrowl.git
cd scrowl

# Install dependencies
flutter pub get
```

## Step 2: Firebase Setup (5 min)

### Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add Project" → Name it "scrowl"
3. Disable Google Analytics (optional)
4. Click "Create Project"

### Enable Services

**Firestore:**
1. Go to Firestore Database → Create Database
2. Start in **test mode** → Next → Enable

**Authentication:**
1. Go to Authentication → Get Started
2. Enable "Anonymous" sign-in

**Storage:**
1. Go to Storage → Get Started
2. Start in test mode → Done

## Step 3: Configure Flutter App (3 min)

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Add to PATH if needed
export PATH="$PATH:$HOME/.pub-cache/bin"

# Configure Firebase
flutterfire configure

# Select your project: scrowl
# Select platforms: Android, iOS, Web (all)
# This creates lib/firebase_options.dart
```

## Step 4: Deploy Firebase (3 min)

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login
firebase login

# Initialize Firebase
firebase init

# Select:
# ✓ Firestore
# ✓ Functions  
# ✓ Storage

# Use existing project: scrowl
# Accept default file names
# For functions: JavaScript, No ESLint, Yes install dependencies

# Deploy Firestore rules and indexes
firebase deploy --only firestore

# Deploy storage rules
firebase deploy --only storage
```

## Step 5: Set Up Gemini AI (2 min)

```bash
# Get API key from https://makersuite.google.com/app/apikey

# Set in Firebase config
firebase functions:config:set gemini.apikey="YOUR_API_KEY"

# Install function dependencies
cd functions
npm install
cd ..

# Deploy functions
firebase deploy --only functions
```

## Step 6: Run the App! (2 min)

```bash
# Check devices
flutter devices

# Run on device/emulator
flutter run
```

## That's It! 🎉

You should now see the Scrowl app running with:
- ✅ Onboarding screen
- ✅ Interest selection
- ✅ Empty trivia feed (we need to add data)

## Adding Sample Data

### Option 1: Manual (Quick Test)

Go to Firebase Console → Firestore → Start collection "trivia":

```json
{
  "question": "What is the speed of light?",
  "answer": "The speed of light is approximately 299,792,458 meters per second.",
  "category": "science",
  "tags": ["physics", "light"],
  "source": "Scientific consensus",
  "isSponsored": false,
  "likes": 0,
  "createdAt": "2024-01-01T00:00:00.000Z"
}
```

Add a few more trivia items manually.

### Option 2: AI Generation (Recommended)

Call the function from your app or Firebase Console:

```dart
// Add this to your app temporarily for testing
import 'package:cloud_functions/cloud_functions.dart';

// In a button or init
final result = await FirebaseFunctions.instance
  .httpsCallable('generateTrivia')
  .call({
    'category': 'science',
    'count': 10,
  });
```

Or from Firebase Console → Functions → Select `generateTrivia` → Test

## Troubleshooting

### "No trivia available"
- Check Firestore has trivia documents
- Verify user interests match trivia categories
- Check Firestore security rules allow reads

### Firebase Connection Error
```bash
# Regenerate Firebase config
flutterfire configure
```

### Functions Not Working
```bash
# Check functions deployed
firebase deploy --only functions

# View logs
firebase functions:log
```

### Build Errors
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

## Next Steps

1. **Customize**: Edit colors in `lib/utils/theme.dart`
2. **Add Content**: Generate more trivia with AI
3. **Test Features**: Try like, save, submit
4. **Deploy**: See DEPLOYMENT.md for production

## Quick Commands Reference

```bash
# Development
flutter run                    # Run app
flutter test                   # Run tests
flutter analyze               # Check code

# Firebase
firebase deploy --only firestore    # Deploy rules
firebase deploy --only functions    # Deploy functions
firebase functions:log              # View logs

# Build
flutter build apk --release         # Android
flutter build ios --release         # iOS
flutter build web --release         # Web
```

## Resources

📚 [Full Setup Guide](SETUP.md)  
🏗️ [Architecture](ARCHITECTURE.md)  
🚀 [Deployment](DEPLOYMENT.md)  
✨ [Features](FEATURES.md)  
🤝 [Contributing](CONTRIBUTING.md)

## Getting Help

- **Issues**: [GitHub Issues](https://github.com/rajeshpachaikani/scrowl/issues)
- **Docs**: Check the comprehensive guides above
- **Firebase**: [Firebase Docs](https://firebase.google.com/docs)
- **Flutter**: [Flutter Docs](https://docs.flutter.dev/)

---

**Time to get started!** Follow the steps above and you'll have Scrowl running in about 15 minutes. 🚀

Have fun building!
