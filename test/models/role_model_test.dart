import 'package:flutter_test/flutter_test.dart';
import 'package:stagesync/models/role_model.dart';

void main() {
  group('RoleModel Serialization and copyWith Tests', () {
    test('fromMap and toMap handle all fields correctly', () {
      final role = RoleModel(
        id: 'role_1',
        name: 'Hamlet',
        assignedUserId: 'actor_101',
      );

      final map = role.toMap();
      expect(map['name'], 'Hamlet');
      expect(map['assignedUserId'], 'actor_101');

      final parsed = RoleModel.fromMap(map, 'role_1');
      expect(parsed.id, 'role_1');
      expect(parsed.name, 'Hamlet');
      expect(parsed.assignedUserId, 'actor_101');
    });

    test('fromMap uses safe fallbacks for missing/null fields', () {
      final parsed = RoleModel.fromMap({}, 'role_fallback');
      expect(parsed.id, 'role_fallback');
      expect(parsed.name, '');
      expect(parsed.assignedUserId, isNull);
    });

    test('copyWith updates specified fields while preserving existing values', () {
      final original = RoleModel(
        id: 'role_1',
        name: 'Ophelia',
        assignedUserId: 'actor_102',
      );

      final updated = original.copyWith(name: 'Lady Macbeth');
      expect(updated.id, 'role_1');
      expect(updated.name, 'Lady Macbeth');
      expect(updated.assignedUserId, 'actor_102');

      final unassigned = original.copyWith(clearAssignedUser: true);
      expect(unassigned.assignedUserId, isNull);
    });
  });
}
