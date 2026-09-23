// ignore_for_file: subtype_of_sealed_class

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stagesync/models/role_model.dart';
import 'package:stagesync/models/user_model.dart';
import 'package:stagesync/services/role_service.dart';
import 'package:stagesync/viewmodels/roles_viewmodel.dart';

class MockRoleService extends Mock implements RoleService {}

class FakeRoleModel extends Fake implements RoleModel {}

void main() {
  late MockRoleService mockRoleService;
  late RolesViewModel viewModel;

  setUpAll(() {
    registerFallbackValue(FakeRoleModel());
  });

  setUp(() {
    mockRoleService = MockRoleService();
    viewModel = RolesViewModel(roleService: mockRoleService);
  });

  tearDown(() {
    viewModel.dispose();
  });

  group('RolesViewModel CRUD and Error Tests', () {
    test('addRole succeeds and sets loading state', () async {
      when(() => mockRoleService.addRole('prod_1', 'Hamlet'))
          .thenAnswer((_) async => 'role_1');

      final success = await viewModel.addRole('prod_1', 'Hamlet');
      expect(success, isTrue);
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.errorMessage, isNull);
      verify(() => mockRoleService.addRole('prod_1', 'Hamlet')).called(1);
    });

    test('addRole handles error and sets errorMessage', () async {
      when(() => mockRoleService.addRole('prod_1', 'Hamlet'))
          .thenThrow(Exception('Firestore write failed'));

      final success = await viewModel.addRole('prod_1', 'Hamlet');
      expect(success, isFalse);
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.errorMessage, contains('Failed to add role'));
    });

    test('updateRole succeeds and clears errorMessage', () async {
      final role = RoleModel(id: 'r1', name: 'Macbeth');
      when(() => mockRoleService.updateRole('prod_1', role))
          .thenAnswer((_) async {});

      final success = await viewModel.updateRole('prod_1', role);
      expect(success, isTrue);
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.errorMessage, isNull);
      verify(() => mockRoleService.updateRole('prod_1', role)).called(1);
    });

    test('updateRole handles error and sets errorMessage', () async {
      final role = RoleModel(id: 'r1', name: 'Macbeth');
      when(() => mockRoleService.updateRole('prod_1', role))
          .thenThrow(StateError('Only the production director can update roles.'));

      final success = await viewModel.updateRole('prod_1', role);
      expect(success, isFalse);
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.errorMessage, contains('Only the production director can update roles'));
    });

    test('deleteRole succeeds and clears errorMessage', () async {
      when(() => mockRoleService.deleteRole('prod_1', 'r1'))
          .thenAnswer((_) async {});

      final success = await viewModel.deleteRole('prod_1', 'r1');
      expect(success, isTrue);
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.errorMessage, isNull);
      verify(() => mockRoleService.deleteRole('prod_1', 'r1')).called(1);
    });

    test('deleteRole handles error and sets errorMessage', () async {
      when(() => mockRoleService.deleteRole('prod_1', 'r1'))
          .thenThrow(Exception('Delete failed'));

      final success = await viewModel.deleteRole('prod_1', 'r1');
      expect(success, isFalse);
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.errorMessage, contains('Failed to delete role'));
    });

    test('assignRole and unassignRole succeed and handle error gracefully', () async {
      when(() => mockRoleService.assignRole('prod_1', 'r1', 'u1'))
          .thenAnswer((_) async {});
      when(() => mockRoleService.unassignRole('prod_1', 'r1'))
          .thenAnswer((_) async {});

      expect(await viewModel.assignRole('prod_1', 'r1', 'u1'), isTrue);
      expect(await viewModel.unassignRole('prod_1', 'r1'), isTrue);

      when(() => mockRoleService.assignRole('prod_1', 'r1', 'u1'))
          .thenThrow(Exception('Assign error'));
      expect(await viewModel.assignRole('prod_1', 'r1', 'u1'), isFalse);
      expect(viewModel.errorMessage, contains('Failed to assign role'));
    });
  });

  group('RolesViewModel Lifecycle and Stream Tests', () {
    test('startWatching populates roles and handles stream error', () async {
      final streamController = StreamController<List<RoleModel>>();
      when(() => mockRoleService.watchRoles('prod_1'))
          .thenAnswer((_) => streamController.stream);
      when(() => mockRoleService.getAllCastUsers())
          .thenAnswer((_) async => <UserModel>[]);

      viewModel.startWatching('prod_1');
      expect(viewModel.isLoading, isTrue);

      streamController.add([RoleModel(id: 'r1', name: 'Horatio')]);
      await pumpEventQueue();

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.roles.length, 1);
      expect(viewModel.roles.first.name, 'Horatio');

      // Test stream error
      streamController.addError(Exception('Stream permission error'));
      await pumpEventQueue();

      expect(viewModel.isLoading, isFalse);
      expect(viewModel.errorMessage, contains('Failed to load roles'));

      await streamController.close();
    });

    test('stopWatching cancels subscription and clears all state', () async {
      final streamController = StreamController<List<RoleModel>>();
      when(() => mockRoleService.watchRoles('prod_1'))
          .thenAnswer((_) => streamController.stream);
      when(() => mockRoleService.getAllCastUsers())
          .thenAnswer((_) async => <UserModel>[]);

      viewModel.startWatching('prod_1');
      streamController.add([RoleModel(id: 'r1', name: 'Horatio')]);
      await pumpEventQueue();

      expect(viewModel.roles.isNotEmpty, isTrue);

      viewModel.stopWatching();

      expect(viewModel.roles, isEmpty);
      expect(viewModel.castUsers, isEmpty);
      expect(viewModel.isLoading, isFalse);
      expect(viewModel.errorMessage, isNull);

      await streamController.close();
    });
  });
}
