import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/trivia_card.dart';
import '../utils/constants.dart';

class TriviaService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<TriviaCard> _triviaCards = [];
  bool _isLoading = false;
  DocumentSnapshot? _lastDocument;
  bool _hasMore = true;

  List<TriviaCard> get triviaCards => _triviaCards;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;

  Future<void> fetchTriviaByInterests(List<String> interests, {bool refresh = false}) async {
    if (_isLoading) return;

    if (refresh) {
      _triviaCards = [];
      _lastDocument = null;
      _hasMore = true;
    }

    if (!_hasMore) return;

    try {
      _isLoading = true;
      notifyListeners();

      Query query = _firestore
          .collection(AppConstants.triviaCollection)
          .where('category', whereIn: interests.isEmpty ? ['science'] : interests)
          .orderBy('createdAt', descending: true)
          .limit(AppConstants.triviaPerPage);

      if (_lastDocument != null) {
        query = query.startAfterDocument(_lastDocument!);
      }

      final QuerySnapshot snapshot = await query.get();

      if (snapshot.docs.isEmpty) {
        _hasMore = false;
      } else {
        _lastDocument = snapshot.docs.last;
        
        final newCards = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          return TriviaCard.fromJson(data);
        }).toList();

        _triviaCards.addAll(newCards);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      if (kDebugMode) {
        print('Error fetching trivia: $e');
      }
    }
  }

  Future<void> likeTrivia(String triviaId) async {
    try {
      await _firestore.collection(AppConstants.triviaCollection).doc(triviaId).update({
        'likes': FieldValue.increment(1),
      });

      // Update local list
      final index = _triviaCards.indexWhere((card) => card.id == triviaId);
      if (index != -1) {
        final updatedCard = _triviaCards[index];
        _triviaCards[index] = TriviaCard(
          id: updatedCard.id,
          question: updatedCard.question,
          answer: updatedCard.answer,
          imageUrl: updatedCard.imageUrl,
          category: updatedCard.category,
          tags: updatedCard.tags,
          isSponsored: updatedCard.isSponsored,
          sponsorName: updatedCard.sponsorName,
          createdAt: updatedCard.createdAt,
          likes: updatedCard.likes + 1,
          source: updatedCard.source,
        );
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error liking trivia: $e');
      }
    }
  }

  Future<void> submitTrivia({
    required String question,
    required String answer,
    required String category,
    List<String>? tags,
    String? source,
  }) async {
    try {
      await _firestore.collection(AppConstants.triviaCollection).add({
        'question': question,
        'answer': answer,
        'category': category,
        'tags': tags ?? [],
        'source': source,
        'isSponsored': false,
        'likes': 0,
        'createdAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error submitting trivia: $e');
      }
      rethrow;
    }
  }
}
