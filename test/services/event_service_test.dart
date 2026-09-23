// ignore_for_file: subtype_of_sealed_class

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stagesync/models/event_model.dart';
import 'package:stagesync/services/event_service.dart';

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {
  late MockTransaction mockTransaction;

  @override
  Future<T> runTransaction<T>(
    TransactionHandler<T> transactionHandler, {
    Duration timeout = const Duration(seconds: 30),
    int maxAttempts = 5,
  }) async {
    return await transactionHandler(mockTransaction);
  }
}

class MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

class MockDocumentReference extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

class MockQuery extends Mock implements Query<Map<String, dynamic>> {}

class MockQuerySnapshot extends Mock
    implements QuerySnapshot<Map<String, dynamic>> {}

class MockQueryDocumentSnapshot extends Mock
    implements QueryDocumentSnapshot<Map<String, dynamic>> {}

class MockTransaction extends Mock implements Transaction {
  int setCallCount = 0;
  int updateCallCount = 0;

  @override
  Transaction set<T>(
    DocumentReference<T> documentReference,
    T data, [
    SetOptions? options,
  ]) {
    setCallCount++;
    return this;
  }

  @override
  Transaction update(
    DocumentReference<Object?> documentReference,
    Map<String, dynamic> data,
  ) {
    updateCallCount++;
    return this;
  }
}

class FakeDocumentReference extends Fake
    implements DocumentReference<Map<String, dynamic>> {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeDocumentReference());
  });

  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference mockProductionsCollection;
  late MockDocumentReference mockProductionDoc;
  late MockCollectionReference mockEventsCollection;
  late MockDocumentReference mockNewEventDoc;
  late MockTransaction mockTransaction;
  late EventService eventService;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockProductionsCollection = MockCollectionReference();
    mockProductionDoc = MockDocumentReference();
    mockEventsCollection = MockCollectionReference();
    mockNewEventDoc = MockDocumentReference();
    mockTransaction = MockTransaction();
    mockFirestore.mockTransaction = mockTransaction;

    when(() => mockFirestore.collection('productions'))
        .thenReturn(mockProductionsCollection);
    when(() => mockProductionsCollection.doc(any()))
        .thenReturn(mockProductionDoc);
    when(() => mockProductionDoc.collection('events'))
        .thenReturn(mockEventsCollection);
    when(() => mockEventsCollection.doc()).thenReturn(mockNewEventDoc);
    when(() => mockEventsCollection.doc(any())).thenReturn(mockNewEventDoc);
    when(() => mockNewEventDoc.id).thenReturn('new_event_123');

    eventService = EventService(firestore: mockFirestore);
  });

  EventModel makeEvent({
    String? id,
    required DateTime start,
    required DateTime end,
    String venue = 'Main Stage',
    String type = 'Rehearsal',
    List<String> castIds = const ['actor_1'],
    String notes = 'Test event',
  }) {
    final date = DateTime.utc(start.year, start.month, start.day);
    return EventModel(
      id: id,
      date: date,
      start: start,
      end: end,
      type: type,
      venue: venue,
      venueKey: EventModel.normalizeVenue(venue),
      castIds: castIds,
      notes: notes,
    );
  }

  void setupCandidateQueries({
    List<EventModel> venueConflicts = const [],
    List<EventModel> castConflicts = const [],
  }) {
    final mockVenueQuery1 = MockQuery();
    final mockVenueQuery2 = MockQuery();
    final mockVenueSnapshot = MockQuerySnapshot();

    when(() => mockEventsCollection.where('venueKey',
        isEqualTo: any(named: 'isEqualTo'))).thenReturn(mockVenueQuery1);
    when(() =>
            mockVenueQuery1.where('date', isEqualTo: any(named: 'isEqualTo')))
        .thenReturn(mockVenueQuery2);
    when(() => mockVenueQuery2.get())
        .thenAnswer((_) async => mockVenueSnapshot);

    final List<MockQueryDocumentSnapshot> venueDocs = [];
    for (final ev in venueConflicts) {
      final doc = MockQueryDocumentSnapshot();
      when(() => doc.id).thenReturn(ev.id ?? 'existing_venue_doc');
      when(() => doc.reference).thenReturn(mockNewEventDoc);
      when(() => doc.data()).thenReturn(ev.toMap());
      when(() => doc.exists).thenReturn(true);
      venueDocs.add(doc);

      when(() => mockTransaction.get(mockNewEventDoc))
          .thenAnswer((_) async => doc);
    }
    when(() => mockVenueSnapshot.docs).thenReturn(venueDocs);

    // Cast query mocking
    final mockCastQuery1 = MockQuery();
    final mockCastQuery2 = MockQuery();
    final mockCastSnapshot = MockQuerySnapshot();

    when(() => mockEventsCollection.where('castIds',
        arrayContains: any(named: 'arrayContains'))).thenReturn(mockCastQuery1);
    when(() => mockCastQuery1.where('date', isEqualTo: any(named: 'isEqualTo')))
        .thenReturn(mockCastQuery2);
    when(() => mockCastQuery2.get()).thenAnswer((_) async => mockCastSnapshot);

    final List<MockQueryDocumentSnapshot> castDocs = [];
    for (final ev in castConflicts) {
      final doc = MockQueryDocumentSnapshot();
      final docRef = MockDocumentReference();
      when(() => doc.id).thenReturn(ev.id ?? 'existing_cast_doc');
      when(() => doc.reference).thenReturn(docRef);
      when(() => doc.data()).thenReturn(ev.toMap());
      when(() => doc.exists).thenReturn(true);
      castDocs.add(doc);

      when(() => mockTransaction.get(docRef)).thenAnswer((_) async => doc);
    }
    when(() => mockCastSnapshot.docs).thenReturn(castDocs);
  }

  group('EventService Conflict Detection Tests', () {
    test(
        '1. Creating an event with no existing event at that venue/date succeeds',
        () async {
      setupCandidateQueries(venueConflicts: [], castConflicts: []);

      final newEvent = makeEvent(
        start: DateTime(2026, 10, 15, 14, 0),
        end: DateTime(2026, 10, 15, 16, 0),
      );

      final result = await eventService.createEvent('prod_1', newEvent);
      expect(result, 'new_event_123');
      expect(mockTransaction.setCallCount, 1);
    });

    test(
        '2. Exact venue/time overlap throws ConflictException naming the conflicting event',
        () async {
      final existingEvent = makeEvent(
        id: 'existing_1',
        start: DateTime(2026, 10, 15, 14, 0),
        end: DateTime(2026, 10, 15, 16, 0),
        venue: 'Main Stage',
        type: 'Rehearsal',
      );

      setupCandidateQueries(venueConflicts: [existingEvent]);

      final newEvent = makeEvent(
        start: DateTime(2026, 10, 15, 14, 0),
        end: DateTime(2026, 10, 15, 16, 0),
        venue: 'Main Stage',
      );

      expect(
        () => eventService.createEvent('prod_1', newEvent),
        throwsA(isA<ConflictException>().having(
          (e) => e.message,
          'message',
          allOf(contains('Venue conflict'), contains('Main Stage'),
              contains('Rehearsal')),
        )),
      );
    });

    test('3. Same time at a different venue does not conflict', () async {
      // Searching venueKey for 'Studio B' returns empty query results
      setupCandidateQueries(venueConflicts: [], castConflicts: []);

      final newEvent = makeEvent(
        start: DateTime(2026, 10, 15, 14, 0),
        end: DateTime(2026, 10, 15, 16, 0),
        venue: 'Studio B',
        castIds: ['other_actor'],
      );

      final result = await eventService.createEvent('prod_1', newEvent);
      expect(result, 'new_event_123');
    });

    test(
        '4. "Auditorium" vs " auditorium " still conflicts, proving normalization',
        () async {
      final existingEvent = makeEvent(
        id: 'aud_1',
        start: DateTime(2026, 10, 15, 10, 0),
        end: DateTime(2026, 10, 15, 12, 0),
        venue: 'Auditorium',
      );

      setupCandidateQueries(venueConflicts: [existingEvent]);

      final newEvent = makeEvent(
        start: DateTime(2026, 10, 15, 11, 0),
        end: DateTime(2026, 10, 15, 13, 0),
        venue: '  auditorium  ',
      );

      expect(
        () => eventService.createEvent('prod_1', newEvent),
        throwsA(isA<ConflictException>().having(
          (e) => e.message,
          'message',
          contains('Venue conflict'),
        )),
      );
    });

    test('5. Cast member with an overlapping event causes ConflictException',
        () async {
      final existingEvent = makeEvent(
        id: 'cast_conflict_event',
        start: DateTime(2026, 10, 15, 14, 0),
        end: DateTime(2026, 10, 15, 16, 0),
        venue: 'Studio A',
        castIds: ['actor_romeo'],
        type: 'Blocking Call',
      );

      setupCandidateQueries(
        venueConflicts: [],
        castConflicts: [existingEvent],
      );

      final newEvent = makeEvent(
        start: DateTime(2026, 10, 15, 15, 0),
        end: DateTime(2026, 10, 15, 17, 0),
        venue: 'Studio C', // different venue
        castIds: ['actor_romeo'], // same cast member!
      );

      expect(
        () => eventService.createEvent('prod_1', newEvent),
        throwsA(isA<ConflictException>().having(
          (e) => e.message,
          'message',
          contains('Cast schedule conflict'),
        )),
      );
    });

    test(
        '6. Adjacent events where A ends exactly when B starts do not conflict',
        () async {
      // Existing event: 2:00 PM to 4:00 PM
      final existingEvent = makeEvent(
        id: 'adj_1',
        start: DateTime(2026, 10, 15, 14, 0),
        end: DateTime(2026, 10, 15, 16, 0),
        venue: 'Main Stage',
      );

      setupCandidateQueries(venueConflicts: [existingEvent]);

      // New event: 4:00 PM to 6:00 PM (adjacent, exactly touching)
      final newEvent = makeEvent(
        start: DateTime(2026, 10, 15, 16, 0),
        end: DateTime(2026, 10, 15, 18, 0),
        venue: 'Main Stage',
      );

      // cand.start < new.end (14 < 18) TRUE, but cand.end > new.start (16 > 16) FALSE -> no conflict!
      final result = await eventService.createEvent('prod_1', newEvent);
      expect(result, 'new_event_123');
    });

    test(
        '7. Updating an event to its existing time does not conflict with itself',
        () async {
      final existingEvent = makeEvent(
        id: 'self_event_1',
        start: DateTime(2026, 10, 15, 14, 0),
        end: DateTime(2026, 10, 15, 16, 0),
        venue: 'Main Stage',
      );

      setupCandidateQueries(venueConflicts: [existingEvent]);

      // Updating 'self_event_1' with same time and venue
      await eventService.updateEvent('prod_1', 'self_event_1', existingEvent);

      expect(mockTransaction.updateCallCount, greaterThanOrEqualTo(1));
    });
  });
}
