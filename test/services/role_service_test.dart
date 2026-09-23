// ignore_for_file: subtype_of_sealed_class

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stagesync/models/production_model.dart';
import 'package:stagesync/models/role_model.dart';
import 'package:stagesync/services/production_service.dart';
import 'package:stagesync/services/role_service.dart';

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

class MockProductionService extends Mock implements ProductionService {}

class MockCollectionReference extends Mock
    implements CollectionReference<Map<String, dynamic>> {}

class MockDocumentReference extends Mock
    implements DocumentReference<Map<String, dynamic>> {}

void main() {
  late MockFirebaseFirestore mockFirestore;
  late MockFirebaseAuth mockAuth;
  late MockUser mockUser;
  late MockProductionService mockProductionService;
  late MockCollectionReference mockProductionsCollection;
  late MockDocumentReference mockProductionDoc;
  late MockCollectionReference mockRolesCollection;
  late MockDocumentReference mockRoleDoc;
  late RoleService roleService;

  final sampleProduction = ProductionModel(
    id: 'prod_100',
    title: 'The Crucible',
    description: 'Drama',
    startDate: DateTime(2026, 1, 1),
    endDate: DateTime(2026, 2, 1),
    directorId: 'director_valid',
    memberIds: ['director_valid'],
    createdAt: DateTime.now(),
  );

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockAuth = MockFirebaseAuth();
    mockUser = MockUser();
    mockProductionService = MockProductionService();
    mockProductionsCollection = MockCollectionReference();
    mockProductionDoc = MockDocumentReference();
    mockRolesCollection = MockCollectionReference();
    mockRoleDoc = MockDocumentReference();

    when(() => mockFirestore.collection('productions'))
        .thenReturn(mockProductionsCollection);
    when(() => mockProductionsCollection.doc(any()))
        .thenReturn(mockProductionDoc);
    when(() => mockProductionDoc.collection('roles'))
        .thenReturn(mockRolesCollection);
    when(() => mockRolesCollection.doc(any())).thenReturn(mockRoleDoc);
    when(() => mockRoleDoc.id).thenReturn('new_role_id');
    when(() => mockRoleDoc.set(any())).thenAnswer((_) async {});
    when(() => mockRoleDoc.update(any())).thenAnswer((_) async {});
    when(() => mockRoleDoc.delete()).thenAnswer((_) async {});

    when(() => mockProductionService.getProduction('prod_100'))
        .thenAnswer((_) async => sampleProduction);
    when(() => mockProductionService.addMemberId(any(), any()))
        .thenAnswer((_) async {});

    when(() => mockAuth.currentUser).thenReturn(mockUser);
    when(() => mockUser.uid).thenReturn('director_valid');

    roleService = RoleService(
      firestore: mockFirestore,
      productionService: mockProductionService,
      auth: mockAuth,
    );
  });

  group('RoleService.addRole Tests', () {
    test('addRole creates document with trimmed name', () async {
      final roleId = await roleService.addRole('prod_100', '  John Proctor  ');

      expect(roleId, 'new_role_id');
      final captured = verify(() => mockRoleDoc.set(captureAny())).captured;
      expect(captured.length, 1);
      final map = captured.first as Map;
      expect(map['name'], 'John Proctor');
      expect(map['assignedUserId'], isNull);
    });

    test('addRole rejects empty prodId or name', () async {
      expect(
        () => roleService.addRole('  ', 'Name'),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => roleService.addRole('prod_100', '   '),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('RoleService.updateRole Authorization and Validation Tests', () {
    test('director can successfully update a role', () async {
      final updatedRole = RoleModel(
        id: 'role_1',
        name: 'John Proctor Lead',
        assignedUserId: 'actor_99',
      );

      await roleService.updateRole('prod_100', updatedRole);

      final captured = verify(() => mockRoleDoc.update(captureAny())).captured;
      expect(captured.length, 1);
      final map = captured.first as Map;
      expect(map['name'], 'John Proctor Lead');
      expect(map['assignedUserId'], 'actor_99');

      verify(() => mockProductionService.addMemberId('prod_100', 'actor_99'))
          .called(1);
    });

    test('unauthenticated caller cannot update role', () async {
      when(() => mockAuth.currentUser).thenReturn(null);

      final role = RoleModel(id: 'role_1', name: 'Name');
      expect(
        () => roleService.updateRole('prod_100', role),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('No authenticated user'),
          ),
        ),
      );
      verifyNever(() => mockRoleDoc.update(any()));
    });

    test('non-director caller is rejected with StateError', () async {
      when(() => mockUser.uid).thenReturn('unauthorized_user');

      final role = RoleModel(id: 'role_1', name: 'Name');
      expect(
        () => roleService.updateRole('prod_100', role),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('Only the production director can update role'),
          ),
        ),
      );
      verifyNever(() => mockRoleDoc.update(any()));
    });

    test('rejects empty prodId, roleId, or name with ArgumentError', () async {
      expect(
        () => roleService.updateRole('', RoleModel(id: 'r1', name: 'N')),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => roleService.updateRole('prod_100', RoleModel(id: '', name: 'N')),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => roleService.updateRole('prod_100', RoleModel(id: 'r1', name: '  ')),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('RoleService.deleteRole Authorization and Validation Tests', () {
    test('director can successfully delete a role', () async {
      await roleService.deleteRole('prod_100', 'role_1');

      verify(() => mockRoleDoc.delete()).called(1);
    });

    test('unauthenticated caller cannot delete role', () async {
      when(() => mockAuth.currentUser).thenReturn(null);

      expect(
        () => roleService.deleteRole('prod_100', 'role_1'),
        throwsA(isA<StateError>()),
      );
      verifyNever(() => mockRoleDoc.delete());
    });

    test('non-director caller cannot delete role', () async {
      when(() => mockUser.uid).thenReturn('imposter');

      expect(
        () => roleService.deleteRole('prod_100', 'role_1'),
        throwsA(isA<StateError>()),
      );
      verifyNever(() => mockRoleDoc.delete());
    });

    test('rejects empty prodId or roleId with ArgumentError', () async {
      expect(
        () => roleService.deleteRole('  ', 'role_1'),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => roleService.deleteRole('prod_100', '  '),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('RoleService.assignRole and unassignRole Tests', () {
    test('assignRole updates role assignedUserId and calls addMemberId', () async {
      await roleService.assignRole('prod_100', 'role_1', 'user_abc');

      final captured = verify(() => mockRoleDoc.update(captureAny())).captured;
      expect(captured.length, 1);
      final map = captured.first as Map;
      expect(map['assignedUserId'], 'user_abc');
      verify(() => mockProductionService.addMemberId('prod_100', 'user_abc'))
          .called(1);
    });

    test('unassignRole sets assignedUserId to null', () async {
      await roleService.unassignRole('prod_100', 'role_1');

      final captured = verify(() => mockRoleDoc.update(captureAny())).captured;
      expect(captured.length, 1);
      final map = captured.first as Map;
      expect(map['assignedUserId'], isNull);
    });
  });
}
