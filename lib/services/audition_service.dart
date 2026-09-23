import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stagesync/models/audition_model.dart';
import 'package:stagesync/services/production_service.dart';

class AuditionService {
  AuditionService({
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
  final ProductionService? _productionService;
  final FirebaseAuth? _auth;

  ProductionService? get productionService => _productionService;

  CollectionReference<Map<String, dynamic>> _auditionsCollection(
          String prodId) =>
      _firestore.collection('productions').doc(prodId).collection('auditions');

  Future<void> _verifyDirector(String prodId, String action) async {
    final currentUid = (_auth ?? FirebaseAuth.instance).currentUser?.uid;
    if (currentUid == null) {
      throw StateError('Cannot $action: No authenticated user.');
    }
    final production = await _productionService?.getProduction(prodId);
    if (production == null) {
      throw StateError('Production not found: $prodId');
    }
    if (production.directorId != currentUid) {
      throw StateError('Only the production director can $action.');
    }
  }

  Future<String> createAudition(String prodId, AuditionModel audition) async {
    final trimmedProdId = prodId.trim();
    if (trimmedProdId.isEmpty) {
      throw ArgumentError('Production ID cannot be empty.');
    }
    if (audition.venue.trim().isEmpty) {
      throw ArgumentError('Audition venue cannot be empty.');
    }

    final docRef = _auditionsCollection(trimmedProdId).doc();
    final data = audition.toMap();
    data['venueKey'] = AuditionModel.normalizeVenue(audition.venue);

    await docRef.set(data);
    return docRef.id;
  }

  Future<void> updateAudition(String prodId, AuditionModel audition) async {
    final trimmedProdId = prodId.trim();
    final audId = audition.id?.trim();
    if (trimmedProdId.isEmpty) {
      throw ArgumentError('Production ID cannot be empty.');
    }
    if (audId == null || audId.isEmpty) {
      throw ArgumentError('Audition ID cannot be empty.');
    }
    if (audition.venue.trim().isEmpty) {
      throw ArgumentError('Audition venue cannot be empty.');
    }

    await _verifyDirector(trimmedProdId, 'update audition');

    final data = audition.toMap();
    data['venueKey'] = AuditionModel.normalizeVenue(audition.venue);

    await _auditionsCollection(trimmedProdId).doc(audId).update(data);
  }

  Future<void> deleteAudition(String prodId, String audId) async {
    final trimmedProdId = prodId.trim();
    final trimmedAudId = audId.trim();
    if (trimmedProdId.isEmpty) {
      throw ArgumentError('Production ID cannot be empty.');
    }
    if (trimmedAudId.isEmpty) {
      throw ArgumentError('Audition ID cannot be empty.');
    }

    await _verifyDirector(trimmedProdId, 'delete audition');

    await _auditionsCollection(trimmedProdId).doc(trimmedAudId).delete();
  }

  Future<void> signUp(String prodId, String audId, String userId) async {
    final trimmedUserId = userId.trim();
    if (trimmedUserId.isEmpty) {
      throw ArgumentError('userId cannot be empty');
    }
    await _auditionsCollection(prodId).doc(audId).update({
      'castIds': FieldValue.arrayUnion([trimmedUserId]),
    });
  }

  Future<void> withdraw(String prodId, String audId, String userId) async {
    final trimmedUserId = userId.trim();
    if (trimmedUserId.isEmpty) {
      throw ArgumentError('userId cannot be empty');
    }
    await _auditionsCollection(prodId).doc(audId).update({
      'castIds': FieldValue.arrayRemove([trimmedUserId]),
    });
  }

  Stream<List<AuditionModel>> watchAuditions(String prodId) {
    final trimmedProdId = prodId.trim();
    return _auditionsCollection(trimmedProdId)
        .orderBy('date')
        .snapshots()
        .map((snapshot) => snapshot.docs.map(AuditionModel.fromDoc).toList());
  }
}
