import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stagesync/models/audition_model.dart';
import 'package:stagesync/services/production_service.dart';

class AuditionService {
  AuditionService({
    FirebaseFirestore? firestore,
    ProductionService? productionService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _productionService = productionService;

  final FirebaseFirestore _firestore;
  final ProductionService? _productionService;

  ProductionService? get productionService => _productionService;

  CollectionReference<Map<String, dynamic>> _auditionsCollection(
          String prodId) =>
      _firestore.collection('productions').doc(prodId).collection('auditions');

  Future<String> createAudition(String prodId, AuditionModel audition) async {
    final docRef = _auditionsCollection(prodId).doc();
    final data = audition.toMap();
    data['venueKey'] = AuditionModel.normalizeVenue(audition.venue);

    await docRef.set(data);
    return docRef.id;
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
    return _auditionsCollection(prodId)
        .orderBy('date')
        .snapshots()
        .map((snapshot) => snapshot.docs.map(AuditionModel.fromDoc).toList());
  }
}
