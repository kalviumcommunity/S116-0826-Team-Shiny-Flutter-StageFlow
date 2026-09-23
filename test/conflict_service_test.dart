import 'package:flutter_test/flutter_test.dart';
import 'package:stagesync/services/conflict_service.dart';
import 'package:stagesync/models/event_model.dart';
import 'package:stagesync/models/app_user.dart';

void main() {
  group('ConflictService — Interval Overlap Math', () {
    test('Overlapping intervals are correctly identified', () {
      // Event A: 10:00 - 12:00
      final startA = DateTime(2026, 9, 22, 10, 0);
      final endA = DateTime(2026, 9, 22, 12, 0);

      // Event B: 11:00 - 13:00 (overlaps with A)
      final startB = DateTime(2026, 9, 22, 11, 0);
      final endB = DateTime(2026, 9, 22, 13, 0);

      expect(ConflictService.doIntervalsOverlap(startA, endA, startB, endB), isTrue);
      expect(ConflictService.doIntervalsOverlap(startB, endB, startA, endA), isTrue);
    });

    test('Adjacent events touching at boundary do NOT overlap (e.g. 10-11 and 11-12)', () {
      // Event A: 10:00 - 11:00
      final startA = DateTime(2026, 9, 22, 10, 0);
      final endA = DateTime(2026, 9, 22, 11, 0);

      // Event B: 11:00 - 12:00
      final startB = DateTime(2026, 9, 22, 11, 0);
      final endB = DateTime(2026, 9, 22, 12, 0);

      expect(ConflictService.doIntervalsOverlap(startA, endA, startB, endB), isFalse);
      expect(ConflictService.doIntervalsOverlap(startB, endB, startA, endA), isFalse);
    });

    test('Completely separate intervals do NOT overlap', () {
      final startA = DateTime(2026, 9, 22, 9, 0);
      final endA = DateTime(2026, 9, 22, 10, 0);

      final startB = DateTime(2026, 9, 22, 14, 0);
      final endB = DateTime(2026, 9, 22, 16, 0);

      expect(ConflictService.doIntervalsOverlap(startA, endA, startB, endB), isFalse);
    });

    test('Contained interval inside another is identified as overlapping', () {
      final startA = DateTime(2026, 9, 22, 10, 0);
      final endA = DateTime(2026, 9, 22, 14, 0);

      final startB = DateTime(2026, 9, 22, 11, 0);
      final endB = DateTime(2026, 9, 22, 12, 0);

      expect(ConflictService.doIntervalsOverlap(startA, endA, startB, endB), isTrue);
    });
  });

  group('ConflictService — Venue & Cast Overlap Checks', () {
    late ConflictService conflictService;
    late EventModel existingHamletRehearsal;
    late Map<String, AppUser> usersMap;

    setUp(() {
      conflictService = ConflictService();

      existingHamletRehearsal = EventModel(
        id: 'event-1',
        productionId: 'prod-hamlet',
        productionTitle: 'Hamlet',
        date: DateTime(2026, 9, 22),
        start: DateTime(2026, 9, 22, 18, 0), // 6:00 PM
        end: DateTime(2026, 9, 22, 20, 0),   // 8:00 PM
        type: 'Rehearsal',
        venue: 'Main Auditorium',
        castIds: ['user-sarah', 'user-john'],
        notes: 'Act 1 blocking',
      );

      usersMap = {
        'user-sarah': const AppUser(id: 'user-sarah', name: 'Sarah', email: 'sarah@example.com', role: 'cast'),
        'user-john': const AppUser(id: 'user-john', name: 'John', email: 'john@example.com', role: 'cast'),
        'user-michael': const AppUser(id: 'user-michael', name: 'Michael', email: 'michael@example.com', role: 'cast'),
      };
    });

    test('Blocks when same venue overlaps in time (Venue Conflict)', () {
      final result = conflictService.checkOverlapAgainstEvents(
        start: DateTime(2026, 9, 22, 19, 0), // 7:00 PM - 9:00 PM
        end: DateTime(2026, 9, 22, 21, 0),
        venue: 'Main Auditorium',
        castIds: ['user-michael'], // Different cast, but SAME venue
        allCandidateEvents: [existingHamletRehearsal],
        usersMap: usersMap,
      );

      expect(result.hasConflict, isTrue);
      expect(result.type, equals(ConflictType.venue));
      expect(result.venue, equals('Main Auditorium'));
      expect(result.message, contains('Main Auditorium is already booked'));
    });

    test('Allows event at different venue at the same time if cast does not overlap', () {
      final result = conflictService.checkOverlapAgainstEvents(
        start: DateTime(2026, 9, 22, 18, 0),
        end: DateTime(2026, 9, 22, 20, 0),
        venue: 'Black Box Studio', // DIFFERENT venue
        castIds: ['user-michael'], // DIFFERENT cast
        allCandidateEvents: [existingHamletRehearsal],
        usersMap: usersMap,
      );

      expect(result.hasConflict, isFalse);
      expect(result.type, equals(ConflictType.none));
    });

    test('Blocks when same cast member is double-booked across different venues (Cast Conflict)', () {
      final result = conflictService.checkOverlapAgainstEvents(
        start: DateTime(2026, 9, 22, 19, 0), // 7:00 PM - 9:00 PM (overlaps 6-8 PM)
        end: DateTime(2026, 9, 22, 21, 0),
        venue: 'Room 201', // Different venue
        castIds: ['user-sarah'], // SARAH is in Hamlet 6-8 PM!
        allCandidateEvents: [existingHamletRehearsal],
        usersMap: usersMap,
      );

      expect(result.hasConflict, isTrue);
      expect(result.type, equals(ConflictType.cast));
      expect(result.conflictedUserName, equals('Sarah'));
      expect(result.message, contains('Sarah is already scheduled'));
    });

    test('Ignores self when updating an existing event (excludeEventId)', () {
      final result = conflictService.checkOverlapAgainstEvents(
        start: DateTime(2026, 9, 22, 18, 0),
        end: DateTime(2026, 9, 22, 20, 0),
        venue: 'Main Auditorium',
        castIds: ['user-sarah'],
        allCandidateEvents: [existingHamletRehearsal],
        usersMap: usersMap,
        excludeEventId: 'event-1', // Editing Hamlet itself
      );

      expect(result.hasConflict, isFalse);
    });
  });
}
