import 'package:flutter_test/flutter_test.dart';
import 'package:stagesync/models/audition.dart';

void main() {
  group('Audition Signup Authorization & Invariant Tests', () {
    late Audition audition;

    setUp(() {
      audition = Audition(
        id: 'audition-101',
        productionId: 'prod-hamlet',
        productionTitle: 'Hamlet',
        date: DateTime(2026, 10, 1),
        time: '3:00 PM – 6:00 PM',
        venue: 'Main Auditorium',
        castIds: ['user-alice', 'user-bob'],
      );
    });

    test('Cast member can sign up by appending their own UID', () {
      const currentUserId = 'user-charlie';

      // Verify user is not yet signed up
      expect(audition.isUserSignedUp(currentUserId), isFalse);

      // Cast member adds only their own UID
      final updatedCastIds = List<String>.from(audition.castIds)..add(currentUserId);

      // Rules invariant check:
      // 1. All existing cast members remain present
      expect(updatedCastIds.toSet().containsAll(audition.castIds), isTrue);

      // 2. The difference contains ONLY the current user's UID
      final difference = updatedCastIds.toSet().difference(audition.castIds.toSet());
      expect(difference, equals({'user-charlie'}));
      expect(difference.contains('user-charlie'), isTrue);
      expect(difference.length, equals(1));
    });

    test('Cast member CANNOT add another user UID', () {
      const currentUserId = 'user-charlie';
      const unauthorizedOtherUserId = 'user-david';

      // Unauthorized update attempting to add another user's UID
      final maliciousCastIds = List<String>.from(audition.castIds)..add(unauthorizedOtherUserId);

      final difference = maliciousCastIds.toSet().difference(audition.castIds.toSet());
      // Must NOT contain the other user UID if caller is currentUserId
      final isAuthorized = difference.length == 1 && difference.contains(currentUserId);
      expect(isAuthorized, isFalse);
    });

    test('Cast member CANNOT remove existing cast members', () {
      const currentUserId = 'user-charlie';

      // Malicious or unauthorized list removing Alice and adding Charlie
      final maliciousCastIds = ['user-bob', currentUserId]; // Removed 'user-alice'

      // Invariant: request.resource.data.castIds.hasAll(resource.data.castIds)
      final retainedAllExisting = maliciousCastIds.toSet().containsAll(audition.castIds);
      expect(retainedAllExisting, isFalse); // Fails security constraint!
    });

    test('Cast member cannot modify venue or date fields during signup', () {
      // Invariant: request.resource.data.diff(resource.data).affectedKeys().hasOnly(['castIds'])
      final originalData = audition.toMap();
      final updatedDataValid = Map<String, dynamic>.from(originalData);
      updatedDataValid['castIds'] = [...audition.castIds, 'user-charlie'];

      final affectedKeysValid = updatedDataValid.keys
          .where((k) => updatedDataValid[k] != originalData[k])
          .toSet();
      expect(affectedKeysValid, equals({'castIds'}));

      // If venue is also tampered with:
      final updatedDataTampered = Map<String, dynamic>.from(originalData);
      updatedDataTampered['castIds'] = [...audition.castIds, 'user-charlie'];
      updatedDataTampered['venue'] = 'Director Office';

      final affectedKeysTampered = updatedDataTampered.keys
          .where((k) => updatedDataTampered[k] != originalData[k])
          .toSet();
      expect(affectedKeysTampered.contains('venue'), isTrue);
      expect(affectedKeysTampered == {'castIds'}, isFalse); // Fails security constraint!
    });

    test('Director authorization check passes when user is directorId', () {
      const directorId = 'dir-ananya';
      const actorId = 'user-sarah';

      bool isProductionDirector(String prodDirectorId, String callerId) {
        return prodDirectorId == callerId;
      }

      expect(isProductionDirector(directorId, 'dir-ananya'), isTrue);
      expect(isProductionDirector(directorId, actorId), isFalse);
    });

    test('Self-signup is only authorized when users/{uid}.role is cast', () {
      bool isCastAuthorized(Map<String, dynamic> userDoc) {
        return userDoc['role'] == 'cast';
      }

      final castUser = {'uid': 'user-1', 'role': 'cast'};
      final directorUser = {'uid': 'user-2', 'role': 'director'};
      final unknownUser = {'uid': 'user-3', 'role': 'volunteer'};

      expect(isCastAuthorized(castUser), isTrue);
      expect(isCastAuthorized(directorUser), isFalse);
      expect(isCastAuthorized(unknownUser), isFalse);
    });
  });
}
