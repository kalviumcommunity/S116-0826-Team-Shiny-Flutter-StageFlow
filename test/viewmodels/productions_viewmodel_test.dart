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
  });
}
