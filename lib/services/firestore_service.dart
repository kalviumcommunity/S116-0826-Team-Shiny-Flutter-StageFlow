import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';
import '../models/production.dart';
import '../models/role_model.dart';
import '../models/event_model.dart';
import '../models/audition.dart';

class FirestoreService {
  final FirebaseFirestore? _injectedFirestore;

  FirestoreService({FirebaseFirestore? firestore})
      : _injectedFirestore = firestore;

  FirebaseFirestore get _firestore => _injectedFirestore ?? FirebaseFirestore.instance;

  // ================= USERS =================

  Stream<List<AppUser>> getAllUsersStream() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => AppUser.fromMap(doc.data(), doc.id)).toList();
    });
  }

  Future<List<AppUser>> getAllUsers() async {
    final snapshot = await _firestore.collection('users').get();
    return snapshot.docs.map((doc) => AppUser.fromMap(doc.data(), doc.id)).toList();
  }

  Future<Map<String, AppUser>> getUsersMap() async {
    final users = await getAllUsers();
    return {for (var u in users) u.id: u};
  }

  // ================= PRODUCTIONS =================

  Stream<List<Production>> getProductionsStream() {
    return _firestore
        .collection('productions')
        .orderBy('startDate', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Production.fromFirestore(doc)).toList());
  }

  Stream<List<Production>> getDirectorProductionsStream(String directorId) {
    return _firestore
        .collection('productions')
        .where('directorId', isEqualTo: directorId)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs.map((doc) => Production.fromFirestore(doc)).toList();
          list.sort((a, b) => a.startDate.compareTo(b.startDate));
          return list;
        });
  }

  Future<Production?> getProduction(String productionId) async {
    final doc = await _firestore.collection('productions').doc(productionId).get();
    if (!doc.exists) return null;
    return Production.fromFirestore(doc);
  }

  Future<String> createProduction(Production production) async {
    final docRef = await _firestore.collection('productions').add(production.toMap());
    return docRef.id;
  }

  Future<void> updateProduction(Production production) async {
    await _firestore.collection('productions').doc(production.id).update(production.toMap());
  }

  Future<void> deleteProduction(String productionId) async {
    // Atomic WriteBatch for cascading deletion of subcollections and production doc
    final batch = _firestore.batch();

    final roles = await _firestore.collection('productions').doc(productionId).collection('roles').get();
    for (var doc in roles.docs) {
      batch.delete(doc.reference);
    }

    final events = await _firestore.collection('productions').doc(productionId).collection('events').get();
    for (var doc in events.docs) {
      batch.delete(doc.reference);
    }

    final auditions = await _firestore.collection('productions').doc(productionId).collection('auditions').get();
    for (var doc in auditions.docs) {
      batch.delete(doc.reference);
    }

    batch.delete(_firestore.collection('productions').doc(productionId));
    await batch.commit();
  }

  // ================= ROLES =================

  Stream<List<RoleModel>> getRolesStream(String productionId) {
    return _firestore
        .collection('productions')
        .doc(productionId)
        .collection('roles')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => RoleModel.fromFirestore(doc, productionId)).toList();
        });
  }

  Future<void> addRole({
    required String productionId,
    required String roleName,
    String? assignedUserId,
  }) async {
    await _firestore.collection('productions').doc(productionId).collection('roles').add({
      'name': roleName.trim(),
      'assignedUserId': (assignedUserId == null || assignedUserId.isEmpty) ? null : assignedUserId,
    });
  }

  Future<void> updateRole({
    required String productionId,
    required String roleId,
    required String roleName,
    String? assignedUserId,
  }) async {
    await _firestore
        .collection('productions')
        .doc(productionId)
        .collection('roles')
        .doc(roleId)
        .update({
      'name': roleName.trim(),
      'assignedUserId': (assignedUserId == null || assignedUserId.isEmpty) ? null : assignedUserId,
    });
  }

  Future<void> deleteRole(String productionId, String roleId) async {
    await _firestore
        .collection('productions')
        .doc(productionId)
        .collection('roles')
        .doc(roleId)
        .delete();
  }

  // ================= EVENTS =================

  Stream<List<EventModel>> getProductionEventsStream(String productionId, [String? productionTitle]) {
    return _firestore
        .collection('productions')
        .doc(productionId)
        .collection('events')
        .orderBy('start', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => EventModel.fromFirestore(doc, productionId, productionTitle))
              .toList();
        });
  }

  Stream<List<EventModel>> getAllEventsStream() {
    return _firestore.collectionGroup('events').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final prodId = doc.reference.parent.parent?.id ?? '';
        return EventModel.fromFirestore(doc, prodId);
      }).toList();
    });
  }

  Future<void> createEvent(EventModel event) async {
    await _firestore
        .collection('productions')
        .doc(event.productionId)
        .collection('events')
        .add(event.toMap());
  }

  Future<void> updateEvent(EventModel event) async {
    await _firestore
        .collection('productions')
        .doc(event.productionId)
        .collection('events')
        .doc(event.id)
        .update(event.toMap());
  }

  Future<void> deleteEvent(String productionId, String eventId) async {
    await _firestore
        .collection('productions')
        .doc(productionId)
        .collection('events')
        .doc(eventId)
        .delete();
  }

  // ================= AUDITIONS =================

  Stream<List<Audition>> getProductionAuditionsStream(String productionId, [String? productionTitle]) {
    return _firestore
        .collection('productions')
        .doc(productionId)
        .collection('auditions')
        .orderBy('date', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Audition.fromFirestore(doc, productionId, productionTitle))
              .toList();
        });
  }

  Stream<List<Audition>> getAllAuditionsStream() {
    return _firestore.collectionGroup('auditions').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final prodId = doc.reference.parent.parent?.id ?? '';
        return Audition.fromFirestore(doc, prodId);
      }).toList();
    });
  }

  Future<void> createAudition(Audition audition) async {
    await _firestore
        .collection('productions')
        .doc(audition.productionId)
        .collection('auditions')
        .add(audition.toMap());
  }

  Future<void> deleteAudition(String productionId, String auditionId) async {
    await _firestore
        .collection('productions')
        .doc(productionId)
        .collection('auditions')
        .doc(auditionId)
        .delete();
  }

  Future<void> signUpForAudition({
    required String productionId,
    required String auditionId,
    required String userId,
  }) async {
    final docRef = _firestore
        .collection('productions')
        .doc(productionId)
        .collection('auditions')
        .doc(auditionId);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) {
        throw Exception('Audition call does not exist');
      }
      final data = snapshot.data() ?? {};
      final rawCast = data['castIds'] as List<dynamic>? ?? [];
      if (!rawCast.contains(userId)) {
        transaction.update(docRef, {
          'castIds': FieldValue.arrayUnion([userId]),
        });
      }
    });
  }
}
