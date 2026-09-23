import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stagesync/models/audition_model.dart';
import 'package:stagesync/services/audition_service.dart';
import 'package:stagesync/viewmodels/auditions_viewmodel.dart';

class MockAuditionService extends Mock implements AuditionService {}

class FakeAuditionModel extends Fake implements AuditionModel {}

void main() {
  late MockAuditionService mockAuditionService;
  late AuditionsViewModel viewModel;

  setUpAll(() {
    registerFallbackValue(FakeAuditionModel());
  });

  setUp(() {
    mockAuditionService = MockAuditionService();
    viewModel = AuditionsViewModel(auditionService: mockAuditionService);
  });

  tearDown(() {
    viewModel.dispose();
  });

  group('AuditionsViewModel.createAudition Tests', () {
    test('createAudition succeeds and sets loading state', () async {
      final audition = AuditionModel(
        date: DateTime(2026, 3, 1),
        time: '10:00 AM',
        venue: 'Room 101',
        venueKey: 'room 101',
        castIds: [],
      );

      when(() => mockAuditionService.createAudition('prod_1', audition))
          .thenAnswer((_) async => 'new_id');

      final success = await viewModel.createAudition('prod_1', audition);
      expect(success, isTrue);
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.errorMessage, isNull);
    });

    test('createAudition handles error gracefully', () async {
      final audition = AuditionModel(
        date: DateTime(2026, 3, 1),
        time: '10:00 AM',
        venue: 'Room 101',
        venueKey: 'room 101',
        castIds: [],
      );

      when(() => mockAuditionService.createAudition('prod_1', audition))
          .thenThrow(Exception('Creation failed'));

      final success = await viewModel.createAudition('prod_1', audition);
      expect(success, isFalse);
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.errorMessage, contains('Failed to create audition slot'));
    });
  });

  group('AuditionsViewModel.updateAudition and deleteAudition Tests', () {
    test('updateAudition succeeds and clears errorMessage', () async {
      final audition = AuditionModel(
        id: 'aud_1',
        date: DateTime(2026, 3, 1),
        time: '10:00 AM',
        venue: 'Room 101',
        venueKey: 'room 101',
        castIds: [],
      );

      when(() => mockAuditionService.updateAudition('prod_1', audition))
          .thenAnswer((_) async {});

      final success = await viewModel.updateAudition('prod_1', audition);
      expect(success, isTrue);
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.errorMessage, isNull);
    });

    test('updateAudition handles error and sets errorMessage', () async {
      final audition = AuditionModel(
        id: 'aud_1',
        date: DateTime(2026, 3, 1),
        time: '10:00 AM',
        venue: 'Room 101',
        venueKey: 'room 101',
        castIds: [],
      );

      when(() => mockAuditionService.updateAudition('prod_1', audition))
          .thenThrow(Exception('Update error'));

      final success = await viewModel.updateAudition('prod_1', audition);
      expect(success, isFalse);
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.errorMessage, contains('Failed to update audition slot'));
    });

    test('deleteAudition succeeds and clears errorMessage', () async {
      when(() => mockAuditionService.deleteAudition('prod_1', 'aud_1'))
          .thenAnswer((_) async {});

      final success = await viewModel.deleteAudition('prod_1', 'aud_1');
      expect(success, isTrue);
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.errorMessage, isNull);
    });

    test('deleteAudition handles error and sets errorMessage', () async {
      when(() => mockAuditionService.deleteAudition('prod_1', 'aud_1'))
          .thenThrow(Exception('Delete error'));

      final success = await viewModel.deleteAudition('prod_1', 'aud_1');
      expect(success, isFalse);
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.errorMessage, contains('Failed to delete audition slot'));
    });
  });

  group('AuditionsViewModel.signUp Tests', () {
    test('signUp returns true and clears errorMessage on success', () async {
      when(() => mockAuditionService.signUp('prod_1', 'aud_1', 'cast_user_1'))
          .thenAnswer((_) async {});

      final result = await viewModel.signUp('prod_1', 'aud_1', 'cast_user_1');

      expect(result, isTrue);
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.errorMessage, isNull);
      verify(() => mockAuditionService.signUp('prod_1', 'aud_1', 'cast_user_1'))
          .called(1);
    });

    test('signUp handles service error gracefully', () async {
      when(() => mockAuditionService.signUp(any(), any(), any()))
          .thenThrow(Exception('Firestore update permission denied'));

      final result = await viewModel.signUp('prod_1', 'aud_1', 'cast_user_1');

      expect(result, isFalse);
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.errorMessage, contains('Failed to sign up for audition'));
    });
  });

  group('AuditionsViewModel.withdraw Tests', () {
    test('withdraw returns true and clears errorMessage on success', () async {
      when(() => mockAuditionService.withdraw('prod_1', 'aud_1', 'cast_user_1'))
          .thenAnswer((_) async {});

      final result =
          await viewModel.withdraw('prod_1', 'aud_1', 'cast_user_1');

      expect(result, isTrue);
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.errorMessage, isNull);
      verify(() =>
              mockAuditionService.withdraw('prod_1', 'aud_1', 'cast_user_1'))
          .called(1);
    });

    test('withdraw handles service error gracefully', () async {
      when(() => mockAuditionService.withdraw(any(), any(), any()))
          .thenThrow(Exception('Firestore update permission denied'));

      final result =
          await viewModel.withdraw('prod_1', 'aud_1', 'cast_user_1');

      expect(result, isFalse);
      expect(viewModel.isLoading, isFalse);
      expect(
          viewModel.errorMessage, contains('Failed to withdraw from audition'));
    });
  });

  group('AuditionsViewModel Lifecycle and Stream Tests', () {
    test('startWatching populates auditions and handles error', () async {
      final controller = StreamController<List<AuditionModel>>();
      when(() => mockAuditionService.watchAuditions('prod_1'))
          .thenAnswer((_) => controller.stream);

      viewModel.startWatching('prod_1');
      expect(viewModel.isLoading, isTrue);

      controller.add([
        AuditionModel(
          id: 'a1',
          date: DateTime(2026, 3, 1),
          time: 'T',
          venue: 'V',
          venueKey: 'v',
          castIds: [],
        )
      ]);
      await pumpEventQueue();

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.auditions.length, 1);

      controller.addError(Exception('Stream error'));
      await pumpEventQueue();

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.errorMessage, contains('Failed to load auditions'));

      await controller.close();
    });

    test('stopWatching cancels subscription and resets state', () async {
      final controller = StreamController<List<AuditionModel>>();
      when(() => mockAuditionService.watchAuditions('prod_1'))
          .thenAnswer((_) => controller.stream);

      viewModel.startWatching('prod_1');
      controller.add([
        AuditionModel(
          id: 'a1',
          date: DateTime(2026, 3, 1),
          time: 'T',
          venue: 'V',
          venueKey: 'v',
          castIds: [],
        )
      ]);
      await pumpEventQueue();

      expect(viewModel.auditions.isNotEmpty, isTrue);

      viewModel.stopWatching();

      expect(viewModel.auditions, isEmpty);
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.errorMessage, isNull);

      await controller.close();
    });
  });
}
