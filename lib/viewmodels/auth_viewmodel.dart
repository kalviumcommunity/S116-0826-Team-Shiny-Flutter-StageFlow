import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:stagesync/models/user_model.dart';
import 'package:stagesync/services/auth_service.dart';
import 'package:stagesync/services/user_service.dart';

class AuthViewModel extends ChangeNotifier {
  AuthViewModel({
    required AuthService authService,
    required UserService userService,
  })  : _authService = authService,
        _userService = userService {
    isLoading = true;
    _authSubscription = _authService.authStateChanges.listen((user) async {
      await _profileSubscription?.cancel();
      _profileSubscription = null;

      if (user == null) {
        currentUser = null;
        isLoading = false;
        notifyListeners();
        return;
      }

      isLoading = true;
      notifyListeners();

      try {
        final profileStream = _userService.watchUserProfile(user.uid);
        _profileSubscription = profileStream.listen((profile) {
          currentUser = profile;
          isLoading = false;
          notifyListeners();
        });
      } catch (_) {
        currentUser = null;
        isLoading = false;
        notifyListeners();
      }
    });
  }

  final AuthService _authService;
  final UserService _userService;

  StreamSubscription? _authSubscription;
  StreamSubscription? _profileSubscription;

  UserModel? currentUser;
  bool isLoading = false;
  String? errorMessage;

  @override
  void dispose() {
    _authSubscription?.cancel();
    _profileSubscription?.cancel();
    super.dispose();
  }

  Future<bool> signUp(
    String name,
    String email,
    String password,
    String role,
  ) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final credential = await _authService.signUp(
        email: email,
        password: password,
      );

      final user = UserModel(
        uid: credential.user?.uid,
        name: name,
        email: email.trim(),
        role: role,
        photoURL: credential.user?.photoURL,
        createdAt: DateTime.now(),
      );

      if (credential.user != null) {
        await _userService.createUserProfile(user);
      }

      currentUser = user;
      isLoading = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      errorMessage = e.message;
      isLoading = false;
      notifyListeners();
      return false;
    } catch (_) {
      errorMessage = 'Unable to create account. Please try again.';
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signIn(String email, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _authService.signIn(
        email: email,
        password: password,
      );
      isLoading = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      errorMessage = e.message;
      isLoading = false;
      notifyListeners();
      return false;
    } catch (_) {
      errorMessage = 'Unable to sign in. Please try again.';
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _authService.signOut();
      currentUser = null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
