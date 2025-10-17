import 'package:flutter_test/flutter_test.dart';
import 'package:scrowl/models/interest.dart';
import 'package:scrowl/models/trivia_card.dart';
import 'package:scrowl/models/user_profile.dart';
import 'package:scrowl/utils/constants.dart';

void main() {
  group('Interest Model Tests', () {
    test('Available interests should have 12 categories', () {
      expect(Interest.availableInterests.length, 12);
    });

    test('Each interest should have unique id', () {
      final ids = Interest.availableInterests.map((i) => i.id).toSet();
      expect(ids.length, Interest.availableInterests.length);
    });

    test('getCategoryColor should return valid color', () {
      final color = Interest.getCategoryColor('science');
      expect(color, isNotNull);
    });
  });

  group('TriviaCard Model Tests', () {
    test('TriviaCard should serialize to JSON and back', () {
      final now = DateTime.now();
      final trivia = TriviaCard(
        id: 'test123',
        question: 'What is Flutter?',
        answer: 'Flutter is a UI toolkit',
        category: 'technology',
        tags: ['programming', 'mobile'],
        createdAt: now,
        likes: 5,
      );

      final json = trivia.toJson();
      final recreated = TriviaCard.fromJson(json);

      expect(recreated.id, trivia.id);
      expect(recreated.question, trivia.question);
      expect(recreated.answer, trivia.answer);
      expect(recreated.category, trivia.category);
      expect(recreated.tags, trivia.tags);
      expect(recreated.likes, trivia.likes);
    });

    test('Sponsored trivia should have sponsor info', () {
      final trivia = TriviaCard(
        id: 'sponsored1',
        question: 'Test question?',
        answer: 'Test answer',
        category: 'science',
        tags: [],
        isSponsored: true,
        sponsorName: 'Test Sponsor',
        createdAt: DateTime.now(),
      );

      expect(trivia.isSponsored, true);
      expect(trivia.sponsorName, 'Test Sponsor');
    });
  });

  group('UserProfile Model Tests', () {
    test('UserProfile should serialize to JSON and back', () {
      final now = DateTime.now();
      final user = UserProfile(
        id: 'user123',
        username: 'testuser',
        email: 'test@example.com',
        interests: ['science', 'technology'],
        rewardPoints: 100,
        rank: 2,
        likedTriviaIds: ['t1', 't2'],
        savedTriviaIds: ['t3'],
        createdAt: now,
        lastActive: now,
      );

      final json = user.toJson();
      final recreated = UserProfile.fromJson(json);

      expect(recreated.id, user.id);
      expect(recreated.username, user.username);
      expect(recreated.email, user.email);
      expect(recreated.interests, user.interests);
      expect(recreated.rewardPoints, user.rewardPoints);
      expect(recreated.rank, user.rank);
    });

    test('UserProfile copyWith should update only specified fields', () {
      final user = UserProfile(
        id: 'user123',
        username: 'testuser',
        interests: ['science'],
        createdAt: DateTime.now(),
        lastActive: DateTime.now(),
      );

      final updated = user.copyWith(
        username: 'newusername',
        rewardPoints: 50,
      );

      expect(updated.username, 'newusername');
      expect(updated.rewardPoints, 50);
      expect(updated.id, user.id);
      expect(updated.interests, user.interests);
    });
  });

  group('Constants Tests', () {
    test('Reward points should be positive', () {
      expect(AppConstants.pointsPerLike, greaterThan(0));
      expect(AppConstants.pointsPerSave, greaterThan(0));
      expect(AppConstants.pointsPerSubmit, greaterThan(0));
      expect(AppConstants.pointsPerDailyLogin, greaterThan(0));
    });

    test('Rank thresholds should be in ascending order', () {
      final thresholds = AppConstants.rankThresholds.values.toList();
      for (int i = 1; i < thresholds.length; i++) {
        expect(thresholds[i], greaterThan(thresholds[i - 1]));
      }
    });

    test('Should have 6 rank levels', () {
      expect(AppConstants.rankThresholds.length, 6);
    });
  });
}
