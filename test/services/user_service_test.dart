// ignore_for_file: subtype_of_sealed_class

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stagesync/models/user_model.dart';
import 'package:stagesync/services/user_service.dart';

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

class MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

class MockDocumentReference extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

class MockDocumentSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {}

void main() {
  late MockFirebaseFirestore mockFirestore;
  late MockFirebaseAuth mockAuth;
  late MockUser mockUser;
  late MockCollectionReference mockUsersCollection;
  late MockDocumentReference mockUserDoc;
  late MockDocumentSnapshot mockDocSnapshot;
  late UserService userService;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockAuth = MockFirebaseAuth();
    mockUser = MockUser();
    mockUsersCollection = MockCollectionReference();
    mockUserDoc = MockDocumentReference();
    mockDocSnapshot = MockDocumentSnapshot();

    when(() => mockFirestore.collection('users')).thenReturn(mockUsersCollection);
    when(() => mockUsersCollection.doc(any())).thenReturn(mockUserDoc);
    when(() => mockUserDoc.update(any())).thenAnswer((_) async {});
    when(() => mockUserDoc.get()).thenAnswer((_) async => mockDocSnapshot);
    when(() => mockAuth.currentUser).thenReturn(mockUser);
    when(() => mockUser.uid).thenReturn('uid_123');

    userService = UserService(
      firestore: mockFirestore,
      auth: mockAuth,
    );
  });

  group('UserService.getCurrentUserProfile Tests', () {
    test('returns null when no authenticated user exists in FirebaseAuth', () async {
      when(() => mockAuth.currentUser).thenReturn(null);

      final profile = await userService.getCurrentUserProfile();

      expect(profile, isNull);
      verifyNever(() => mockUsersCollection.doc(any()));
    });

    test('fetches and returns profile when user is authenticated', () async {
      when(() => mockAuth.currentUser).thenReturn(mockUser);
      when(() => mockUser.uid).thenReturn('uid_logged_in');
      when(() => mockDocSnapshot.exists).thenReturn(true);
      when(() => mockDocSnapshot.id).thenReturn('uid_logged_in');
      when(() => mockDocSnapshot.data()).thenReturn({
        'name': 'Actor Bob',
        'email': 'bob@example.com',
        'role': 'cast',
        'createdAt': DateTime(2026, 1, 1),
      });

      final profile = await userService.getCurrentUserProfile();

      expect(profile, isNotNull);
      expect(profile?.uid, 'uid_logged_in');
      expect(profile?.name, 'Actor Bob');
      expect(profile?.role, 'cast');
      verify(() => mockUsersCollection.doc('uid_logged_in')).called(1);
    });
  });

  group('UserService.updateUserProfile Tests', () {
    test('unauthenticated user cannot update a profile', () async {
      when(() => mockAuth.currentUser).thenReturn(null);

      expect(
        () => userService.updateUserProfile(
          uid: 'uid_123',
          data: {'name': 'New Name'},
        ),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('No authenticated user'),
          ),
        ),
      );
      verifyNever(() => mockUserDoc.update(any()));
    });

    test('authenticated user cannot update another user\'s profile', () async {
      when(() => mockAuth.currentUser).thenReturn(mockUser);
      when(() => mockUser.uid).thenReturn('uid_123');

      expect(
        () => userService.updateUserProfile(
          uid: 'different_user_456',
          data: {'name': 'New Name'},
        ),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('not authorized to update another user\'s profile'),
          ),
        ),
      );
      verifyNever(() => mockUserDoc.update(any()));
    });

    test('authenticated user can update their own profile', () async {
      when(() => mockAuth.currentUser).thenReturn(mockUser);
      when(() => mockUser.uid).thenReturn('uid_123');

      await userService.updateUserProfile(
        uid: 'uid_123',
        data: {
          'name': 'Updated Name',
          'photoURL': 'https://example.com/new.png',
        },
      );

      final captured = verify(() => mockUserDoc.update(captureAny())).captured;
      expect(captured.length, 1);
      final updateMap = captured.first as Map;
      expect(updateMap['name'], 'Updated Name');
      expect(updateMap['photoURL'], 'https://example.com/new.png');
    });

    test('successfully updates allowed editable fields (name and photoURL)', () async {
      await userService.updateUserProfile(
        uid: 'uid_123',
        data: {
          'name': 'Updated Name',
          'photoURL': 'https://example.com/new.png',
        },
      );

      final captured = verify(() => mockUserDoc.update(captureAny())).captured;
      expect(captured.length, 1);
      final updateMap = captured.first as Map;
      expect(updateMap['name'], 'Updated Name');
      expect(updateMap['photoURL'], 'https://example.com/new.png');
    });

    test('rejects empty or whitespace uid with ArgumentError', () async {
      expect(
        () => userService.updateUserProfile(
          uid: '   ',
          data: {'name': 'Valid Name'},
        ),
        throwsA(isA<ArgumentError>()),
      );
      verifyNever(() => mockUserDoc.update(any()));
    });

    test('rejects empty update data with ArgumentError', () async {
      expect(
        () => userService.updateUserProfile(
          uid: 'uid_123',
          data: {},
        ),
        throwsA(isA<ArgumentError>()),
      );
      verifyNever(() => mockUserDoc.update(any()));
    });

    test('rejects protected fields (role) to prevent privilege escalation', () async {
      expect(
        () => userService.updateUserProfile(
          uid: 'uid_123',
          data: {'role': 'director'},
        ),
        throwsA(
          isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            contains('Cannot update protected field(s): role'),
          ),
        ),
      );
      verifyNever(() => mockUserDoc.update(any()));
    });

    test('rejects protected fields (email, uid, createdAt)', () async {
      expect(
        () => userService.updateUserProfile(
          uid: 'uid_123',
          data: {'email': 'hacker@example.com'},
        ),
        throwsA(isA<ArgumentError>()),
      );

      expect(
        () => userService.updateUserProfile(
          uid: 'uid_123',
          data: {'uid': 'other_uid'},
        ),
        throwsA(isA<ArgumentError>()),
      );

      expect(
        () => userService.updateUserProfile(
          uid: 'uid_123',
          data: {'createdAt': DateTime.now()},
        ),
        throwsA(isA<ArgumentError>()),
      );
      verifyNever(() => mockUserDoc.update(any()));
    });

    test('rejects empty or whitespace name string', () async {
      expect(
        () => userService.updateUserProfile(
          uid: 'uid_123',
          data: {'name': '   '},
        ),
        throwsA(isA<ArgumentError>()),
      );
      verifyNever(() => mockUserDoc.update(any()));
    });

    test('updateProfileFields forwards trimmed inputs to updateUserProfile', () async {
      await userService.updateProfileFields(
        uid: 'uid_123',
        name: '  Trimmed Name  ',
        photoURL: '  https://example.com/avatar.jpg  ',
      );

      final captured = verify(() => mockUserDoc.update(captureAny())).captured;
      expect(captured.length, 1);
      final updateMap = captured.first as Map;
      expect(updateMap['name'], 'Trimmed Name');
      expect(updateMap['photoURL'], 'https://example.com/avatar.jpg');
    });
  });
}
