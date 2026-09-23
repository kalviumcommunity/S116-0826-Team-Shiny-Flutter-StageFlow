import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';

class AuthService {
  final FirebaseAuth? _injectedAuth;
  final FirebaseFirestore? _injectedFirestore;

  AuthService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _injectedAuth = auth,
        _injectedFirestore = firestore;

  FirebaseAuth get _auth => _injectedAuth ?? FirebaseAuth.instance;
  FirebaseFirestore get _firestore => _injectedFirestore ?? FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentFirebaseUser => _auth.currentUser;

  Future<AppUser?> getCurrentUserData() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists && doc.data() != null) {
        return AppUser.fromMap(doc.data()!, doc.id);
      }
      // Fallback if doc is not yet written
      return AppUser(
        id: user.uid,
        name: user.displayName ?? user.email?.split('@').first ?? 'User',
        email: user.email ?? '',
        role: 'cast',
        photoURL: user.photoURL,
      );
    } catch (e) {
      return null;
    }
  }

  Future<AppUser> signUp({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw Exception('User registration failed: No user returned');
      }

      await firebaseUser.updateDisplayName(name.trim());

      final appUser = AppUser(
        id: firebaseUser.uid,
        name: name.trim(),
        email: email.trim().toLowerCase(),
        role: role.trim().toLowerCase(),
      );

      // Create /users/{uid} document in Firestore
      await _firestore.collection('users').doc(firebaseUser.uid).set(appUser.toMap());

      return appUser;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to create account: ${e.toString()}');
    }
  }

  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw Exception('Sign in failed: No user returned');
      }

      final doc = await _firestore.collection('users').doc(firebaseUser.uid).get();
      if (doc.exists && doc.data() != null) {
        return AppUser.fromMap(doc.data()!, doc.id);
      }

      // Default fallback
      final fallbackUser = AppUser(
        id: firebaseUser.uid,
        name: firebaseUser.displayName ?? email.split('@').first,
        email: email,
        role: 'cast',
      );
      await _firestore.collection('users').doc(firebaseUser.uid).set(fallbackUser.toMap());
      return fallbackUser;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to sign in: ${e.toString()}');
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'email-already-in-use':
        return 'This email address is already in use by another account.';
      case 'invalid-email':
        return 'The email address format is invalid.';
      case 'weak-password':
        return 'Password is too weak. Please use at least 6 characters.';
      case 'network-request-failed':
        return 'Network error: Please check your internet connection.';
      case 'too-many-requests':
        return 'Too many failed login attempts. Please try again later.';
      default:
        return e.message ?? 'Authentication error occurred. Please try again.';
    }
  }
}
