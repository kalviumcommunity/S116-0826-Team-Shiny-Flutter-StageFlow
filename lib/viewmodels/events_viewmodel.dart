import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:stagesync/models/event_model.dart';
import 'package:stagesync/services/event_service.dart';

class EventsViewModel extends ChangeNotifier {
  EventsViewModel({
    required EventService eventService,
  }) : _eventService = eventService;

  final EventService _eventService;
  StreamSubscription<List<EventModel>>? _eventsSubscription;

  List<EventModel> events = const <EventModel>[];
  bool isLoading = false;
  String? errorMessage;
  String? conflictMessage;

  void startWatching(String prodId) {
    _eventsSubscription?.cancel();
    isLoading = true;
    errorMessage = null;
    conflictMessage = null;
    notifyListeners();

    _eventsSubscription = _eventService.watchEvents(prodId).listen(
      (data) {
        events = data;
        isLoading = false;
        errorMessage = null;
        notifyListeners();
      },
      onError: (Object error) {
        isLoading = false;
        errorMessage = 'Failed to load events: $error';
        notifyListeners();
      },
    );
  }

  void clearMessages() {
    errorMessage = null;
    conflictMessage = null;
    notifyListeners();
  }

  Future<bool> createEvent(String prodId, EventModel newEvent) async {
    isLoading = true;
    errorMessage = null;
    conflictMessage = null;
    notifyListeners();

    try {
      await _eventService.createEvent(prodId, newEvent);
      isLoading = false;
      notifyListeners();
      return true;
    } on ConflictException catch (e) {
      conflictMessage = e.message;
      isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      errorMessage = 'Failed to create event: $e';
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateEvent(
    String prodId,
    String eventId,
    EventModel updatedEvent,
  ) async {
    isLoading = true;
    errorMessage = null;
    conflictMessage = null;
    notifyListeners();

    try {
      await _eventService.updateEvent(prodId, eventId, updatedEvent);
      isLoading = false;
      notifyListeners();
      return true;
    } on ConflictException catch (e) {
      conflictMessage = e.message;
      isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      errorMessage = 'Failed to update event: $e';
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteEvent(String prodId, String eventId) async {
    isLoading = true;
    errorMessage = null;
    conflictMessage = null;
    notifyListeners();

    try {
      await _eventService.deleteEvent(prodId, eventId);
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = 'Failed to delete event: $e';
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _eventsSubscription?.cancel();
    super.dispose();
  }
}
