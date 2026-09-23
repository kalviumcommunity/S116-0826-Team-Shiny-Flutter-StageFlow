import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/event_model.dart';
import '../models/app_user.dart';
import '../services/firestore_service.dart';
import '../services/conflict_service.dart';

class ScheduleProvider extends ChangeNotifier {
  final FirestoreService _firestoreService;
  final ConflictService _conflictService;

  List<EventModel> _allEvents = [];
  String _activeFilter = 'all'; // 'all', 'rehearsals', 'auditions', 'performances'
  bool _isLoading = false;
  bool _isCheckingConflicts = false;
  ConflictResult? _lastConflictResult;
  String? _errorMessage;

  StreamSubscription? _eventsSub;

  ScheduleProvider({
    FirestoreService? firestoreService,
    ConflictService? conflictService,
  })  : _firestoreService = firestoreService ?? FirestoreService(),
        _conflictService = conflictService ?? ConflictService() {
    _init();
  }

  List<EventModel> get allEvents => _allEvents;
  String get activeFilter => _activeFilter;
  bool get isLoading => _isLoading;
  bool get isCheckingConflicts => _isCheckingConflicts;
  ConflictResult? get lastConflictResult => _lastConflictResult;
  String? get errorMessage => _errorMessage;

  void _init() {
    _eventsSub = _firestoreService.getAllEventsStream().listen((events) {
      events.sort((a, b) => a.start.compareTo(b.start));
      _allEvents = events;
      notifyListeners();
    }, onError: (err) {
      _errorMessage = err.toString();
      notifyListeners();
    });
  }

  void setFilter(String filter) {
    _activeFilter = filter.toLowerCase();
    notifyListeners();
  }

  List<EventModel> getFilteredEvents({String? castUserId}) {
    var list = _allEvents;

    // Filter by cast relevance if cast user
    if (castUserId != null && castUserId.isNotEmpty) {
      list = list.where((e) => e.castIds.contains(castUserId)).toList();
    }

    if (_activeFilter == 'all') {
      return list;
    } else if (_activeFilter == 'rehearsals') {
      return list.where((e) => e.isRehearsal).toList();
    } else if (_activeFilter == 'auditions') {
      return list.where((e) => e.isAudition).toList();
    } else if (_activeFilter == 'performances') {
      return list.where((e) => e.isPerformance).toList();
    }
    return list;
  }

  /// Verifies conflicts and creates event if clear.
  /// Returns null if successfully saved, or [ConflictResult] if blocked by a conflict.
  Future<ConflictResult?> createEventWithConflictCheck({
    required EventModel event,
    required Map<String, AppUser> usersMap,
  }) async {
    try {
      _isCheckingConflicts = true;
      _lastConflictResult = null;
      _errorMessage = null;
      notifyListeners();

      // 1. Check live Firestore events across all productions via collectionGroup
      final firestoreConflict = await _conflictService.checkConflictsFromFirestore(
        start: event.start,
        end: event.end,
        venue: event.venue,
        castIds: event.castIds,
        excludeEventId: null,
        usersMap: usersMap,
      );

      if (firestoreConflict.hasConflict) {
        _lastConflictResult = firestoreConflict;
        _isCheckingConflicts = false;
        notifyListeners();
        return firestoreConflict; // BLOCKED
      }

      // 2. Also check against current in-memory stream events
      final streamConflict = _conflictService.checkOverlapAgainstEvents(
        start: event.start,
        end: event.end,
        venue: event.venue,
        castIds: event.castIds,
        allCandidateEvents: _allEvents,
        usersMap: usersMap,
        excludeEventId: null,
      );

      if (streamConflict.hasConflict) {
        _lastConflictResult = streamConflict;
        _isCheckingConflicts = false;
        notifyListeners();
        return streamConflict; // BLOCKED
      }

      // No conflict: save to Firestore
      await _firestoreService.createEvent(event);

      _isCheckingConflicts = false;
      notifyListeners();
      return null;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isCheckingConflicts = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Verifies conflicts and updates event if clear.
  Future<ConflictResult?> updateEventWithConflictCheck({
    required EventModel event,
    required Map<String, AppUser> usersMap,
  }) async {
    try {
      _isCheckingConflicts = true;
      _lastConflictResult = null;
      _errorMessage = null;
      notifyListeners();

      // 1. Check live Firestore events across all productions, excluding current event ID
      final firestoreConflict = await _conflictService.checkConflictsFromFirestore(
        start: event.start,
        end: event.end,
        venue: event.venue,
        castIds: event.castIds,
        excludeEventId: event.id,
        usersMap: usersMap,
      );

      if (firestoreConflict.hasConflict) {
        _lastConflictResult = firestoreConflict;
        _isCheckingConflicts = false;
        notifyListeners();
        return firestoreConflict; // BLOCKED
      }

      // 2. Also check against in-memory stream events, excluding current event ID
      final streamConflict = _conflictService.checkOverlapAgainstEvents(
        start: event.start,
        end: event.end,
        venue: event.venue,
        castIds: event.castIds,
        allCandidateEvents: _allEvents,
        usersMap: usersMap,
        excludeEventId: event.id,
      );

      if (streamConflict.hasConflict) {
        _lastConflictResult = streamConflict;
        _isCheckingConflicts = false;
        notifyListeners();
        return streamConflict; // BLOCKED
      }

      await _firestoreService.updateEvent(event);

      _isCheckingConflicts = false;
      notifyListeners();
      return null;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isCheckingConflicts = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteEvent(String productionId, String eventId) async {
    await _firestoreService.deleteEvent(productionId, eventId);
  }

  @override
  void dispose() {
    _eventsSub?.cancel();
    super.dispose();
  }
}
