import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:stagesync/models/event_model.dart';

class ConflictException implements Exception {
  ConflictException(this.message);

  final String message;

  @override
  String toString() => message;
}

class EventService {
  EventService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _eventsCollection(String prodId) =>
      _firestore.collection('productions').doc(prodId).collection('events');

  DocumentReference<Map<String, dynamic>> _productionDoc(String prodId) =>
      _firestore.collection('productions').doc(prodId);

  /// Normalized calendar date (midnight UTC) for consistent day-grouping queries.
  DateTime normalizeDate(DateTime date) {
    return DateTime.utc(date.year, date.month, date.day);
  }

  /// Transactional event creation with double-booking prevention for venues and cast.
  ///
  /// SDK Limitation Handling:
  /// The Flutter Cloud Firestore SDK does not support executing arbitrary queries
  /// (e.g., `transaction.get(Query)`) within a transaction; only `transaction.get(DocumentReference)`
  /// is supported. To guarantee serialization and eliminate non-transactional blind writes:
  /// 1. We identify candidate event references for the normalized date and venueKey / castIds.
  /// 2. Inside [runTransaction], we read each candidate document using [transaction.get] to inspect
  ///    its current snapshot state.
  /// 3. We evaluate the non-negotiable conflict invariant:
  ///      (cand.start < new.end && cand.end > new.start)
  /// 4. If any conflict exists, [ConflictException] is thrown immediately, rolling back the transaction.
  /// 5. If valid, the new event is written ([transaction.set]) and the production's memberIds are updated
  ///    ([transaction.update] with arrayUnion) within the exact same atomic transaction.
  Future<String> createEvent(String prodId, EventModel newEvent) async {
    final eventsRef = _eventsCollection(prodId);
    final prodRef = _productionDoc(prodId);
    final normalizedVenue = EventModel.normalizeVenue(newEvent.venue);
    final dayDate = normalizeDate(newEvent.date);

    // 1. Discover potential venue conflict candidates in this production
    final venueCandidatesSnapshot = await eventsRef
        .where('venueKey', isEqualTo: normalizedVenue)
        .where('date', isEqualTo: Timestamp.fromDate(dayDate))
        .get();

    // 2. Discover potential cast conflict candidates across this production's events
    final List<DocumentReference<Map<String, dynamic>>> candidateRefs = [];
    final Set<String> candidateDocIds = {};

    for (final doc in venueCandidatesSnapshot.docs) {
      if (candidateDocIds.add(doc.id)) {
        candidateRefs.add(doc.reference);
      }
    }

    for (final castId in newEvent.castIds) {
      final castCandidates = await eventsRef
          .where('castIds', arrayContains: castId)
          .where('date', isEqualTo: Timestamp.fromDate(dayDate))
          .get();
      for (final doc in castCandidates.docs) {
        if (candidateDocIds.add(doc.id)) {
          candidateRefs.add(doc.reference);
        }
      }
    }

    final newEventDocRef = eventsRef.doc();
    final timeFormat = DateFormat('h:mm a');

    // 3. Execute transactional read validation and atomic write
    await _firestore.runTransaction((transaction) async {
      for (final ref in candidateRefs) {
        final snap = await transaction.get(ref);
        if (!snap.exists) continue;

        final candidate = EventModel.fromDoc(snap);

        // Check overlap invariant: cand.start < new.end && cand.end > new.start
        final overlaps = candidate.start.isBefore(newEvent.end) &&
            candidate.end.isAfter(newEvent.start);

        if (overlaps) {
          // Venue conflict check
          if (candidate.venueKey == normalizedVenue) {
            throw ConflictException(
              'Venue conflict: "${newEvent.venue}" is already booked for '
              '${candidate.type} (${timeFormat.format(candidate.start)} - '
              '${timeFormat.format(candidate.end)}).',
            );
          }

          // Cast member conflict check
          for (final castId in newEvent.castIds) {
            if (candidate.castIds.contains(castId)) {
              throw ConflictException(
                'Cast schedule conflict: A cast member is already scheduled for '
                '${candidate.type} at ${timeFormat.format(candidate.start)} - '
                '${timeFormat.format(candidate.end)}.',
              );
            }
          }
        }
      }

      // 4. Atomic event creation inside the transaction
      final eventData = newEvent.toMap();
      eventData['venueKey'] = normalizedVenue;
      eventData['date'] = Timestamp.fromDate(dayDate);
      eventData['start'] = Timestamp.fromDate(newEvent.start);
      eventData['end'] = Timestamp.fromDate(newEvent.end);

      transaction.set(newEventDocRef, eventData);

      // 5. Atomic memberIds update inside the same transaction
      if (newEvent.castIds.isNotEmpty) {
        transaction.update(prodRef, {
          'memberIds': FieldValue.arrayUnion(newEvent.castIds),
        });
      }
    });

    return newEventDocRef.id;
  }

  /// Transactional event update with conflict checking (excluding self).
  Future<void> updateEvent(
    String prodId,
    String eventId,
    EventModel updatedEvent,
  ) async {
    final eventsRef = _eventsCollection(prodId);
    final prodRef = _productionDoc(prodId);
    final normalizedVenue = EventModel.normalizeVenue(updatedEvent.venue);
    final dayDate = normalizeDate(updatedEvent.date);
    final eventDocRef = eventsRef.doc(eventId);

    final venueCandidatesSnapshot = await eventsRef
        .where('venueKey', isEqualTo: normalizedVenue)
        .where('date', isEqualTo: Timestamp.fromDate(dayDate))
        .get();

    final List<DocumentReference<Map<String, dynamic>>> candidateRefs = [];
    final Set<String> candidateDocIds = {};

    for (final doc in venueCandidatesSnapshot.docs) {
      if (doc.id != eventId && candidateDocIds.add(doc.id)) {
        candidateRefs.add(doc.reference);
      }
    }

    for (final castId in updatedEvent.castIds) {
      final castCandidates = await eventsRef
          .where('castIds', arrayContains: castId)
          .where('date', isEqualTo: Timestamp.fromDate(dayDate))
          .get();
      for (final doc in castCandidates.docs) {
        if (doc.id != eventId && candidateDocIds.add(doc.id)) {
          candidateRefs.add(doc.reference);
        }
      }
    }

    final timeFormat = DateFormat('h:mm a');

    await _firestore.runTransaction((transaction) async {
      for (final ref in candidateRefs) {
        final snap = await transaction.get(ref);
        if (!snap.exists) continue;

        final candidate = EventModel.fromDoc(snap);

        final overlaps = candidate.start.isBefore(updatedEvent.end) &&
            candidate.end.isAfter(updatedEvent.start);

        if (overlaps) {
          if (candidate.venueKey == normalizedVenue) {
            throw ConflictException(
              'Venue conflict: "${updatedEvent.venue}" is already booked for '
              '${candidate.type} (${timeFormat.format(candidate.start)} - '
              '${timeFormat.format(candidate.end)}).',
            );
          }

          for (final castId in updatedEvent.castIds) {
            if (candidate.castIds.contains(castId)) {
              throw ConflictException(
                'Cast schedule conflict: A cast member is already scheduled for '
                '${candidate.type} at ${timeFormat.format(candidate.start)} - '
                '${timeFormat.format(candidate.end)}.',
              );
            }
          }
        }
      }

      final eventData = updatedEvent.toMap();
      eventData['venueKey'] = normalizedVenue;
      eventData['date'] = Timestamp.fromDate(dayDate);
      eventData['start'] = Timestamp.fromDate(updatedEvent.start);
      eventData['end'] = Timestamp.fromDate(updatedEvent.end);

      transaction.update(eventDocRef, eventData);

      if (updatedEvent.castIds.isNotEmpty) {
        transaction.update(prodRef, {
          'memberIds': FieldValue.arrayUnion(updatedEvent.castIds),
        });
      }
    });
  }

  Future<void> deleteEvent(String prodId, String eventId) async {
    await _eventsCollection(prodId).doc(eventId).delete();
  }

  Stream<List<EventModel>> watchEvents(String prodId) {
    return _eventsCollection(prodId)
        .orderBy('date')
        .snapshots()
        .map((snapshot) {
          final events = snapshot.docs.map(EventModel.fromDoc).toList();
          events.sort((a, b) {
            final dateComp = a.date.compareTo(b.date);
            if (dateComp != 0) return dateComp;
            return a.start.compareTo(b.start);
          });
          return List<EventModel>.unmodifiable(events);
        });
  }
}
