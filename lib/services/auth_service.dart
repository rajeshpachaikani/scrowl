import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  bool _isLoading = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  AuthService() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<bool> signInAnonymously() async {
    try {
      _isLoading = true;
      notifyListeners();

      final UserCredential result = await _auth.signInAnonymously();
      _user = result.user;

      if (_user != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConstants.userId, _user!.uid);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      if (kDebugMode) {
        print('Error signing in: $e');
      }
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.userId);
      _user = null;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error signing out: $e');
      }
    }
  }

  Future<String?> getCurrentUserId() async {
    if (_user != null) {
      return _user!.uid;
    }
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.userId);
  }
}
