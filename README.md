# Scrowl - A Feed for Curious Minds

A personalized trivia feed app that replaces short-form content with fact-checked, interest-based trivia. Built with Flutter and Firebase, powered by Gemini AI.

## Features

### Core Features
- **Personalized Onboarding**: Select your interests from 12 categories (Science, Technology, History, Geography, Arts, Sports, Music, Nature, Space, Literature, Food, Movies)
- **Scrollable Trivia Feed**: Swipe through beautifully designed trivia cards with questions, answers, and images
- **Interactive Cards**: Like and save your favorite trivia pieces
- **Submit Trivia**: Contribute your own fact-checked trivia and earn points
- **Reward System**: Earn points for engagement (likes, saves, submissions)
- **Ranking System**: Progress through 6 ranks (Beginner → Explorer → Scholar → Expert → Master → Legend)
- **User Profile**: Track your points, rank, saved items, and statistics
- **Sponsored Content**: Support for sponsored trivia cards with clear labeling

### AI-Powered Content
- **Gemini AI Integration**: Automatic trivia generation using Google's Gemini AI
- **Daily Content**: Scheduled Firebase Functions generate fresh trivia daily
- **Fact-Checked**: AI prompts emphasize accuracy and verifiable information
- **Category-Based**: Content tailored to user interests

### Design
- **Clean Minimal UI**: Modern Material Design 3 with custom theming
- **Category Colors**: Each category has a unique color scheme for visual distinction
- **Smooth Animations**: Polished user experience with intuitive interactions
- **Responsive Layout**: Works seamlessly on different screen sizes

## Project Structure

```
scrowl/
├── lib/
│   ├── models/           # Data models (TriviaCard, UserProfile, Interest)
│   ├── screens/          # UI screens (Home, Onboarding, Profile, Submit)
│   ├── widgets/          # Reusable widgets (TriviaCardWidget)
│   ├── services/         # Business logic (Auth, Trivia, User services)
│   ├── utils/            # Utilities (Theme, Constants)
│   ├── firebase_options.dart
│   └── main.dart
├── functions/            # Firebase Cloud Functions
│   ├── index.js          # Gemini AI integration and scheduled tasks
│   └── package.json
├── firebase.json         # Firebase configuration
├── firestore.rules       # Firestore security rules
├── firestore.indexes.json
├── storage.rules
└── pubspec.yaml
```

## Setup Instructions

### Prerequisites
- Flutter SDK (3.0.0 or higher)
- Firebase account
- Google Cloud account (for Gemini AI API)
- Node.js 18+ (for Firebase Functions)

### 1. Flutter Setup
```bash
# Install dependencies
flutter pub get

# Run code generation (if needed)
flutter pub run build_runner build
```

### 2. Firebase Setup
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize Firebase in your project
firebase init

# Select:
# - Firestore
# - Functions
# - Hosting (optional)
# - Storage

# Configure Flutter Firebase
flutterfire configure
```

### 3. Gemini AI Setup
```bash
# Get Gemini API key from Google AI Studio
# https://makersuite.google.com/app/apikey

# Set up Firebase Functions config
firebase functions:config:set gemini.apikey="YOUR_GEMINI_API_KEY"

# Or use environment variables for local development
cd functions
echo "GEMINI_API_KEY=your_key_here" > .env
```

### 4. Install Function Dependencies
```bash
cd functions
npm install
```

### 5. Deploy Firebase
```bash
# Deploy Firestore rules and indexes
firebase deploy --only firestore

# Deploy storage rules
firebase deploy --only storage

# Deploy functions
firebase deploy --only functions
```

### 6. Run the App
```bash
# Run on emulator/device
flutter run

# Build for release
flutter build apk       # Android
flutter build ios       # iOS
flutter build web       # Web
```

## Firebase Collections

### Users Collection
```json
{
  "id": "user_id",
  "username": "string",
  "email": "string?",
  "interests": ["array", "of", "strings"],
  "rewardPoints": 0,
  "rank": 0,
  "likedTriviaIds": [],
  "savedTriviaIds": [],
  "createdAt": "timestamp",
  "lastActive": "timestamp"
}
```

### Trivia Collection
```json
{
  "question": "string",
  "answer": "string",
  "imageUrl": "string?",
  "category": "string",
  "tags": ["array"],
  "isSponsored": false,
  "sponsorName": "string?",
  "likes": 0,
  "source": "string?",
  "createdAt": "timestamp"
}
```

### Rankings Collection
```json
{
  "userId": "string",
  "username": "string",
  "rewardPoints": 0,
  "rank": 0,
  "updatedAt": "timestamp"
}
```

## Reward Points System
- **Like a trivia**: 1 point
- **Save a trivia**: 2 points
- **Submit a trivia**: 10 points
- **Daily login**: 5 points

## Ranking Thresholds
- **Beginner**: 0 points
- **Explorer**: 50 points
- **Scholar**: 200 points
- **Expert**: 500 points
- **Master**: 1000 points
- **Legend**: 2500 points

## Firebase Functions

### `generateTrivia`
On-demand HTTPS callable function to generate trivia using Gemini AI.
```javascript
// Example call from Flutter
final result = await FirebaseFunctions.instance
  .httpsCallable('generateTrivia')
  .call({'category': 'science', 'count': 5});
```

### `generateDailyTrivia`
Scheduled function that runs daily at midnight UTC to generate fresh trivia content for all categories.

### `updateUserRanking`
Firestore trigger that updates user rankings and leaderboard when reward points change.

### `cleanupOldTrivia`
Weekly scheduled function to remove trivia older than 90 days.

## Configuration Notes

### Firebase Options
Edit `lib/firebase_options.dart` with your Firebase project credentials after running `flutterfire configure`.

### Assets
The app expects assets in:
- `assets/images/` - For trivia images
- `assets/fonts/` - For custom fonts (Poppins family)

Note: Font files are referenced but not included. You can either:
1. Download Poppins font and add to assets/fonts/
2. Remove font configuration from pubspec.yaml to use default fonts

## Development Tips

### Testing Locally
```bash
# Start Firebase emulators
firebase emulators:start

# Run app against emulators
# (Update Firebase initialization in main.dart to use emulators)
```

### Adding Sample Data
You can manually add sample trivia to Firestore or trigger the `generateTrivia` function to populate with AI-generated content.

### Customization
- **Colors**: Edit `lib/utils/theme.dart`
- **Categories**: Edit `lib/models/interest.dart`
- **Points**: Edit `lib/utils/constants.dart`

## Contributing
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License
This project is open source and available under the MIT License.

## Support
For issues and questions, please open an issue on GitHub.

---

Built with ❤️ using Flutter and Firebase
