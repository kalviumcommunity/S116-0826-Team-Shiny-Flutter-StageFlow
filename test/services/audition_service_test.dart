// ignore_for_file: subtype_of_sealed_class

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stagesync/services/audition_service.dart';
import 'package:stagesync/services/production_service.dart';

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

class MockDocumentReference extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

class MockProductionService extends Mock implements ProductionService {}

void main() {
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference mockProductionsCollection;
  late MockDocumentReference mockProductionDoc;
  late MockCollectionReference mockAuditionsCollection;
  late MockDocumentReference mockAuditionDoc;
  late MockProductionService mockProductionService;
  late AuditionService auditionService;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockProductionsCollection = MockCollectionReference();
    mockProductionDoc = MockDocumentReference();
    mockAuditionsCollection = MockCollectionReference();
    mockAuditionDoc = MockDocumentReference();
    mockProductionService = MockProductionService();

    when(() => mockFirestore.collection('productions'))
        .thenReturn(mockProductionsCollection);
    when(() => mockProductionsCollection.doc(any()))
        .thenReturn(mockProductionDoc);
    when(() => mockProductionDoc.collection('auditions'))
        .thenReturn(mockAuditionsCollection);
    when(() => mockAuditionsCollection.doc(any()))
        .thenReturn(mockAuditionDoc);
    when(() => mockAuditionDoc.update(any()))
        .thenAnswer((_) async {});

    auditionService = AuditionService(
      firestore: mockFirestore,
      productionService: mockProductionService,
    );
  });

  group('AuditionService.signUp Tests', () {
    test('signUp uses FieldValue.arrayUnion and does NOT call addMemberId',
        () async {
      await auditionService.signUp('prod_101', 'aud_202', 'cast_user_456');

      final captured = verify(() => mockAuditionDoc.update(captureAny())).captured;
      expect(captured.length, 1);
      final updateMap = captured.first as Map;
      expect(updateMap.containsKey('castIds'), isTrue);
      expect(updateMap['castIds'], isA<FieldValue>());

      // Verify that audition signup is decoupled from ProductionService.addMemberId
      verifyNever(() => mockProductionService.addMemberId(any(), any()));
    });

    test('signUp rejects empty or whitespace userId', () async {
      expect(
        () => auditionService.signUp('prod_101', 'aud_202', '   '),
        throwsA(isA<ArgumentError>()),
      );
      verifyNever(() => mockAuditionDoc.update(any()));
    });
  });

  group('AuditionService.withdraw Tests', () {
    test('withdraw uses FieldValue.arrayRemove and does not alter production members',
        () async {
      await auditionService.withdraw('prod_101', 'aud_202', 'cast_user_456');

      final captured = verify(() => mockAuditionDoc.update(captureAny())).captured;
      expect(captured.length, 1);
      final updateMap = captured.first as Map;
      expect(updateMap.containsKey('castIds'), isTrue);
      expect(updateMap['castIds'], isA<FieldValue>());

      verifyNever(() => mockProductionService.addMemberId(any(), any()));
    });

    test('withdraw rejects empty or whitespace userId', () async {
      expect(
        () => auditionService.withdraw('prod_101', 'aud_202', ''),
        throwsA(isA<ArgumentError>()),
      );
      verifyNever(() => mockAuditionDoc.update(any()));
    });
  });
}
