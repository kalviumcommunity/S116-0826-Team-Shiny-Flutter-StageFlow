import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stagesync/models/role_model.dart';
import 'package:stagesync/models/user_model.dart';
import 'package:stagesync/services/production_service.dart';

class RoleService {
  RoleService({
    FirebaseFirestore? firestore,
    ProductionService? productionService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _productionService = productionService ?? ProductionService();

  final FirebaseFirestore _firestore;
  final ProductionService _productionService;

  CollectionReference<Map<String, dynamic>> _rolesCollection(String prodId) =>
      _firestore.collection('productions').doc(prodId).collection('roles');

  Future<String> addRole(String prodId, String name) async {
    final docRef = _rolesCollection(prodId).doc();
    final role = RoleModel(
      id: docRef.id,
      name: name.trim(),
      assignedUserId: null,
    );
    await docRef.set(role.toMap());
    return docRef.id;
  }

  Future<void> assignRole(String prodId, String roleId, String userId) async {
    await _rolesCollection(prodId).doc(roleId).update({
      'assignedUserId': userId,
    });
    // Add user to the production's memberIds so security rules grant read access
    await _productionService.addMemberId(prodId, userId);
  }

  Future<void> unassignRole(String prodId, String roleId) async {
    await _rolesCollection(prodId).doc(roleId).update({
      'assignedUserId': null,
    });
    // Architectural Note: We intentionally do NOT remove the user from memberIds
    // here because they may still have existing event or audition assignments on
    // this production. Under the StageSync MVP security model, memberIds grows
    // monotonically to avoid accidental revocation of valid production reads.
  }

  Stream<List<RoleModel>> watchRoles(String prodId) {
    return _rolesCollection(prodId)
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
