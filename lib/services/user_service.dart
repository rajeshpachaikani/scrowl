import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';
import '../utils/constants.dart';

class UserService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  UserProfile? _currentUser;
  bool _isLoading = false;

  UserProfile? get currentUser => _currentUser;
  bool get isLoading => _isLoading;

  Future<void> createUser({
    required String userId,
    required String username,
    required List<String> interests,
    String? email,
  }) async {
    try {
      final user = UserProfile(
        id: userId,
        username: username,
        email: email,
        interests: interests,
        rewardPoints: 0,
        rank: 0,
        createdAt: DateTime.now(),
        lastActive: DateTime.now(),
      );

      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .set(user.toJson());

      _currentUser = user;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error creating user: $e');
      }
      rethrow;
    }
  }

  Future<void> fetchUser(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        _currentUser = UserProfile.fromJson(data);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      if (kDebugMode) {
        print('Error fetching user: $e');
      }
    }
  }

  Future<void> updateInterests(String userId, List<String> interests) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .update({'interests': interests});

      if (_currentUser != null) {
        _currentUser = _currentUser!.copyWith(interests: interests);
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating interests: $e');
      }
    }
  }

  Future<void> addRewardPoints(String userId, int points) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .update({
        'rewardPoints': FieldValue.increment(points),
      });

      if (_currentUser != null) {
        final newPoints = _currentUser!.rewardPoints + points;
        final newRank = _calculateRank(newPoints);
        _currentUser = _currentUser!.copyWith(
          rewardPoints: newPoints,
          rank: newRank,
        );
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error adding reward points: $e');
      }
    }
  }

  Future<void> likeTrivia(String userId, String triviaId) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .update({
        'likedTriviaIds': FieldValue.arrayUnion([triviaId]),
      });

      if (_currentUser != null) {
        final likedIds = List<String>.from(_currentUser!.likedTriviaIds);
        if (!likedIds.contains(triviaId)) {
          likedIds.add(triviaId);
          _currentUser = _currentUser!.copyWith(likedTriviaIds: likedIds);
          notifyListeners();
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error liking trivia: $e');
      }
    }
  }

  Future<void> saveTrivia(String userId, String triviaId) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .update({
        'savedTriviaIds': FieldValue.arrayUnion([triviaId]),
      });

      if (_currentUser != null) {
        final savedIds = List<String>.from(_currentUser!.savedTriviaIds);
        if (!savedIds.contains(triviaId)) {
          savedIds.add(triviaId);
          _currentUser = _currentUser!.copyWith(savedTriviaIds: savedIds);
          notifyListeners();
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving trivia: $e');
      }
    }
  }

  int _calculateRank(int points) {
    int rank = 0;
    for (final entry in AppConstants.rankThresholds.entries) {
      if (points >= entry.value) {
        rank++;
      }
    }
    return rank;
  }

  String getRankTitle(int points) {
    String title = 'Beginner';
    for (final entry in AppConstants.rankThresholds.entries) {
      if (points >= entry.value) {
        title = entry.key;
      }
    }
    return title;
  }
}
