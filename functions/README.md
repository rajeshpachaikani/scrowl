# Scrowl Firebase Functions

This directory contains Firebase Cloud Functions for the Scrowl app, powered by Google's Gemini AI.

## Functions

### 1. `generateTrivia` (HTTPS Callable)
Generates trivia content on-demand using Gemini AI.

**Parameters:**
- `category` (string, required): The category of trivia to generate
- `count` (number, optional): Number of trivia items to generate (default: 5)

**Returns:**
```json
{
  "success": true,
  "count": 5,
  "message": "Generated 5 trivia items for science"
}
```

**Example Usage (Flutter):**
```dart
import 'package:cloud_functions/cloud_functions.dart';

final functions = FirebaseFunctions.instance;
try {
  final result = await functions.httpsCallable('generateTrivia').call({
    'category': 'science',
    'count': 10,
  });
  print(result.data);
} catch (e) {
  print('Error: $e');
}
```

### 2. `generateDailyTrivia` (Scheduled)
Automatically generates fresh trivia content daily at midnight UTC for all categories.

**Schedule:** `0 0 * * *` (Every day at midnight UTC)

**Categories:**
- science
- technology
- history
- geography
- arts
- sports
- music
- nature
- space
- literature
- food
- movies

**Generates:** 3 trivia items per category per day

### 3. `updateUserRanking` (Firestore Trigger)
Updates user ranking and leaderboard when reward points change.

**Trigger:** `users/{userId}` document updates

**Logic:**
- Detects changes in `rewardPoints` field
- Calculates new rank based on thresholds
- Updates user document with new rank
- Updates rankings collection for leaderboard

**Rank Thresholds:**
```javascript
{
  'Beginner': 0,
  'Explorer': 50,
  'Scholar': 200,
  'Expert': 500,
  'Master': 1000,
  'Legend': 2500,
}
```

### 4. `cleanupOldTrivia` (Scheduled)
Removes trivia content older than 90 days to keep the database fresh.

**Schedule:** `0 2 * * 0` (Every Sunday at 2 AM UTC)

**Logic:**
- Finds trivia items older than 90 days
- Deletes up to 500 items per run
- Runs weekly to maintain database health

## Setup

### Install Dependencies
```bash
cd functions
npm install
```

### Set Up Gemini API Key

#### Production (Firebase):
```bash
firebase functions:config:set gemini.apikey="YOUR_GEMINI_API_KEY"
```

#### Local Development:
Create a `.env` file in the `functions` directory:
```bash
echo "GEMINI_API_KEY=your_api_key_here" > .env
```

Get your API key from [Google AI Studio](https://makersuite.google.com/app/apikey).

### Deploy Functions
```bash
# Deploy all functions
firebase deploy --only functions

# Deploy specific function
firebase deploy --only functions:generateTrivia
firebase deploy --only functions:generateDailyTrivia
firebase deploy --only functions:updateUserRanking
firebase deploy --only functions:cleanupOldTrivia
```

### Test Locally
```bash
# Start Firebase emulators
firebase emulators:start

# Or just functions emulator
firebase emulators:start --only functions
```

## Gemini AI Integration

The functions use Google's Gemini AI (gemini-pro model) to generate high-quality trivia content.

### Prompt Structure
The AI is instructed to generate trivia with:
- Clear, engaging questions
- Detailed, accurate answers
- Relevant tags
- Source references
- Fact-checked information

### Response Format
The AI returns JSON arrays:
```json
[
  {
    "question": "What is photosynthesis?",
    "answer": "Photosynthesis is the process by which plants...",
    "tags": ["biology", "plants", "energy"],
    "source": "Scientific consensus"
  }
]
```

### Error Handling
- Validates API responses
- Extracts JSON from markdown code blocks
- Logs errors for debugging
- Handles rate limiting with delays

## Cost Considerations

### Gemini API
- Free tier: 60 requests per minute
- Check pricing at [Google AI Pricing](https://ai.google.dev/pricing)

### Firebase Functions
- Free tier: 2M invocations/month
- Scheduled functions count towards quota
- Monitor usage in Firebase Console

### Optimization Tips
1. **Caching**: Store generated trivia for reuse
2. **Batch Requests**: Generate multiple items per call
3. **Rate Limiting**: Add delays between category generations
4. **Quota Monitoring**: Track API usage
5. **Error Handling**: Gracefully handle failures

## Monitoring

### View Logs
```bash
# All logs
firebase functions:log

# Specific function
firebase functions:log --only generateTrivia

# Follow logs in real-time
firebase functions:log --follow
```

### Firebase Console
- Go to Firebase Console → Functions
- View execution counts, errors, and performance
- Set up alerts for failures

## Development Tips

### Local Testing
```dart
// Use emulators in Flutter app (main.dart)
if (kDebugMode) {
  FirebaseFunctions.instance.useFunctionsEmulator('localhost', 5001);
}
```

### Debug Logging
```javascript
// In functions/index.js
console.log('Debug info:', data);
console.error('Error occurred:', error);
```

### Testing Individual Functions
```bash
# Open Firebase shell
firebase functions:shell

# Call function
generateTrivia({category: 'science', count: 3})
```

## Security

### Authentication
The `generateTrivia` function can be protected with authentication:

```javascript
exports.generateTrivia = functions.https.onCall(async (data, context) => {
  // Uncomment to require authentication
  // if (!context.auth) {
  //   throw new functions.https.HttpsError('unauthenticated', 'Must be authenticated');
  // }
  
  // ... rest of function
});
```

### Rate Limiting
Consider implementing rate limiting to prevent abuse:

```javascript
// Track user requests in Firestore
// Limit to X requests per hour per user
```

## Troubleshooting

### Function Not Deploying
```bash
# Check Node version
node --version  # Should be 18+

# Reinstall dependencies
rm -rf node_modules package-lock.json
npm install

# Try deploying again
firebase deploy --only functions
```

### Gemini API Errors
```bash
# Verify API key
firebase functions:config:get

# Test API key
curl "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=YOUR_KEY"
```

### Timeout Errors
```javascript
// Increase timeout (functions/index.js)
exports.generateDailyTrivia = functions
  .runWith({ timeoutSeconds: 540 })  // 9 minutes
  .pubsub.schedule(...)
```

## Future Enhancements

1. **Content Moderation**: Add AI-based content filtering
2. **Image Generation**: Use Gemini Vision for trivia images
3. **Multi-language**: Generate trivia in multiple languages
4. **User Preferences**: Personalize trivia difficulty
5. **Analytics**: Track popular categories and engagement
6. **Caching Layer**: Redis for frequently accessed data
7. **A/B Testing**: Test different AI prompts

## Contributing

When adding new functions:
1. Document the function purpose
2. Add error handling
3. Include logging
4. Test locally first
5. Update this README

## Resources

- [Firebase Functions Docs](https://firebase.google.com/docs/functions)
- [Gemini API Docs](https://ai.google.dev/docs)
- [Node.js Best Practices](https://github.com/goldbergyoni/nodebestpractices)

## Support

For issues with functions:
1. Check Firebase Console logs
2. Test locally with emulators
3. Verify API keys and permissions
4. Review function quotas
5. Open an issue on GitHub
