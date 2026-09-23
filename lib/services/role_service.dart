import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stagesync/models/role_model.dart';
import 'package:stagesync/models/user_model.dart';
import 'package:stagesync/services/production_service.dart';

class RoleService {
  RoleService({
    FirebaseFirestore? firestore,
    ProductionService? productionService,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _productionService = productionService ??
            ProductionService(
              firestore: firestore ?? FirebaseFirestore.instance,
            ),
        _auth = auth;

  final FirebaseFirestore _firestore;
  final ProductionService _productionService;
  final FirebaseAuth? _auth;

  ProductionService get productionService => _productionService;

  CollectionReference<Map<String, dynamic>> _rolesCollection(String prodId) =>
      _firestore.collection('productions').doc(prodId).collection('roles');

  Future<void> _verifyDirector(String prodId, String action) async {
    final currentUid = (_auth ?? FirebaseAuth.instance).currentUser?.uid;
    if (currentUid == null) {
      throw StateError('Cannot $action: No authenticated user.');
    }
    final production = await _productionService.getProduction(prodId);
    if (production == null) {
      throw StateError('Production not found: $prodId');
    }
    if (production.directorId != currentUid) {
      throw StateError('Only the production director can $action.');
    }
  }

  Future<String> addRole(String prodId, String name) async {
    final trimmedProdId = prodId.trim();
    final trimmedName = name.trim();
    if (trimmedProdId.isEmpty) {
      throw ArgumentError('Production ID cannot be empty.');
    }
    if (trimmedName.isEmpty) {
      throw ArgumentError('Role name cannot be empty.');
    }

    final docRef = _rolesCollection(trimmedProdId).doc();
    final role = RoleModel(
      id: docRef.id,
      name: trimmedName,
      assignedUserId: null,
    );
    await docRef.set(role.toMap());
    return docRef.id;
  }

  Future<void> updateRole(String prodId, RoleModel role) async {
    final trimmedProdId = prodId.trim();
    final roleId = role.id?.trim();
    final roleName = role.name.trim();

    if (trimmedProdId.isEmpty) {
      throw ArgumentError('Production ID cannot be empty.');
    }
    if (roleId == null || roleId.isEmpty) {
      throw ArgumentError('Role ID cannot be empty.');
    }
    if (roleName.isEmpty) {
      throw ArgumentError('Role name cannot be empty.');
    }

    await _verifyDirector(trimmedProdId, 'update role');

    await _rolesCollection(trimmedProdId).doc(roleId).update(role.toMap());

    if (role.assignedUserId != null &&
        role.assignedUserId!.trim().isNotEmpty) {
      await _productionService.addMemberId(
        trimmedProdId,
        role.assignedUserId!.trim(),
      );
    }
  }

  Future<void> deleteRole(String prodId, String roleId) async {
    final trimmedProdId = prodId.trim();
    final trimmedRoleId = roleId.trim();

    if (trimmedProdId.isEmpty) {
      throw ArgumentError('Production ID cannot be empty.');
    }
    if (trimmedRoleId.isEmpty) {
      throw ArgumentError('Role ID cannot be empty.');
    }

    await _verifyDirector(trimmedProdId, 'delete role');

    await _rolesCollection(trimmedProdId).doc(trimmedRoleId).delete();
  }

  Future<void> assignRole(String prodId, String roleId, String userId) async {
    final trimmedProdId = prodId.trim();
    final trimmedRoleId = roleId.trim();
    final trimmedUserId = userId.trim();

    if (trimmedProdId.isEmpty) {
      throw ArgumentError('Production ID cannot be empty.');
    }
    if (trimmedRoleId.isEmpty) {
      throw ArgumentError('Role ID cannot be empty.');
    }
    if (trimmedUserId.isEmpty) {
      throw ArgumentError('User ID cannot be empty.');
    }

    await _rolesCollection(trimmedProdId).doc(trimmedRoleId).update({
      'assignedUserId': trimmedUserId,
    });
    // Add user to the production's memberIds so security rules grant read access
    await _productionService.addMemberId(trimmedProdId, trimmedUserId);
  }

  Future<void> unassignRole(String prodId, String roleId) async {
    final trimmedProdId = prodId.trim();
    final trimmedRoleId = roleId.trim();

    if (trimmedProdId.isEmpty) {
      throw ArgumentError('Production ID cannot be empty.');
    }
    if (trimmedRoleId.isEmpty) {
      throw ArgumentError('Role ID cannot be empty.');
    }

    await _rolesCollection(trimmedProdId).doc(trimmedRoleId).update({
      'assignedUserId': null,
    });
    // Architectural Note: We intentionally do NOT remove the user from memberIds
    // here because they may still have existing event or audition assignments on
    // this production. Under the StageSync MVP security model, memberIds grows
    // monotonically to avoid accidental revocation of valid production reads.
  }

  Stream<List<RoleModel>> watchRoles(String prodId) {
    final trimmedProdId = prodId.trim();
    return _rolesCollection(trimmedProdId)
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs.map(RoleModel.fromDoc).toList());
  }

  Future<List<UserModel>> getAllCastUsers() async {
    final snapshot = await _firestore
        .collection('users')
        .where('role', isEqualTo: 'cast')
        .get();

    return snapshot.docs.map(UserModel.fromDoc).toList();
  }
}
