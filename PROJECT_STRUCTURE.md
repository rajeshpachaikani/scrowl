# Scrowl Project Structure

Visual guide to the project organization and file structure.

## Directory Tree

```
scrowl/
│
├── lib/                          # Flutter application code
│   ├── models/                   # Data models
│   │   ├── interest.dart         # Interest categories with colors
│   │   ├── trivia_card.dart      # Trivia data model
│   │   └── user_profile.dart     # User profile model
│   │
│   ├── screens/                  # Full-page screens
│   │   ├── home_screen.dart      # Main feed (home/profile tabs)
│   │   ├── onboarding_screen.dart# First-time user setup
│   │   ├── profile_screen.dart   # User profile & stats
│   │   └── submit_trivia_screen.dart # Trivia submission form
│   │
│   ├── widgets/                  # Reusable UI components
│   │   └── trivia_card_widget.dart # Trivia card component
│   │
│   ├── services/                 # Business logic & state
│   │   ├── auth_service.dart     # Authentication logic
│   │   ├── trivia_service.dart   # Trivia data management
│   │   └── user_service.dart     # User profile management
│   │
│   ├── utils/                    # Utilities & helpers
│   │   ├── constants.dart        # App constants & configs
│   │   └── theme.dart            # App theme & styling
│   │
│   ├── firebase_options.dart     # Firebase configuration
│   └── main.dart                 # App entry point
│
├── functions/                    # Firebase Cloud Functions
│   ├── index.js                  # Function implementations
│   ├── package.json              # Node dependencies
│   └── README.md                 # Functions documentation
│
├── test/                         # Test files
│   └── widget_test.dart          # Unit & widget tests
│
├── assets/                       # Static assets
│   ├── images/                   # Image assets
│   └── fonts/                    # Custom fonts
│
├── android/                      # Android platform code
├── ios/                          # iOS platform code
├── web/                          # Web platform code
│
├── firebase.json                 # Firebase project config
├── firestore.rules               # Firestore security rules
├── firestore.indexes.json        # Firestore indexes
├── storage.rules                 # Storage security rules
│
├── pubspec.yaml                  # Flutter dependencies
├── analysis_options.yaml         # Dart analyzer config
├── .gitignore                    # Git ignore rules
│
├── README.md                     # Project overview
├── QUICKSTART.md                 # Quick setup guide
├── SETUP.md                      # Detailed setup guide
├── ARCHITECTURE.md               # Architecture docs
├── FEATURES.md                   # Feature specifications
├── DEPLOYMENT.md                 # Deployment guide
├── CONTRIBUTING.md               # Contributing guide
├── LICENSE                       # MIT License
└── PROJECT_STRUCTURE.md          # This file
```

## Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│                     Presentation Layer                   │
│  ┌─────────────┐  ┌──────────────┐  ┌────────────────┐ │
│  │   Screens   │  │   Widgets    │  │     Theme      │ │
│  │             │  │              │  │                │ │
│  │ - Onboard   │  │ - TriviaCard │  │ - Colors       │ │
│  │ - Home      │  │              │  │ - Typography   │ │
│  │ - Profile   │  │              │  │ - Styles       │ │
│  │ - Submit    │  │              │  │                │ │
│  └─────────────┘  └──────────────┘  └────────────────┘ │
└─────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────┐
│                   Business Logic Layer                   │
│  ┌───────────────┐  ┌───────────────┐  ┌─────────────┐ │
│  │ AuthService   │  │ TriviaService │  │ UserService │ │
│  │               │  │               │  │             │ │
│  │ - Sign In     │  │ - Fetch       │  │ - Profile   │ │
│  │ - Sign Out    │  │ - Like        │  │ - Points    │ │
│  │ - User ID     │  │ - Submit      │  │ - Ranking   │ │
│  └───────────────┘  └───────────────┘  └─────────────┘ │
│               (Provider State Management)                │
└─────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────┐
│                      Data Layer                          │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌─────────┐│
│  │ Firestore│  │   Auth   │  │ Storage  │  │Functions││
│  │          │  │          │  │          │  │         ││
│  │ - Users  │  │ - Anon   │  │ - Images │  │ - AI    ││
│  │ - Trivia │  │          │  │          │  │ - Rank  ││
│  │ - Ranks  │  │          │  │          │  │         ││
│  └──────────┘  └──────────┘  └──────────┘  └─────────┘│
└─────────────────────────────────────────────────────────┘
```

## Data Flow Diagrams

### User Onboarding Flow

```
┌──────────┐
│  User    │
│  Opens   │
│   App    │
└────┬─────┘
     │
     ▼
┌─────────────────┐
│ Check Onboard   │
│   Completed?    │
└────┬───────┬────┘
     │       │
    No      Yes
     │       │
     ▼       ▼
┌─────────┐ ┌──────────┐
│Onboard  │ │   Home   │
│ Screen  │ │  Screen  │
└────┬────┘ └──────────┘
     │
     ▼
┌──────────────────┐
│ Select Interests │
└────┬─────────────┘
     │
     ▼
┌──────────────────┐
│ Create Auth User │
└────┬─────────────┘
     │
     ▼
┌──────────────────┐
│ Create Profile   │
│   in Firestore   │
└────┬─────────────┘
     │
     ▼
┌──────────────────┐
│  Save to Prefs   │
└────┬─────────────┘
     │
     ▼
┌──────────────────┐
│  Navigate Home   │
└──────────────────┘
```

### Trivia Feed Flow

```
┌──────────┐
│  Home    │
│  Screen  │
└────┬─────┘
     │
     ▼
┌──────────────────┐
│  Load User Data  │
└────┬─────────────┘
     │
     ▼
┌──────────────────┐
│ Get Interests    │
└────┬─────────────┘
     │
     ▼
┌──────────────────┐
│ Query Firestore  │
│ WHERE category   │
│  IN interests    │
└────┬─────────────┘
     │
     ▼
┌──────────────────┐
│ Display Cards    │
│ (Pagination 10)  │
└────┬─────────────┘
     │
  ┌──┴───┐
  │Scroll│
  └──┬───┘
     │
     ▼
┌──────────────────┐
│ Load More (80%)  │
└──────────────────┘
```

### Like/Save Flow

```
┌──────────┐
│   User   │
│  Taps    │
│Like/Save │
└────┬─────┘
     │
     ▼
┌──────────────────┐
│ Update UI        │
│ (Optimistic)     │
└────┬─────────────┘
     │
     ▼
┌──────────────────┐
│ Update Firestore │
│ - User array     │
│ - Trivia count   │
└────┬─────────────┘
     │
     ▼
┌──────────────────┐
│  Add Points      │
│  to User         │
└────┬─────────────┘
     │
     ▼
┌──────────────────┐
│ Firebase Trigger │
│ updateUserRanking│
└────┬─────────────┘
     │
     ▼
┌──────────────────┐
│ Calculate Rank   │
│ Update Profile   │
└──────────────────┘
```

## Component Hierarchy

### Home Screen Structure

```
HomeScreen
├── AppBar
│   ├── Title: "Scrowl"
│   └── Actions
│       └── IconButton (Submit)
├── Body (conditional)
│   ├── HomeFeed (index=0)
│   │   └── Consumer<TriviaService, UserService>
│   │       └── RefreshIndicator
│   │           └── ListView.builder
│   │               └── TriviaCardWidget (multiple)
│   │                   ├── Category Header
│   │                   ├── Image (optional)
│   │                   ├── Question
│   │                   ├── Answer (tap to reveal)
│   │                   ├── Source (optional)
│   │                   └── Actions (Like, Save)
│   │
│   └── ProfileScreen (index=1)
│       └── Consumer<UserService>
│           └── SingleChildScrollView
│               ├── Avatar & Username
│               ├── Rank Badge
│               ├── Points Card
│               │   └── Progress Bar
│               ├── Statistics
│               │   ├── Liked Count
│               │   └── Saved Count
│               ├── Interests
│               └── Reward Info
│
└── BottomNavigationBar
    ├── Home Tab
    └── Profile Tab
```

## State Management Flow

```
User Action
     │
     ▼
Widget Event Handler
     │
     ▼
Service Method
     │
     ├─► Update Local State
     │   (setState/notifyListeners)
     │
     ├─► Firebase Operation
     │   (Firestore/Auth/Storage)
     │
     └─► Error Handling
         └─► UI Feedback
             (SnackBar/Dialog)
```

## Firebase Collections Schema

### users/
```
{userId}/
  ├─ username: string
  ├─ email: string?
  ├─ interests: string[]
  ├─ rewardPoints: number
  ├─ rank: number
  ├─ likedTriviaIds: string[]
  ├─ savedTriviaIds: string[]
  ├─ createdAt: timestamp
  └─ lastActive: timestamp
```

### trivia/
```
{triviaId}/
  ├─ question: string
  ├─ answer: string
  ├─ imageUrl: string?
  ├─ category: string
  ├─ tags: string[]
  ├─ isSponsored: boolean
  ├─ sponsorName: string?
  ├─ likes: number
  ├─ source: string?
  └─ createdAt: timestamp
```

### rankings/
```
{userId}/
  ├─ userId: string
  ├─ username: string
  ├─ rewardPoints: number
  ├─ rank: number
  └─ updatedAt: timestamp
```

## File Dependencies

### Core Dependencies

```
main.dart
├─ requires: firebase_core, provider
├─ imports: firebase_options
├─ imports: screens/onboarding_screen
├─ imports: screens/home_screen
├─ imports: services/auth_service
├─ imports: services/trivia_service
├─ imports: services/user_service
└─ imports: utils/theme

home_screen.dart
├─ requires: provider
├─ imports: services (all)
├─ imports: widgets/trivia_card_widget
├─ imports: screens/profile_screen
├─ imports: screens/submit_trivia_screen
└─ imports: models/trivia_card

trivia_card_widget.dart
├─ requires: cached_network_image
├─ imports: models/trivia_card
├─ imports: models/interest
└─ imports: utils/theme
```

## Build Process

```
Source Code (lib/)
      │
      ▼
Flutter Compiler
      │
      ├─► Android (Gradle)
      │   └─► APK/AAB
      │
      ├─► iOS (Xcode)
      │   └─► IPA
      │
      └─► Web (Dart2JS)
          └─► HTML/JS/CSS
```

## Testing Structure

```
test/
└── widget_test.dart
    ├─ Interest Model Tests
    │  ├─ Count verification
    │  ├─ Unique ID check
    │  └─ Color retrieval
    │
    ├─ TriviaCard Model Tests
    │  ├─ Serialization
    │  ├─ Sponsored flag
    │  └─ JSON conversion
    │
    ├─ UserProfile Model Tests
    │  ├─ Serialization
    │  ├─ copyWith method
    │  └─ Field preservation
    │
    └─ Constants Tests
       ├─ Positive values
       ├─ Rank order
       └─ Count verification
```

## Key Files Explained

| File | Purpose | Key Components |
|------|---------|----------------|
| `main.dart` | App entry point | MultiProvider setup, Firebase init |
| `firebase_options.dart` | Firebase config | Platform-specific keys |
| `interest.dart` | Category definitions | 12 categories with colors |
| `trivia_card.dart` | Trivia data model | Question, answer, metadata |
| `user_profile.dart` | User data model | Points, rank, interests |
| `auth_service.dart` | Authentication | Anonymous sign-in |
| `trivia_service.dart` | Trivia logic | Fetch, like, submit |
| `user_service.dart` | User logic | Profile, points, ranking |
| `theme.dart` | App styling | Colors, text styles |
| `constants.dart` | App constants | Points, thresholds |

## Quick Reference

**Add new screen:**
1. Create in `lib/screens/`
2. Import in relevant navigation file
3. Add route if needed

**Add new model:**
1. Create in `lib/models/`
2. Implement fromJson/toJson
3. Add tests in `test/`

**Add new service:**
1. Create in `lib/services/`
2. Extend ChangeNotifier
3. Add to MultiProvider in main.dart

**Add new widget:**
1. Create in `lib/widgets/`
2. Make it reusable
3. Document props clearly

---

This structure follows Flutter best practices and clean architecture principles. For more details, see [ARCHITECTURE.md](ARCHITECTURE.md).
