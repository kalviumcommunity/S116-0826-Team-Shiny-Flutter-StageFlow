// ignore_for_file: subtype_of_sealed_class

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stagesync/models/audition_model.dart';
import 'package:stagesync/models/production_model.dart';
import 'package:stagesync/services/audition_service.dart';
import 'package:stagesync/services/production_service.dart';

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

class MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

class MockDocumentReference extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

class MockProductionService extends Mock implements ProductionService {}

void main() {
  late MockFirebaseFirestore mockFirestore;
  late MockFirebaseAuth mockAuth;
  late MockUser mockUser;
  late MockCollectionReference mockProductionsCollection;
  late MockDocumentReference mockProductionDoc;
  late MockCollectionReference mockAuditionsCollection;
  late MockDocumentReference mockAuditionDoc;
  late MockProductionService mockProductionService;
  late AuditionService auditionService;

  final sampleProduction = ProductionModel(
    id: 'prod_101',
    title: 'The Crucible',
    description: 'Drama',
    startDate: DateTime(2026, 1, 1),
    endDate: DateTime(2026, 2, 1),
    directorId: 'director_authorized',
    memberIds: ['director_authorized'],
    createdAt: DateTime.now(),
  );

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockAuth = MockFirebaseAuth();
    mockUser = MockUser();
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
    when(() => mockAuditionDoc.id).thenReturn('new_aud_id');
    when(() => mockAuditionDoc.set(any())).thenAnswer((_) async {});
    when(() => mockAuditionDoc.update(any())).thenAnswer((_) async {});
    when(() => mockAuditionDoc.delete()).thenAnswer((_) async {});

    when(() => mockProductionService.getProduction('prod_101'))
        .thenAnswer((_) async => sampleProduction);

    when(() => mockAuth.currentUser).thenReturn(mockUser);
    when(() => mockUser.uid).thenReturn('director_authorized');

    auditionService = AuditionService(
      firestore: mockFirestore,
      productionService: mockProductionService,
      auth: mockAuth,
    );
  });

  group('AuditionService.createAudition Tests', () {
    test('creates audition and stores normalized venueKey', () async {
      final audition = AuditionModel(
        date: DateTime(2026, 3, 1),
        time: '10:00 AM',
        venue: '  Main Auditorium  ',
        venueKey: 'will be normalized',
        castIds: [],
      );

      final id = await auditionService.createAudition('prod_101', audition);
      expect(id, 'new_aud_id');

      final captured = verify(() => mockAuditionDoc.set(captureAny())).captured;
      expect(captured.length, 1);
      final data = captured.first as Map;
      expect(data['venueKey'], 'main auditorium');
    });

    test('rejects empty prodId or venue with ArgumentError', () async {
      final valid = AuditionModel(
        date: DateTime.now(),
        time: 'T',
        venue: 'V',
        venueKey: 'v',
        castIds: [],
      );
      final emptyVenue = AuditionModel(
        date: DateTime.now(),
        time: 'T',
        venue: '   ',
        venueKey: '',
        castIds: [],
      );

      expect(
        () => auditionService.createAudition('   ', valid),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => auditionService.createAudition('prod_101', emptyVenue),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('AuditionService.updateAudition Tests', () {
    test('director can successfully update audition definition', () async {
      final updated = AuditionModel(
        id: 'aud_202',
        date: DateTime(2026, 3, 1),
        time: '2:00 PM',
        venue: 'Studio A',
        venueKey: 'studio a',
        castIds: ['user_1'],
        status: 'closed',
      );

      await auditionService.updateAudition('prod_101', updated);

      final captured = verify(() => mockAuditionDoc.update(captureAny())).captured;
      expect(captured.length, 1);
      final data = captured.first as Map;
      expect(data['status'], 'closed');
      expect(data['venueKey'], 'studio a');
    });

    test('unauthenticated caller cannot update audition', () async {
      when(() => mockAuth.currentUser).thenReturn(null);

      final audition = AuditionModel(
        id: 'aud_202',
        date: DateTime.now(),
        time: 'T',
        venue: 'V',
        venueKey: 'v',
        castIds: [],
      );

      expect(
        () => auditionService.updateAudition('prod_101', audition),
        throwsA(isA<StateError>()),
      );
      verifyNever(() => mockAuditionDoc.update(any()));
    });

    test('non-director caller cannot update audition definition', () async {
      when(() => mockUser.uid).thenReturn('imposter');

      final audition = AuditionModel(
        id: 'aud_202',
        date: DateTime.now(),
        time: 'T',
        venue: 'V',
        venueKey: 'v',
        castIds: [],
      );

      expect(
        () => auditionService.updateAudition('prod_101', audition),
        throwsA(isA<StateError>()),
      );
      verifyNever(() => mockAuditionDoc.update(any()));
    });
  });

  group('AuditionService.deleteAudition Tests', () {
    test('director can successfully delete an audition', () async {
      await auditionService.deleteAudition('prod_101', 'aud_202');

      verify(() => mockAuditionDoc.delete()).called(1);
    });

    test('non-director caller cannot delete audition', () async {
      when(() => mockUser.uid).thenReturn('unauthorized');

      expect(
        () => auditionService.deleteAudition('prod_101', 'aud_202'),
        throwsA(isA<StateError>()),
      );
      verifyNever(() => mockAuditionDoc.delete());
    });

    test('rejects empty prodId or audId with ArgumentError', () async {
      expect(
        () => auditionService.deleteAudition('  ', 'aud_1'),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => auditionService.deleteAudition('prod_101', '  '),
        throwsA(isA<ArgumentError>()),
      );
    });
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
