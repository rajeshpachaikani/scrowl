# Scrowl Architecture Documentation

## Overview

Scrowl is a Flutter-based mobile application that provides a personalized trivia feed powered by Firebase and Gemini AI. The architecture follows clean architecture principles with clear separation of concerns.

## Architecture Layers

### 1. Presentation Layer (UI)
- **Screens**: Full-page views (Onboarding, Home, Profile, Submit)
- **Widgets**: Reusable UI components (TriviaCardWidget)
- **Theme**: Centralized styling and theming

### 2. Business Logic Layer
- **Services**: State management and business logic
  - `AuthService`: Authentication and user session
  - `TriviaService`: Trivia data fetching and management
  - `UserService`: User profile and reward system
- **Providers**: State management using Provider pattern

### 3. Data Layer
- **Models**: Data structures (TriviaCard, UserProfile, Interest)
- **Firebase**: Backend services (Firestore, Auth, Storage, Functions)

## Technology Stack

### Frontend
- **Flutter**: UI framework (3.0.0+)
- **Dart**: Programming language
- **Provider**: State management
- **Material Design 3**: UI components

### Backend
- **Firebase**:
  - Firestore: NoSQL database
  - Authentication: Anonymous auth
  - Storage: Image storage
  - Cloud Functions: Serverless functions
- **Gemini AI**: Content generation
- **Node.js 18**: Functions runtime

### Build Tools
- **Flutter CLI**: Build and deployment
- **Firebase CLI**: Backend deployment
- **NPM**: Functions dependency management

## Data Flow

### User Onboarding Flow
```
User Input → AuthService.signInAnonymously()
         ↓
UserService.createUser() → Firestore users collection
         ↓
SharedPreferences → Store onboarding_completed
         ↓
Navigate to HomeScreen
```

### Trivia Feed Flow
```
User Opens App → UserService.fetchUser()
              ↓
         Get user interests
              ↓
TriviaService.fetchTriviaByInterests() → Firestore query
              ↓
         Display TriviaCards
              ↓
User Scrolls → Load more (pagination)
```

### Like/Save Flow
```
User Action → UserService.likeTrivia() / saveTrivia()
          ↓
     Update Firestore
          ↓
     Add Reward Points
          ↓
Firebase Function: updateUserRanking
          ↓
     Update User Rank
          ↓
     Update UI
```

### Submit Trivia Flow
```
User Submits → Validate Input
           ↓
TriviaService.submitTrivia() → Firestore trivia collection
           ↓
UserService.addRewardPoints() → Award points
           ↓
     Success Feedback
```

### AI Generation Flow
```
Scheduled Function (Daily) → generateDailyTrivia
                          ↓
              Loop through categories
                          ↓
              Gemini AI API call
                          ↓
              Parse JSON response
                          ↓
              Store in Firestore
```

## Database Schema

### Collections

#### users
```
Document ID: userId
Fields:
- username: string
- email: string (nullable)
- interests: array<string>
- rewardPoints: number
- rank: number
- likedTriviaIds: array<string>
- savedTriviaIds: array<string>
- createdAt: timestamp
- lastActive: timestamp
```

#### trivia
```
Document ID: auto-generated
Fields:
- question: string
- answer: string
- imageUrl: string (nullable)
- category: string
- tags: array<string>
- isSponsored: boolean
- sponsorName: string (nullable)
- likes: number
- source: string (nullable)
- createdAt: timestamp

Indexes:
- category + createdAt (DESC)
```

#### rankings
```
Document ID: userId
Fields:
- userId: string
- username: string
- rewardPoints: number
- rank: number
- updatedAt: timestamp

Indexes:
- rewardPoints (DESC) + updatedAt (DESC)
```

## State Management

### Provider Pattern

```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AuthService()),
    ChangeNotifierProvider(create: (_) => TriviaService()),
    ChangeNotifierProvider(create: (_) => UserService()),
  ],
  child: App
)
```

### Service State

Each service manages its own state:
- Loading states
- Error handling
- Data caching
- Pagination state

### UI Updates

```dart
Consumer<ServiceName>(
  builder: (context, service, child) {
    // UI rebuilds when service notifies listeners
    return Widget(...);
  }
)
```

## Security

### Firestore Rules

```
- Users can read all user profiles
- Users can only create/update their own profile
- Users can read all trivia
- Users can create trivia (authenticated)
- Rankings are read-only (managed by functions)
```

### Storage Rules

```
- Public read access for trivia images
- Authenticated write with size limits (5MB)
- User avatars restricted to owner
```

### Function Security

```
- generateTrivia: Can be secured with auth check
- Scheduled functions: Automatically secured
- Database triggers: Secure by design
```

## Performance Optimization

### Caching Strategies

1. **Local State Cache**
   - Services cache fetched data
   - Reduces redundant Firebase calls
   - Invalidate on pull-to-refresh

2. **Image Caching**
   - `cached_network_image` package
   - Persistent cache on device
   - Placeholder for loading states

3. **Pagination**
   - Load 10 items at a time
   - Infinite scroll with threshold
   - Last document cursor for efficiency

### Database Optimization

1. **Compound Indexes**
   - category + createdAt for queries
   - Efficient filtering and sorting

2. **Denormalization**
   - Store username in rankings collection
   - Avoid extra reads for leaderboard

3. **Batch Operations**
   - AI generation uses batches
   - Reduces function execution time

## Scalability Considerations

### Horizontal Scaling

- Firebase automatically scales
- Cloud Functions scale with demand
- Firestore handles high throughput

### Cost Management

1. **Read Optimization**
   - Pagination limits reads
   - Cache reduces redundant queries
   - Indexes improve query efficiency

2. **Function Optimization**
   - Batch AI generation
   - Rate limiting on AI calls
   - Cleanup old data to reduce storage

3. **Storage Optimization**
   - Image compression before upload
   - CDN for global distribution
   - Automatic cleanup of unused images

## Error Handling

### UI Level
```dart
try {
  await service.performAction();
} catch (e) {
  ScaffoldMessenger.show(
    SnackBar(content: Text('Error: $e'))
  );
}
```

### Service Level
```dart
try {
  // Firebase operation
} catch (e) {
  if (kDebugMode) print('Error: $e');
  notifyListeners();
  rethrow; // Let UI handle
}
```

### Function Level
```javascript
try {
  // Operation
} catch (error) {
  console.error('Error:', error);
  throw new functions.https.HttpsError('internal', error.message);
}
```

## Testing Strategy

### Unit Tests
- Model serialization/deserialization
- Business logic in services
- Utility functions

### Widget Tests
- Individual widget rendering
- User interactions
- State changes

### Integration Tests
- Complete user flows
- Firebase integration
- Navigation flows

## Monitoring and Analytics

### Firebase Analytics
- User engagement metrics
- Screen views
- Custom events (likes, saves, submits)

### Crashlytics
- Crash reporting
- Error tracking
- Performance monitoring

### Cloud Functions Logs
- Execution logs
- Error tracking
- Performance metrics

## Deployment Pipeline

### Development
```
1. Local development
2. Unit tests
3. Widget tests
4. Manual testing
```

### Staging
```
1. Deploy to staging Firebase project
2. Integration tests
3. Beta testing
4. Performance testing
```

### Production
```
1. Deploy functions
2. Deploy Firestore rules
3. Build app bundles
4. Submit to stores
5. Monitor rollout
```

## Future Enhancements

### Phase 2
- User authentication (email/social)
- Comments on trivia
- Trivia verification system
- Advanced search and filters
- Dark mode

### Phase 3
- Multiplayer quiz mode
- Daily challenges
- Achievement system
- Social sharing
- Push notifications

### Phase 4
- Machine learning recommendations
- Content moderation AI
- Multi-language support
- Premium features
- Advanced analytics

## Best Practices

### Code Organization
```
lib/
├── models/        # Data structures
├── screens/       # Full-page views
├── widgets/       # Reusable components
├── services/      # Business logic
├── utils/         # Utilities and helpers
└── main.dart      # App entry point
```

### Naming Conventions
- Classes: PascalCase
- Files: snake_case
- Variables: camelCase
- Constants: UPPER_SNAKE_CASE (for true constants)

### State Management
- Keep services focused and single-purpose
- Use immutable data models
- Notify listeners only when state changes
- Dispose resources properly

### Firebase Best Practices
- Use security rules
- Create appropriate indexes
- Implement pagination
- Handle offline scenarios
- Monitor quota usage

## Troubleshooting

### Common Issues

1. **Firebase Connection**
   - Check firebase_options.dart
   - Verify project configuration
   - Check network connectivity

2. **State Not Updating**
   - Verify notifyListeners() calls
   - Check Provider scope
   - Ensure proper Consumer usage

3. **Performance Issues**
   - Check query efficiency
   - Verify indexes exist
   - Monitor Firebase usage
   - Profile app performance

## Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Gemini AI Documentation](https://ai.google.dev/docs)
- [Provider Package](https://pub.dev/packages/provider)
- [Material Design 3](https://m3.material.io/)
