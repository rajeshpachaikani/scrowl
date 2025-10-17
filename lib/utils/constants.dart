class AppConstants {
  // Reward Points
  static const int pointsPerLike = 1;
  static const int pointsPerSave = 2;
  static const int pointsPerSubmit = 10;
  static const int pointsPerDailyLogin = 5;

  // Pagination
  static const int triviaPerPage = 10;
  
  // Firebase Collections
  static const String usersCollection = 'users';
  static const String triviaCollection = 'trivia';
  static const String rankingsCollection = 'rankings';
  
  // Preferences Keys
  static const String onboardingCompleted = 'onboarding_completed';
  static const String userId = 'user_id';
  
  // Ranking Thresholds
  static const Map<String, int> rankThresholds = {
    'Beginner': 0,
    'Explorer': 50,
    'Scholar': 200,
    'Expert': 500,
    'Master': 1000,
    'Legend': 2500,
  };

  // Ad Frequency
  static const int sponsoredTriviaFrequency = 5; // Every 5th card
}
