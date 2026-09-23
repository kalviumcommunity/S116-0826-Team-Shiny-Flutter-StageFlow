import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stagesync/models/audition_model.dart';
import 'package:stagesync/services/production_service.dart';

class AuditionService {
  AuditionService({
    FirebaseFirestore? firestore,
    ProductionService? productionService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _productionService = productionService ?? ProductionService();

  final FirebaseFirestore _firestore;
  final ProductionService _productionService;

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
    await _auditionsCollection(prodId).doc(audId).update({
      'castIds': FieldValue.arrayUnion([userId]),
    });
    // Add user to the production's memberIds so security rules grant read access
    await _productionService.addMemberId(prodId, userId);
  }

  Stream<List<AuditionModel>> watchAuditions(String prodId) {
    return _auditionsCollection(prodId)
        .orderBy('date')
        .snapshots()
        .map((snapshot) => snapshot.docs.map(AuditionModel.fromDoc).toList());
  }
}
