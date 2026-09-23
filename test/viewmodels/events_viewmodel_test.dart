// ignore_for_file: subtype_of_sealed_class

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stagesync/models/event_model.dart';
import 'package:stagesync/services/event_service.dart';
import 'package:stagesync/viewmodels/events_viewmodel.dart';

class MockEventService extends Mock implements EventService {}

class FakeEventModel extends Fake implements EventModel {}

void main() {
  late MockEventService mockEventService;
  late EventsViewModel viewModel;

  setUpAll(() {
    registerFallbackValue(FakeEventModel());
  });

  setUp(() {
    mockEventService = MockEventService();
    viewModel = EventsViewModel(eventService: mockEventService);
  });

  tearDown(() {
    viewModel.dispose();
  });

  final sampleEvent = EventModel(
    id: 'e1',
    date: DateTime(2026, 7, 1),
    start: DateTime(2026, 7, 1, 10, 0),
    end: DateTime(2026, 7, 1, 12, 0),
    type: 'Rehearsal',
    venue: 'Stage',
    venueKey: 'stage',
    castIds: ['actor_1'],
    notes: 'Act I',
  );

  group('EventsViewModel CRUD and Conflict Handling Tests', () {
    test('createEvent succeeds and clears messages', () async {
      when(() => mockEventService.createEvent('prod_1', sampleEvent))
          .thenAnswer((_) async => 'e1');

      final success = await viewModel.createEvent('prod_1', sampleEvent);
      expect(success, isTrue);
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.errorMessage, isNull);
      expect(viewModel.conflictMessage, isNull);
    });

    test('createEvent handles ConflictException gracefully', () async {
      when(() => mockEventService.createEvent('prod_1', sampleEvent))
          .thenThrow(ConflictException('Venue already booked.'));

      final success = await viewModel.createEvent('prod_1', sampleEvent);
      expect(success, isFalse);
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.conflictMessage, 'Venue already booked.');
      expect(viewModel.errorMessage, isNull);
    });

    test('createEvent handles generic error gracefully', () async {
      when(() => mockEventService.createEvent('prod_1', sampleEvent))
          .thenThrow(Exception('Network error'));

      final success = await viewModel.createEvent('prod_1', sampleEvent);
      expect(success, isFalse);
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.errorMessage, contains('Failed to create event'));
    });

    test('updateEvent succeeds and clears messages', () async {
      when(() => mockEventService.updateEvent('prod_1', 'e1', sampleEvent))
          .thenAnswer((_) async {});

      final success = await viewModel.updateEvent('prod_1', 'e1', sampleEvent);
      expect(success, isTrue);
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.errorMessage, isNull);
      expect(viewModel.conflictMessage, isNull);
    });

    test('updateEvent handles ConflictException gracefully', () async {
      when(() => mockEventService.updateEvent('prod_1', 'e1', sampleEvent))
          .thenThrow(ConflictException('Cast member conflict.'));

      final success = await viewModel.updateEvent('prod_1', 'e1', sampleEvent);
      expect(success, isFalse);
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.conflictMessage, 'Cast member conflict.');
      expect(viewModel.errorMessage, isNull);
    });

    test('deleteEvent succeeds and handles errors', () async {
      when(() => mockEventService.deleteEvent('prod_1', 'e1'))
          .thenAnswer((_) async {});

      expect(await viewModel.deleteEvent('prod_1', 'e1'), isTrue);

      when(() => mockEventService.deleteEvent('prod_1', 'e1'))
          .thenThrow(Exception('Delete failed'));
      expect(await viewModel.deleteEvent('prod_1', 'e1'), isFalse);
      expect(viewModel.errorMessage, contains('Failed to delete event'));
    });

    test('clearMessages clears errorMessage and conflictMessage', () {
      viewModel.clearMessages();
      expect(viewModel.errorMessage, isNull);
      expect(viewModel.conflictMessage, isNull);
    });
  });

  group('EventsViewModel Lifecycle and Stream Tests', () {
    test('startWatching updates events and handles error', () async {
      final controller = StreamController<List<EventModel>>();
      when(() => mockEventService.watchEvents('prod_1'))
          .thenAnswer((_) => controller.stream);

      viewModel.startWatching('prod_1');
      expect(viewModel.isLoading, isTrue);

      controller.add([sampleEvent]);
      await pumpEventQueue();

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.events.length, 1);

      controller.addError(Exception('Stream error'));
      await pumpEventQueue();

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.errorMessage, contains('Failed to load events'));

      await controller.close();
    });

    test('stopWatching cancels subscription and resets state', () async {
      final controller = StreamController<List<EventModel>>();
      when(() => mockEventService.watchEvents('prod_1'))
          .thenAnswer((_) => controller.stream);

      viewModel.startWatching('prod_1');
      controller.add([sampleEvent]);
      await pumpEventQueue();

      expect(viewModel.events.isNotEmpty, isTrue);

      viewModel.stopWatching();

      expect(viewModel.events, isEmpty);
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.errorMessage, isNull);
      expect(viewModel.conflictMessage, isNull);

      await controller.close();
    });
  });
}
