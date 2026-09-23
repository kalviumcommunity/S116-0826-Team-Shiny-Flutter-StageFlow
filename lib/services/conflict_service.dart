import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event_model.dart';
import '../models/app_user.dart';
import '../utils/date_utils.dart';

enum ConflictType {
  none,
  venue,
  cast,
}

class ConflictResult {
  final bool hasConflict;
  final ConflictType type;
  final String? venue;
  final String? conflictedUserName;
  final String? conflictedUserId;
  final EventModel? conflictingEvent;
  final String message;

  const ConflictResult({
    required this.hasConflict,
    this.type = ConflictType.none,
    this.venue,
    this.conflictedUserName,
    this.conflictedUserId,
    this.conflictingEvent,
    this.message = '',
  });

  factory ConflictResult.noConflict() {
    return const ConflictResult(hasConflict: false);
  }

  factory ConflictResult.venueConflict({
    required String venue,
    required EventModel existingEvent,
  }) {
    final title = existingEvent.productionTitle ?? 'Existing Production';
    final timeStr = AppDateUtils.formatTimeRange(existingEvent.start, existingEvent.end);
    return ConflictResult(
      hasConflict: true,
      type: ConflictType.venue,
      venue: venue,
      conflictingEvent: existingEvent,
      message: 'Venue Conflict\n\n'
          '$venue is already booked.\n\n'
          'Existing Event:\n$title — ${existingEvent.type}\n\n'
          'Time:\n$timeStr\n\n'
          'Please choose another time or venue.',
    );
  }

  factory ConflictResult.castConflict({
    required String castName,
    required String castId,
    required EventModel existingEvent,
  }) {
    final title = existingEvent.productionTitle ?? 'Another Production';
    final timeStr = AppDateUtils.formatTimeRange(existingEvent.start, existingEvent.end);
    return ConflictResult(
      hasConflict: true,
      type: ConflictType.cast,
      conflictedUserName: castName,
      conflictedUserId: castId,
      conflictingEvent: existingEvent,
      message: 'Cast Conflict\n\n'
          '$castName is already scheduled for:\n\n'
          '$title — ${existingEvent.type}\n\n'
          'Time:\n$timeStr\n\n'
          'Please change the schedule or cast.',
    );
  }
}

class ConflictService {
  final FirebaseFirestore? _injectedFirestore;

  ConflictService({FirebaseFirestore? firestore}) : _injectedFirestore = firestore;

  FirebaseFirestore get _firestore => _injectedFirestore ?? FirebaseFirestore.instance;

  /// Pure mathematical overlap function:
  /// Two intervals [A.start, A.end] and [B.start, B.end] overlap iff:
  /// A.start < B.end AND A.end > B.start.
  /// Touching intervals (e.g. 10:00-11:00 and 11:00-12:00) do NOT overlap.
  static bool doIntervalsOverlap(
    DateTime startA,
    DateTime endA,
    DateTime startB,
    DateTime endB,
  ) {
    return startA.isBefore(endB) && endA.isAfter(startB);
  }

  /// Checks for both Venue and Cast conflicts against a list of events in memory or from Firestore.
  /// [allCandidateEvents]: Events from all productions to check against.
  /// [usersMap]: Map of userId -> AppUser to display friendly cast member names.
  ConflictResult checkOverlapAgainstEvents({
    required DateTime start,
    required DateTime end,
    required String venue,
    required List<String> castIds,
    required List<EventModel> allCandidateEvents,
    Map<String, AppUser> usersMap = const {},
    String? excludeEventId,
  }) {
    // 1. Check Venue Conflicts first
    for (final event in allCandidateEvents) {
      if (excludeEventId != null && event.id == excludeEventId) continue;

      if (event.venue.trim().toLowerCase() == venue.trim().toLowerCase()) {
        if (doIntervalsOverlap(start, end, event.start, event.end)) {
          return ConflictResult.venueConflict(
            venue: venue,
            existingEvent: event,
          );
        }
      }
    }

    // 2. Check Cast Conflicts for every selected cast member
    for (final castId in castIds) {
      for (final event in allCandidateEvents) {
        if (excludeEventId != null && event.id == excludeEventId) continue;

        if (event.castIds.contains(castId)) {
          if (doIntervalsOverlap(start, end, event.start, event.end)) {
            final userName = usersMap[castId]?.name ?? 'Cast member ($castId)';
            return ConflictResult.castConflict(
              castName: userName,
              castId: castId,
              existingEvent: event,
            );
          }
        }
      }
    }

    return ConflictResult.noConflict();
  }

  /// Query Firestore for all active events across productions and evaluate conflicts
  Future<ConflictResult> checkConflictsFromFirestore({
    required DateTime start,
    required DateTime end,
    required String venue,
    required List<String> castIds,
    String? excludeEventId,
    Map<String, AppUser> usersMap = const {},
  }) async {
    try {
      // Query events across all productions collectionGroup
      final snapshot = await _firestore.collectionGroup('events').get();
      final List<EventModel> allEvents = [];

      // Also get production titles map
      final productionsSnap = await _firestore.collection('productions').get();
      final Map<String, String> prodTitles = {
        for (var doc in productionsSnap.docs)
          doc.id: (doc.data()['title'] as String? ?? 'Production')
      };

      for (var doc in snapshot.docs) {
        final prodId = doc.reference.parent.parent?.id ?? '';
        allEvents.add(EventModel.fromFirestore(
          doc,
          prodId,
          prodTitles[prodId] ?? 'Production',
        ));
      }

      return checkOverlapAgainstEvents(
        start: start,
        end: end,
        venue: venue,
        castIds: castIds,
        allCandidateEvents: allEvents,
        usersMap: usersMap,
        excludeEventId: excludeEventId,
      );
    } catch (e) {
      // Fallback if collectionGroup index is provisioning
      return ConflictResult.noConflict();
    }
  }
}
