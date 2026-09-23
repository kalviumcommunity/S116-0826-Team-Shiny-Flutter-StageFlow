// ignore_for_file: subtype_of_sealed_class

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stagesync/models/production_model.dart';
import 'package:stagesync/services/production_service.dart';

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

class MockDocumentReference extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

class MockDocumentSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {}

void main() {
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference mockProductionsCollection;
  late MockDocumentReference mockProductionDoc;
  late MockDocumentSnapshot mockDocSnapshot;
  late ProductionService productionService;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockProductionsCollection = MockCollectionReference();
    mockProductionDoc = MockDocumentReference();
    mockDocSnapshot = MockDocumentSnapshot();

    when(() => mockFirestore.collection('productions'))
        .thenReturn(mockProductionsCollection);
    when(() => mockProductionsCollection.doc(any()))
        .thenReturn(mockProductionDoc);
    when(() => mockProductionDoc.id).thenReturn('new_prod_id');
    when(() => mockProductionDoc.set(any())).thenAnswer((_) async {});
    when(() => mockProductionDoc.update(any())).thenAnswer((_) async {});
    when(() => mockProductionDoc.get()).thenAnswer((_) async => mockDocSnapshot);

    productionService = ProductionService(firestore: mockFirestore);
  });

  group('ProductionService.createProduction Date Validation Tests', () {
    test('succeeds when startDate <= endDate', () async {
      final valid = ProductionModel(
        title: 'Valid Production',
        description: 'Description',
        startDate: DateTime(2026, 6, 1),
        endDate: DateTime(2026, 6, 30),
        directorId: 'dir_1',
        memberIds: ['dir_1'],
        createdAt: DateTime.now(),
      );

      final id = await productionService.createProduction(valid);
      expect(id, 'new_prod_id');
      verify(() => mockProductionDoc.set(any())).called(1);
    });

    test('rejects with ArgumentError when startDate > endDate', () async {
      final invalid = ProductionModel(
        title: 'Invalid Production',
        description: 'Description',
        startDate: DateTime(2026, 7, 1),
        endDate: DateTime(2026, 6, 30),
        directorId: 'dir_1',
        memberIds: ['dir_1'],
        createdAt: DateTime.now(),
      );

      expect(
        () => productionService.createProduction(invalid),
        throwsA(isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          contains('start date cannot be after end date'),
        )),
      );
      verifyNever(() => mockProductionDoc.set(any()));
    });
  });

  group('ProductionService.updateProduction Resulting Date Range Validation Tests', () {
    test('succeeds when both dates updated and startDate <= endDate', () async {
      await productionService.updateProduction('prod_1', {
        'startDate': DateTime(2026, 5, 1),
        'endDate': DateTime(2026, 5, 15),
      });

      verify(() => mockProductionDoc.update(any())).called(1);
    });

    test('rejects when both dates updated and startDate > endDate', () async {
      expect(
        () => productionService.updateProduction('prod_1', {
          'startDate': DateTime(2026, 5, 20),
          'endDate': DateTime(2026, 5, 15),
        }),
        throwsA(isA<ArgumentError>()),
      );
      verifyNever(() => mockProductionDoc.update(any()));
    });

    test('validates resulting range when only startDate is updated against existing endDate', () async {
      when(() => mockDocSnapshot.exists).thenReturn(true);
      when(() => mockDocSnapshot.id).thenReturn('prod_1');
      when(() => mockDocSnapshot.data()).thenReturn({
        'title': 'Existing Production',
        'startDate': DateTime(2026, 5, 1),
        'endDate': DateTime(2026, 5, 10),
        'directorId': 'dir_1',
        'memberIds': ['dir_1'],
        'createdAt': DateTime(2026, 1, 1),
      });

      // Valid: new startDate (May 5) <= existing endDate (May 10)
      await productionService.updateProduction('prod_1', {
        'startDate': DateTime(2026, 5, 5),
      });
      verify(() => mockProductionDoc.update(any())).called(1);

      // Invalid: new startDate (May 15) > existing endDate (May 10)
      expect(
        () => productionService.updateProduction('prod_1', {
          'startDate': DateTime(2026, 5, 15),
        }),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('validates resulting range when only endDate is updated against existing startDate', () async {
      when(() => mockDocSnapshot.exists).thenReturn(true);
      when(() => mockDocSnapshot.id).thenReturn('prod_1');
      when(() => mockDocSnapshot.data()).thenReturn({
        'title': 'Existing Production',
        'startDate': DateTime(2026, 5, 10),
        'endDate': DateTime(2026, 5, 30),
        'directorId': 'dir_1',
        'memberIds': ['dir_1'],
        'createdAt': DateTime(2026, 1, 1),
      });

      // Valid: existing startDate (May 10) <= new endDate (May 20)
      await productionService.updateProduction('prod_1', {
        'endDate': DateTime(2026, 5, 20),
      });
      verify(() => mockProductionDoc.update(any())).called(1);

      // Invalid: existing startDate (May 10) > new endDate (May 5)
      expect(
        () => productionService.updateProduction('prod_1', {
          'endDate': DateTime(2026, 5, 5),
        }),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('rejects empty prodId with ArgumentError', () async {
      expect(
        () => productionService.updateProduction('  ', {'title': 'T'}),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
