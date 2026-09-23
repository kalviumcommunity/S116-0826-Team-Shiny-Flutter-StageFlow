import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:stagesync/models/event_model.dart';
import 'package:stagesync/models/production_model.dart';
import 'package:stagesync/services/event_service.dart';
import 'package:stagesync/services/production_service.dart';

class GlobalScheduleItem {
  final String prodId;
  final String productionTitle;
  final EventModel event;

  GlobalScheduleItem({
    required this.prodId,
    required this.productionTitle,
    required this.event,
  });
}

class ScheduleViewModel extends ChangeNotifier {
  ScheduleViewModel({
    required ProductionService productionService,
    required EventService eventService,
  })  : _productionService = productionService,
        _eventService = eventService;

  final ProductionService _productionService;
  final EventService _eventService;

  StreamSubscription<List<ProductionModel>>? _productionsSubscription;
  final Map<String, StreamSubscription<List<EventModel>>> _eventSubscriptions =
      {};
  final Map<String, List<EventModel>> _eventsByProduction = {};
  final Map<String, String> _productionTitles = {};

  List<GlobalScheduleItem> scheduledItems = const [];
  bool isLoading = false;
  String? errorMessage;

  void startWatching(String uid) {
    _cleanup();
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    _productionsSubscription =
        _productionService.watchMyProductions(uid).listen(
      (productions) {
        _syncEventStreams(productions);
      },
      onError: (Object error) {
        isLoading = false;
        errorMessage = 'Failed to load user productions: $error';
        notifyListeners();
      },
    );
  }

  void _syncEventStreams(List<ProductionModel> productions) {
    final activeProdIds =
        productions.map((p) => p.id).whereType<String>().toSet();

    // Cancel subscriptions for productions user is no longer in
    final removed = _eventSubscriptions.keys
        .where((id) => !activeProdIds.contains(id))
        .toList();
    for (final id in removed) {
      _eventSubscriptions[id]?.cancel();
      _eventSubscriptions.remove(id);
      _eventsByProduction.remove(id);
      _productionTitles.remove(id);
    }

    // Subscribe to new productions
    for (final prod in productions) {
      if (prod.id == null) continue;
      final prodId = prod.id!;
      _productionTitles[prodId] = prod.title;

      if (!_eventSubscriptions.containsKey(prodId)) {
        _eventSubscriptions[prodId] =
            _eventService.watchEvents(prodId).listen(
          (events) {
            _eventsByProduction[prodId] = events;
            _recomputeScheduledItems();
          },
          onError: (Object err) {
            debugPrint('Error loading events for $prodId: $err');
            errorMessage = 'Some production schedules could not be loaded.';
            _eventsByProduction.remove(prodId);
            _recomputeScheduledItems();
          },
        );
      }
    }

    if (productions.isEmpty) {
      isLoading = false;
      scheduledItems = const [];
      notifyListeners();
    }
  }

  void _recomputeScheduledItems() {
    final List<GlobalScheduleItem> merged = [];

    for (final entry in _eventsByProduction.entries) {
      final prodId = entry.key;
      final title = _productionTitles[prodId] ?? 'Production';
      for (final event in entry.value) {
        merged.add(
          GlobalScheduleItem(
            prodId: prodId,
            productionTitle: title,
            event: event,
          ),
        );
      }
    }

    // Sort chronologically: by date, then start
    merged.sort((a, b) {
      final dateComp = a.event.date.compareTo(b.event.date);
      if (dateComp != 0) return dateComp;
      return a.event.start.compareTo(b.event.start);
    });

    scheduledItems = merged;
    isLoading = false;
    notifyListeners();
  }

  void _cleanup() {
    _productionsSubscription?.cancel();
    _productionsSubscription = null;
    for (final sub in _eventSubscriptions.values) {
      sub.cancel();
    }
    _eventSubscriptions.clear();
    _eventsByProduction.clear();
    _productionTitles.clear();
  }

  void stopWatching() {
    _cleanup();
    scheduledItems = const [];
    isLoading = false;
    errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    stopWatching();
    super.dispose();
  }
}
