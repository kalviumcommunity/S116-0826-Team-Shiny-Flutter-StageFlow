// ignore_for_file: subtype_of_sealed_class

import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stagesync/models/production_model.dart';
import 'package:stagesync/services/production_service.dart';
import 'package:stagesync/services/storage_service.dart';
import 'package:stagesync/viewmodels/productions_viewmodel.dart';

class MockProductionService extends Mock implements ProductionService {}

class MockStorageService extends Mock implements StorageService {}

class FakeProductionModel extends Fake implements ProductionModel {}

void main() {
  late MockProductionService mockProductionService;
  late MockStorageService mockStorageService;
  late ProductionsViewModel viewModel;

  setUpAll(() {
    registerFallbackValue(FakeProductionModel());
    registerFallbackValue(File(''));
  });

  setUp(() {
    mockProductionService = MockProductionService();
    mockStorageService = MockStorageService();
    viewModel = ProductionsViewModel(
      productionService: mockProductionService,
      storageService: mockStorageService,
    );
  });

  tearDown(() {
    viewModel.dispose();
  });

  group('ProductionsViewModel Tests', () {
    test('createProduction succeeds without poster and creates document',
        () async {
      when(() => mockProductionService.createProduction(any()))
          .thenAnswer((_) async => 'new_prod_id_123');

      final success = await viewModel.createProduction(
        title: 'The Crucible',
        description: 'Drama',
        startDate: DateTime(2026, 10, 1),
        endDate: DateTime(2026, 10, 15),
        directorId: 'director_456',
        posterFile: null,
      );

      expect(success, isTrue);
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.errorMessage, isNull);
      verify(() => mockProductionService.createProduction(any())).called(1);
      verifyNever(() => mockStorageService.uploadProductionPoster(any(), any()));
    });

    test(
        'createProduction succeeds with posterFile when StorageService returns null',
        () async {
      when(() => mockProductionService.createProduction(any()))
          .thenAnswer((_) async => 'new_prod_id_456');
      when(() => mockStorageService.uploadProductionPoster(any(), any()))
          .thenAnswer((_) async => null);

      final success = await viewModel.createProduction(
        title: 'Hamlet',
        description: 'Tragedy',
        startDate: DateTime(2026, 11, 1),
        endDate: DateTime(2026, 11, 20),
        directorId: 'director_456',
        posterFile: File('dummy_path.jpg'),
      );

      expect(success, isTrue);
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.errorMessage, isNull);
      verify(() => mockProductionService.createProduction(any())).called(1);
      verify(() => mockStorageService.uploadProductionPoster(
            'new_prod_id_456',
            any(),
          )).called(1);
      // Because StorageService returned null, no secondary updateProduction for imageURL is called
      verifyNever(() => mockProductionService.updateProduction(any(), any()));
    });

    test('createProduction rejects startDate > endDate before calling service', () async {
      final success = await viewModel.createProduction(
        title: 'Invalid Dates',
        description: 'Desc',
        startDate: DateTime(2026, 11, 20),
        endDate: DateTime(2026, 11, 10),
        directorId: 'director_456',
      );

      expect(success, isFalse);
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.errorMessage, 'Start date cannot be after end date.');
      verifyNever(() => mockProductionService.createProduction(any()));
    });

    test('createProduction populates errorMessage on service failure',
        () async {
      when(() => mockProductionService.createProduction(any()))
          .thenAnswer((_) async => throw Exception('Firestore permission denied'));

      final success = await viewModel.createProduction(
        title: 'Failure Test',
        description: 'Fails',
        startDate: DateTime(2026, 10, 1),
        endDate: DateTime(2026, 10, 15),
        directorId: 'director_456',
      );

      expect(success, isFalse);
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.errorMessage, contains('Firestore permission denied'));
    });

    test('updateProduction rejects startDate > endDate before calling service', () async {
      final success = await viewModel.updateProduction(
        prodId: 'prod_1',
        title: 'Updated Title',
        description: 'Desc',
        startDate: DateTime(2026, 12, 1),
        endDate: DateTime(2026, 11, 1),
      );

      expect(success, isFalse);
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.errorMessage, 'Start date cannot be after end date.');
      verifyNever(() => mockProductionService.updateProduction(any(), any()));
    });

    test('updateProduction succeeds and updates production', () async {
      when(() => mockProductionService.updateProduction('prod_1', any()))
          .thenAnswer((_) async {});

      final success = await viewModel.updateProduction(
        prodId: 'prod_1',
        title: 'Valid Update',
        description: 'Desc',
        startDate: DateTime(2026, 11, 1),
        endDate: DateTime(2026, 11, 30),
      );

      expect(success, isTrue);
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.errorMessage, isNull);
      verify(() => mockProductionService.updateProduction('prod_1', any())).called(1);
    });

    test('deleteProduction succeeds and clears errorMessage', () async {
      when(() => mockProductionService.deleteProduction('prod_1'))
          .thenAnswer((_) async {});

      final success = await viewModel.deleteProduction('prod_1');
      expect(success, isTrue);
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.errorMessage, isNull);
      verify(() => mockProductionService.deleteProduction('prod_1')).called(1);
    });

    test('deleteProduction handles error and sets errorMessage', () async {
      when(() => mockProductionService.deleteProduction('prod_1'))
          .thenThrow(Exception('Delete failed'));

      final success = await viewModel.deleteProduction('prod_1');
      expect(success, isFalse);
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.errorMessage, contains('Failed to delete production'));
    });

    test('stopWatching cancels subscription and resets state', () async {
      final streamController = StreamController<List<ProductionModel>>();
      when(() => mockProductionService.watchMyProductions('user_1'))
          .thenAnswer((_) => streamController.stream);

      viewModel.startWatching('user_1');
      streamController.add([
        ProductionModel(
          id: 'p1',
          title: 'Title',
          description: 'Desc',
          startDate: DateTime(2026, 1, 1),
          endDate: DateTime(2026, 1, 31),
          directorId: 'user_1',
          memberIds: ['user_1'],
          createdAt: DateTime.now(),
        )
      ]);
      await pumpEventQueue();

      expect(viewModel.productions.isNotEmpty, isTrue);

      viewModel.stopWatching();

      expect(viewModel.productions, isEmpty);
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.errorMessage, isNull);

      await streamController.close();
    });
  });
}
