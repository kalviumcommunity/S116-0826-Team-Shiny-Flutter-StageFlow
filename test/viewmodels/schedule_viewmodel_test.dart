// ignore_for_file: subtype_of_sealed_class

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stagesync/models/event_model.dart';
import 'package:stagesync/models/production_model.dart';
import 'package:stagesync/services/event_service.dart';
import 'package:stagesync/services/production_service.dart';
import 'package:stagesync/viewmodels/schedule_viewmodel.dart';

class MockProductionService extends Mock implements ProductionService {}

class MockEventService extends Mock implements EventService {}

void main() {
  late MockProductionService mockProductionService;
  late MockEventService mockEventService;
  late ScheduleViewModel viewModel;

  setUp(() {
    mockProductionService = MockProductionService();
    mockEventService = MockEventService();
    viewModel = ScheduleViewModel(
      productionService: mockProductionService,
      eventService: mockEventService,
    );
  });

  tearDown(() {
    viewModel.dispose();
  });

  group('ScheduleViewModel Stream Error Handling Tests', () {
    test(
        'event stream error sets errorMessage, resolves isLoading, and leaves app stable',
        () async {
      final prodController = StreamController<List<ProductionModel>>();
      final eventController = StreamController<List<EventModel>>();

      when(() => mockProductionService.watchMyProductions('user_1'))
          .thenAnswer((_) => prodController.stream);
      when(() => mockEventService.watchEvents('prod_101'))
          .thenAnswer((_) => eventController.stream);

      viewModel.startWatching('user_1');
      expect(viewModel.isLoading, isTrue);

      prodController.add([
        ProductionModel(
          id: 'prod_101',
          title: 'Macbeth',
          description: 'Scottish play',
          startDate: DateTime(2026, 10, 1),
          endDate: DateTime(2026, 10, 10),
          directorId: 'dir_1',
          memberIds: ['user_1'],
          createdAt: DateTime(2026, 9, 1),
        ),
      ]);
      await pumpEventQueue();

      // Emit error on the event stream
      eventController.addError(Exception('Permission denied on events'));
      await pumpEventQueue();

      expect(viewModel.isLoading, isFalse);
      expect(
        viewModel.errorMessage,
        'Some production schedules could not be loaded.',
      );
      expect(viewModel.scheduledItems, isEmpty);

      await prodController.close();
      await eventController.close();
    });

    test(
        'event stream error on one production preserves schedules from healthy productions',
        () async {
      final prodController = StreamController<List<ProductionModel>>();
      final failingEventController = StreamController<List<EventModel>>();
      final healthyEventController = StreamController<List<EventModel>>();

      when(() => mockProductionService.watchMyProductions('user_1'))
          .thenAnswer((_) => prodController.stream);
      when(() => mockEventService.watchEvents('prod_failing'))
          .thenAnswer((_) => failingEventController.stream);
      when(() => mockEventService.watchEvents('prod_healthy'))
          .thenAnswer((_) => healthyEventController.stream);

      viewModel.startWatching('user_1');

      prodController.add([
        ProductionModel(
          id: 'prod_failing',
          title: 'Failing Production',
          description: 'A troubled production',
          startDate: DateTime(2026, 10, 1),
          endDate: DateTime(2026, 10, 10),
          directorId: 'dir_1',
          memberIds: ['user_1'],
          createdAt: DateTime(2026, 9, 1),
        ),
        ProductionModel(
          id: 'prod_healthy',
          title: 'Healthy Production',
          description: 'A smooth production',
          startDate: DateTime(2026, 10, 1),
          endDate: DateTime(2026, 10, 10),
          directorId: 'dir_2',
          memberIds: ['user_1'],
          createdAt: DateTime(2026, 9, 1),
        ),
      ]);
      await pumpEventQueue();

      // Healthy production receives events
      final testEvent = EventModel(
        id: 'event_1',
        date: DateTime(2026, 10, 5),
        start: DateTime(2026, 10, 5, 14, 0),
        end: DateTime(2026, 10, 5, 16, 0),
        type: 'Rehearsal',
        venue: 'Studio A',
        venueKey: 'studio a',
        castIds: ['user_1'],
        notes: 'Act 1 run',
      );
      healthyEventController.add([testEvent]);
      await pumpEventQueue();

      expect(viewModel.scheduledItems.length, 1);
      expect(viewModel.scheduledItems.first.productionTitle, 'Healthy Production');

      // Failing production encounters error
      failingEventController.addError(Exception('Failing stream network timeout'));
      await pumpEventQueue();

      // State handles error gracefully without clearing healthy production events
      expect(
        viewModel.errorMessage,
        'Some production schedules could not be loaded.',
      );
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.scheduledItems.length, 1);
      expect(viewModel.scheduledItems.first.event.id, 'event_1');

      await prodController.close();
      await failingEventController.close();
      await healthyEventController.close();
    });

    test('stopWatching cancels all streams and resets scheduledItems', () async {
      final prodController = StreamController<List<ProductionModel>>();
      final eventController = StreamController<List<EventModel>>();

      when(() => mockProductionService.watchMyProductions('user_1'))
          .thenAnswer((_) => prodController.stream);
      when(() => mockEventService.watchEvents('prod_101'))
          .thenAnswer((_) => eventController.stream);

      viewModel.startWatching('user_1');
      prodController.add([
        ProductionModel(
          id: 'prod_101',
          title: 'Macbeth',
          description: 'Scottish play',
          startDate: DateTime(2026, 10, 1),
          endDate: DateTime(2026, 10, 10),
          directorId: 'dir_1',
          memberIds: ['user_1'],
          createdAt: DateTime(2026, 9, 1),
        ),
      ]);
      await pumpEventQueue();

      eventController.add([
        EventModel(
          id: 'event_1',
          date: DateTime(2026, 10, 5),
          start: DateTime(2026, 10, 5, 14, 0),
          end: DateTime(2026, 10, 5, 16, 0),
          type: 'Rehearsal',
          venue: 'Studio A',
          venueKey: 'studio a',
          castIds: ['user_1'],
          notes: 'Act 1 run',
        ),
      ]);
      await pumpEventQueue();

      expect(viewModel.scheduledItems.isNotEmpty, isTrue);

      viewModel.stopWatching();

      expect(viewModel.scheduledItems, isEmpty);
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.errorMessage, isNull);

      await prodController.close();
      await eventController.close();
    });
  });
}
