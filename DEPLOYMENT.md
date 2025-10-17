# Scrowl Deployment Guide

This guide covers deploying Scrowl to production environments.

## Pre-Deployment Checklist

- [ ] All tests passing
- [ ] Code reviewed and approved
- [ ] Firebase project created (production)
- [ ] Gemini AI API key obtained
- [ ] App signed with release keys
- [ ] Privacy policy and terms created
- [ ] App store accounts ready

## Firebase Setup (Production)

### 1. Create Production Firebase Project

```bash
# Create new project in Firebase Console
# Project name: scrowl-prod
# Enable Google Analytics (recommended)
```

### 2. Configure Firebase Services

#### Firestore
```bash
# Deploy production rules
firebase use scrowl-prod
firebase deploy --only firestore:rules

# Create indexes
firebase deploy --only firestore:indexes
```

#### Authentication
```bash
# Enable Anonymous authentication
# (Optional) Enable email/password, Google Sign-In
```

#### Storage
```bash
# Deploy storage rules
firebase deploy --only storage
```

#### Functions
```bash
# Set Gemini API key
firebase functions:config:set gemini.apikey="YOUR_PRODUCTION_API_KEY"

# Deploy functions
firebase deploy --only functions
```

### 3. Security Rules (Production)

Update `firestore.rules` for production:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Helper functions
    function isAuthenticated() {
      return request.auth != null;
    }
    
    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }
    
    // Users collection
    match /users/{userId} {
      allow read: if isAuthenticated();
      allow create: if isOwner(userId);
      allow update: if isOwner(userId);
      allow delete: if isOwner(userId);
    }
    
    // Trivia collection
    match /trivia/{triviaId} {
      allow read: if true;
      allow create: if isAuthenticated() 
        && request.resource.data.question is string
        && request.resource.data.answer is string
        && request.resource.data.category is string;
      allow update: if isAuthenticated();
      allow delete: if false; // Only admins via console
    }
    
    // Rankings collection (read-only for clients)
    match /rankings/{userId} {
      allow read: if true;
      allow write: if false; // Only functions
    }
  }
}
```

## Android Deployment

### 1. Generate Signing Key

```bash
# Create keystore
keytool -genkey -v -keystore ~/scrowl-release-key.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias scrowl

# Keep keystore safe and secure!
```

### 2. Configure Build

Create `android/key.properties`:
```properties
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=scrowl
storeFile=/path/to/scrowl-release-key.jks
```

Update `android/app/build.gradle`:
```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    ...
    
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
            minifyEnabled true
            shrinkResources true
        }
    }
}
```

### 3. Build Release

```bash
# Build app bundle (recommended)
flutter build appbundle --release

# Or build APK
flutter build apk --release --split-per-abi
```

### 4. Google Play Console

1. Create app in Play Console
2. Upload app bundle
3. Fill in store listing:
   - Title: Scrowl
   - Short description
   - Full description
   - Screenshots (required)
   - Feature graphic
4. Set up content rating
5. Set pricing (free)
6. Submit for review

## iOS Deployment

### 1. Configure Xcode

```bash
# Open iOS project
open ios/Runner.xcworkspace
```

In Xcode:
- Select Runner → General
- Set Bundle Identifier: `com.scrowl.app`
- Set Version and Build Number
- Select Team (requires Apple Developer account)

### 2. Update Info.plist

Ensure required permissions in `ios/Runner/Info.plist`:
```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>Upload images for trivia</string>
<key>NSCameraUsageDescription</key>
<string>Take photos for trivia</string>
```

### 3. Build Release

```bash
# Build iOS app
flutter build ios --release

# Or build via Xcode for TestFlight/App Store
```

### 4. App Store Connect

1. Create app in App Store Connect
2. Upload build via Xcode or Transporter
3. Fill in app information:
   - App name: Scrowl
   - Subtitle
   - Description
   - Keywords
   - Screenshots (required for all sizes)
   - App icon
4. Set up privacy details
5. Set pricing (free)
6. Submit for review

## Web Deployment

### 1. Build Web App

```bash
# Build for web
flutter build web --release

# Output in build/web/
```

### 2. Firebase Hosting

```bash
# Initialize hosting (if not done)
firebase init hosting

# Deploy to Firebase Hosting
firebase deploy --only hosting

# Custom domain (optional)
# Configure in Firebase Console → Hosting → Add custom domain
```

### 3. PWA Configuration

The web build includes PWA support. Update `web/manifest.json`:
```json
{
  "name": "Scrowl - A Feed for Curious Minds",
  "short_name": "Scrowl",
  "start_url": "/",
  "display": "standalone",
  "background_color": "#F8F9FA",
  "theme_color": "#6366F1",
  "description": "Personalized trivia feed",
  "orientation": "portrait-primary",
  "icons": [
    {
      "src": "icons/icon-192.png",
      "sizes": "192x192",
      "type": "image/png"
    },
    {
      "src": "icons/icon-512.png",
      "sizes": "512x512",
      "type": "image/png"
    }
  ]
}
```

## Environment Configuration

### Production vs Staging

Create separate Firebase projects:
- `scrowl-dev` - Development
- `scrowl-staging` - Staging
- `scrowl-prod` - Production

Switch between environments:
```bash
firebase use scrowl-prod
flutterfire configure
```

### Environment Variables

For sensitive data, use environment variables:

```dart
// lib/config/env.dart
class Environment {
  static const String environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',
  );
  
  static bool get isProduction => environment == 'production';
  static bool get isStaging => environment == 'staging';
  static bool get isDevelopment => environment == 'development';
}
```

Build with environment:
```bash
flutter build apk --dart-define=ENVIRONMENT=production
```

## Monitoring and Analytics

### Firebase Analytics

```dart
import 'package:firebase_analytics/firebase_analytics.dart';

final analytics = FirebaseAnalytics.instance;

// Log events
await analytics.logEvent(
  name: 'trivia_liked',
  parameters: {'category': category},
);
```

### Crashlytics

Add to `pubspec.yaml`:
```yaml
dependencies:
  firebase_crashlytics: ^3.4.8
```

Initialize in `main.dart`:
```dart
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
  
  runApp(const ScrowlApp());
}
```

### Performance Monitoring

Add to `pubspec.yaml`:
```yaml
dependencies:
  firebase_performance: ^0.9.3+9
```

Track custom traces:
```dart
import 'package:firebase_performance/firebase_performance.dart';

final performance = FirebasePerformance.instance;
final trace = performance.newTrace('trivia_load');

await trace.start();
// ... load trivia
await trace.stop();
```

## CI/CD Pipeline

### GitHub Actions

Create `.github/workflows/deploy.yml`:
```yaml
name: Deploy

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Run tests
        run: flutter test
      
      - name: Build
        run: flutter build apk --release
      
      - name: Deploy Functions
        env:
          FIREBASE_TOKEN: ${{ secrets.FIREBASE_TOKEN }}
        run: |
          npm install -g firebase-tools
          cd functions && npm install && cd ..
          firebase deploy --only functions --token $FIREBASE_TOKEN
```

## Post-Deployment

### 1. Verify Deployment

- [ ] App installs successfully
- [ ] Firebase connection works
- [ ] Trivia loads correctly
- [ ] Like/save functions work
- [ ] Submit trivia works
- [ ] Reward points update
- [ ] Profile displays correctly
- [ ] AI generation works (call manually)

### 2. Monitor Initial Launch

```bash
# Watch function logs
firebase functions:log --follow

# Check Firestore usage
# Firebase Console → Firestore → Usage

# Monitor errors
# Firebase Console → Crashlytics
```

### 3. Gradual Rollout

For Play Store:
1. Start with 10% rollout
2. Monitor for crashes/issues
3. Increase to 50% after 24 hours
4. Full rollout after 48 hours

## Maintenance

### Regular Tasks

**Daily:**
- Monitor Crashlytics for new errors
- Check Cloud Functions execution logs
- Review user feedback

**Weekly:**
- Review Analytics data
- Check Firebase quotas
- Monitor costs
- Update trivia content

**Monthly:**
- Dependency updates
- Security audit
- Performance review
- User engagement analysis

### Updates

For app updates:
```bash
# Update version in pubspec.yaml
version: 1.0.1+2  # version+build

# Build new release
flutter build appbundle --release

# Upload to Play Console / App Store Connect
```

### Hotfix Process

```bash
# Create hotfix branch
git checkout -b hotfix/critical-bug

# Fix issue
# Test thoroughly

# Deploy
flutter build appbundle --release
# Upload to stores with expedited review request
```

## Rollback

If critical issue found:

**App Stores:**
- Play Store: Halt rollout, revert to previous version
- App Store: Request removal, expedited review for fix

**Firebase:**
```bash
# Revert functions
firebase deploy --only functions

# Revert Firestore rules
firebase deploy --only firestore:rules
```

## Costs and Quotas

### Firebase Free Tier

- Firestore: 50K reads, 20K writes per day
- Functions: 2M invocations per month
- Storage: 5GB
- Hosting: 10GB transfer per month

### Gemini AI Free Tier

- 60 requests per minute
- Monitor usage closely

### Scaling Costs

Calculate based on:
- Daily active users
- Trivia items per user
- AI generation frequency
- Storage usage

**Optimization Tips:**
1. Cache trivia client-side
2. Batch AI requests
3. Implement pagination
4. Use Cloud Storage CDN
5. Monitor and set budget alerts

## Security Checklist

- [ ] Security rules reviewed and tested
- [ ] API keys secured (not in source code)
- [ ] HTTPS enforced
- [ ] User data encrypted in transit
- [ ] Regular security audits
- [ ] Dependency vulnerabilities checked
- [ ] Rate limiting implemented
- [ ] Input validation on all forms
- [ ] No console.log in production
- [ ] Error messages don't leak sensitive info

## Support and Maintenance

### User Support

Set up:
- In-app feedback form
- Support email
- FAQ section
- Community forum/Discord

### Incident Response

1. **Detect**: Monitoring alerts
2. **Assess**: Severity and impact
3. **Respond**: Fix or rollback
4. **Communicate**: User notification
5. **Document**: Post-mortem

## Resources

- [Flutter Deployment Docs](https://docs.flutter.dev/deployment)
- [Firebase Best Practices](https://firebase.google.com/docs/rules/best-practices)
- [Play Console Help](https://support.google.com/googleplay/android-developer)
- [App Store Connect Help](https://developer.apple.com/app-store-connect/)

## Conclusion

Deployment is just the beginning. Continuous monitoring, updates, and user feedback are essential for long-term success.

Good luck with your launch! 🚀
