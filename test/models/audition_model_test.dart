import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stagesync/models/audition_model.dart';

void main() {
  group('AuditionModel Serialization, Status, and Capacity Tests', () {
    test('fromMap and toMap handle all fields correctly with status and capacity', () {
      final date = DateTime(2026, 5, 20, 10, 0);
      final model = AuditionModel(
        id: 'aud_1',
        date: date,
        time: '10:00 AM - 12:00 PM',
        venue: 'Main Stage',
        venueKey: 'main stage',
        castIds: ['user_1', 'user_2'],
        status: 'open',
        capacity: 10,
      );

      final map = model.toMap();
      expect(map['time'], '10:00 AM - 12:00 PM');
      expect(map['venue'], 'Main Stage');
      expect(map['venueKey'], 'main stage');
      expect(map['castIds'], ['user_1', 'user_2']);
      expect(map['status'], 'open');
      expect(map['capacity'], 10);

      final parsed = AuditionModel.fromMap(map, 'aud_1');
      expect(parsed.id, 'aud_1');
      expect(parsed.time, '10:00 AM - 12:00 PM');
      expect(parsed.venue, 'Main Stage');
      expect(parsed.venueKey, 'main stage');
      expect(parsed.castIds, ['user_1', 'user_2']);
      expect(parsed.status, 'open');
      expect(parsed.capacity, 10);
    });

    test('backward compatibility: missing status defaults to "open", missing capacity defaults to null', () {
      final minimalMap = {
        'date': DateTime(2026, 6, 1),
        'time': '2:00 PM',
        'venue': 'Black Box',
      };

      final parsed = AuditionModel.fromMap(minimalMap, 'aud_legacy');
      expect(parsed.status, 'open');
      expect(parsed.capacity, isNull);
      expect(parsed.castIds, isEmpty);
      expect(parsed.venueKey, 'black box');
    });

    test('capacity behavior: null capacity means no limit; isFull only true when capacity is non-null and reached', () {
      final unlimited = AuditionModel(
        date: DateTime(2026, 6, 1),
        time: '2:00 PM',
        venue: 'Studio A',
        venueKey: 'studio a',
        castIds: List.generate(50, (i) => 'user_$i'),
        capacity: null,
      );
      expect(unlimited.isFull, isFalse);
      expect(unlimited.isOpen, isTrue);

      final cappedNotFull = AuditionModel(
        date: DateTime(2026, 6, 1),
        time: '2:00 PM',
        venue: 'Studio A',
        venueKey: 'studio a',
        castIds: ['user_1', 'user_2'],
        capacity: 3,
      );
      expect(cappedNotFull.isFull, isFalse);
      expect(cappedNotFull.isOpen, isTrue);

      final cappedFull = AuditionModel(
        date: DateTime(2026, 6, 1),
        time: '2:00 PM',
        venue: 'Studio A',
        venueKey: 'studio a',
        castIds: ['user_1', 'user_2', 'user_3'],
        capacity: 3,
      );
      expect(cappedFull.isFull, isTrue);
      expect(cappedFull.isOpen, isFalse);
    });

    test('isOpen is false when status is not "open"', () {
      final closedAudition = AuditionModel(
        date: DateTime(2026, 6, 1),
        time: '2:00 PM',
        venue: 'Studio A',
        venueKey: 'studio a',
        castIds: [],
        status: 'closed',
      );
      expect(closedAudition.isOpen, isFalse);
    });

    test('fromMap coerces different date representations correctly', () {
      final date = DateTime(2026, 4, 15);
      final fromTimestamp = AuditionModel.fromMap({
        'date': Timestamp.fromDate(date),
      }, 'id_1');
      expect(fromTimestamp.date, date);

      final fromString = AuditionModel.fromMap({
        'date': '2026-04-15T00:00:00.000',
      }, 'id_2');
      expect(fromString.date, date);

      final fromMillis = AuditionModel.fromMap({
        'date': date.millisecondsSinceEpoch,
      }, 'id_3');
      expect(fromMillis.date, date);
    });

    test('copyWith updates fields while preserving existing values', () {
      final original = AuditionModel(
        id: 'aud_original',
        date: DateTime(2026, 5, 1),
        time: '1:00 PM',
        venue: 'Studio B',
        venueKey: 'studio b',
        castIds: ['user_1'],
        status: 'open',
        capacity: 5,
      );

      final updated = original.copyWith(
        venue: 'Grand Hall',
        venueKey: 'grand hall',
        status: 'closed',
        clearCapacity: true,
      );

      expect(updated.id, 'aud_original');
      expect(updated.venue, 'Grand Hall');
      expect(updated.venueKey, 'grand hall');
      expect(updated.status, 'closed');
      expect(updated.capacity, isNull);
      expect(updated.time, '1:00 PM');
    });
  });
}
