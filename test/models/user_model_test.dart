import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stagesync/models/user_model.dart';

void main() {
  group('UserModel Serialization and copyWith Tests', () {
    test('fromMap and toMap handle all fields correctly', () {
      final now = DateTime(2026, 1, 15, 12, 0);
      final model = UserModel(
        uid: 'user_123',
        name: 'Jane Doe',
        email: 'jane@example.com',
        role: 'cast',
        photoURL: 'https://example.com/avatar.png',
        createdAt: now,
      );

      final map = model.toMap();
      expect(map['name'], 'Jane Doe');
      expect(map['email'], 'jane@example.com');
      expect(map['role'], 'cast');
      expect(map['photoURL'], 'https://example.com/avatar.png');
      expect(map['createdAt'], now);

      final parsed = UserModel.fromMap(map, 'user_123');
      expect(parsed.uid, 'user_123');
      expect(parsed.name, 'Jane Doe');
      expect(parsed.email, 'jane@example.com');
      expect(parsed.role, 'cast');
      expect(parsed.photoURL, 'https://example.com/avatar.png');
      expect(parsed.createdAt, now);
    });

    test('fromMap uses safe fallbacks for missing/null fields', () {
      final parsed = UserModel.fromMap({}, 'fallback_uid');
      expect(parsed.uid, 'fallback_uid');
      expect(parsed.name, '');
      expect(parsed.email, '');
      expect(parsed.role, 'cast');
      expect(parsed.photoURL, isNull);
      expect(parsed.createdAt, DateTime.fromMillisecondsSinceEpoch(0));
    });

    test('fromMap coerces different date types', () {
      final date = DateTime(2026, 3, 10);
      final fromDateTime = UserModel.fromMap({'createdAt': date}, 'id_1');
      expect(fromDateTime.createdAt, date);

      final fromTimestamp = UserModel.fromMap(
        {'createdAt': Timestamp.fromDate(date)},
        'id_2',
      );
      expect(fromTimestamp.createdAt, date);

      final fromString = UserModel.fromMap(
        {'createdAt': '2026-03-10T00:00:00.000'},
        'id_3',
      );
      expect(fromString.createdAt, date);

      final fromMillis = UserModel.fromMap(
        {'createdAt': date.millisecondsSinceEpoch},
        'id_4',
      );
      expect(fromMillis.createdAt, date);
    });

    test('copyWith updates specified fields while preserving existing values', () {
      final original = UserModel(
        uid: 'user_abc',
        name: 'Original Name',
        email: 'orig@example.com',
        role: 'director',
        photoURL: 'https://example.com/old.jpg',
        createdAt: DateTime(2026, 1, 1),
      );

      final updated = original.copyWith(
        name: 'New Name',
        photoURL: 'https://example.com/new.jpg',
      );

      expect(updated.uid, 'user_abc');
      expect(updated.name, 'New Name');
      expect(updated.email, 'orig@example.com');
      expect(updated.role, 'director');
      expect(updated.photoURL, 'https://example.com/new.jpg');
      expect(updated.createdAt, DateTime(2026, 1, 1));
    });
  });
}
