// ignore_for_file: subtype_of_sealed_class

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stagesync/models/user_model.dart';
import 'package:stagesync/services/auth_service.dart';
import 'package:stagesync/services/user_service.dart';
import 'package:stagesync/viewmodels/auth_viewmodel.dart';

class MockAuthService extends Mock implements AuthService {}

class MockUserService extends Mock implements UserService {}

class MockUserCredential extends Mock implements UserCredential {}

class MockUser extends Mock implements User {}

class FakeUserModel extends Fake implements UserModel {}

void main() {
  late MockAuthService mockAuthService;
  late MockUserService mockUserService;
  late MockUserCredential mockCredential;
  late MockUser mockUser;
  late StreamController<User?> authStateController;

  setUpAll(() {
    registerFallbackValue(FakeUserModel());
  });

  setUp(() {
    mockAuthService = MockAuthService();
    mockUserService = MockUserService();
    mockCredential = MockUserCredential();
    mockUser = MockUser();
    authStateController = StreamController<User?>.broadcast();

    when(() => mockAuthService.authStateChanges)
        .thenAnswer((_) => authStateController.stream);
    when(() => mockCredential.user).thenReturn(mockUser);
    when(() => mockUser.uid).thenReturn('new_auth_uid_123');
    when(() => mockUser.photoURL).thenReturn(null);
  });

  tearDown(() {
    authStateController.close();
  });

  group('AuthViewModel Signup Rollback Tests', () {
    test(
        'signUp rolls back (deletes) newly created Firebase Auth account if Firestore profile creation fails',
        () async {
      when(() => mockAuthService.signUp(
            email: 'cast@example.com',
            password: 'Password123!',
          )).thenAnswer((_) async => mockCredential);

      when(() => mockUserService.createUserProfile(any()))
          .thenThrow(Exception('Firestore write blocked'));

      when(() => mockAuthService.deleteCurrentUser())
          .thenAnswer((_) async {});

      final viewModel = AuthViewModel(
        authService: mockAuthService,
        userService: mockUserService,
      );

      final result = await viewModel.signUp(
        'Cast Member',
        'cast@example.com',
        'Password123!',
        'cast',
      );

      expect(result, isFalse);
      expect(viewModel.currentUser, isNull);
      expect(viewModel.isLoading, isFalse);
      expect(
        viewModel.errorMessage,
        'Account setup could not be completed. Please try again.',
      );

      // Verify that the rollback was triggered to delete the orphan Auth account
      verify(() => mockAuthService.deleteCurrentUser()).called(1);
    });

    test(
        'signUp rollback failure does not crash the app and returns user-friendly error',
        () async {
      when(() => mockAuthService.signUp(
            email: 'director@example.com',
            password: 'Password123!',
          )).thenAnswer((_) async => mockCredential);

      when(() => mockUserService.createUserProfile(any()))
          .thenThrow(Exception('Firestore write blocked'));

      // If deleteCurrentUser also fails (e.g. network partition)
      when(() => mockAuthService.deleteCurrentUser())
          .thenThrow(Exception('Network timeout during auth deletion'));

      final viewModel = AuthViewModel(
        authService: mockAuthService,
        userService: mockUserService,
      );

      final result = await viewModel.signUp(
        'Director',
        'director@example.com',
        'Password123!',
        'director',
      );

      expect(result, isFalse);
      expect(viewModel.currentUser, isNull);
      expect(viewModel.isLoading, isFalse);
      expect(
        viewModel.errorMessage,
        'Account setup could not be completed. Please try again.',
      );
      verify(() => mockAuthService.deleteCurrentUser()).called(1);
    });

    test('signUp preserves AuthException when auth service fails', () async {
      when(() => mockAuthService.signUp(
            email: 'duplicate@example.com',
            password: 'Password123!',
          )).thenThrow(
        AuthException('This email is already registered. Please sign in instead.'),
      );

      final viewModel = AuthViewModel(
        authService: mockAuthService,
        userService: mockUserService,
      );

      final result = await viewModel.signUp(
        'Existing User',
        'duplicate@example.com',
        'Password123!',
        'cast',
      );

      expect(result, isFalse);
      expect(viewModel.currentUser, isNull);
      expect(
        viewModel.errorMessage,
        'This email is already registered. Please sign in instead.',
      );
      verifyNever(() => mockUserService.createUserProfile(any()));
      verifyNever(() => mockAuthService.deleteCurrentUser());
    });
  });

  group('AuthViewModel Profile Stream Error Tests', () {
    test(
        'watchUserProfile stream error sets errorMessage, resolves loading state, and nulls currentUser',
        () async {
      final profileController = StreamController<UserModel?>();

      when(() => mockUserService.watchUserProfile('new_auth_uid_123'))
          .thenAnswer((_) => profileController.stream);

      final viewModel = AuthViewModel(
        authService: mockAuthService,
        userService: mockUserService,
      );

      // Trigger auth state change to signed in
      authStateController.add(mockUser);
      await pumpEventQueue();

      expect(viewModel.isLoading, isTrue);

      // Emit stream error
      profileController.addError(Exception('Profile stream permission denied'));
      await pumpEventQueue();

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.currentUser, isNull);
      expect(
        viewModel.errorMessage,
        'Failed to load user profile. Please check your connection.',
      );

      await profileController.close();
      viewModel.dispose();
    });

    test('signOut cancels profile subscription and clears state', () async {
      final profileController = StreamController<UserModel?>();

      when(() => mockUserService.watchUserProfile('new_auth_uid_123'))
          .thenAnswer((_) => profileController.stream);
      when(() => mockAuthService.signOut()).thenAnswer((_) async {});

      final viewModel = AuthViewModel(
        authService: mockAuthService,
        userService: mockUserService,
      );

      authStateController.add(mockUser);
      await pumpEventQueue();

      profileController.add(UserModel(
        uid: 'new_auth_uid_123',
        name: 'Cast Member',
        email: 'cast@example.com',
        role: 'cast',
        createdAt: DateTime(2026, 1, 1),
      ));
      await pumpEventQueue();

      expect(viewModel.currentUser?.name, 'Cast Member');

      await viewModel.signOut();

      expect(viewModel.currentUser, isNull);
      expect(viewModel.isLoading, isFalse);
      verify(() => mockAuthService.signOut()).called(1);

      await profileController.close();
      viewModel.dispose();
    });
  });
}
