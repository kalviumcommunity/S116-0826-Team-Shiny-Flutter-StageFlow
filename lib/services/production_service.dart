import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stagesync/models/production_model.dart';

class ProductionService {
  ProductionService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _productionsCollection =>
      _firestore.collection('productions');

  Future<String> createProduction(ProductionModel production) async {
    final docRef = _productionsCollection.doc();
    final data = production.toMap()
      ..['memberIds'] = <String>[production.directorId];

    await docRef.set(data);
    return docRef.id;
  }

  Future<void> updateProduction(
    String prodId,
    Map<String, dynamic> updates,
  ) async {
    await _productionsCollection.doc(prodId).update(updates);
  }

  Future<void> deleteProduction(String prodId) async {
    final productionRef = _productionsCollection.doc(prodId);

    // For MVP this client-side batch delete is acceptable; at serious scale,
    // this should move to a Cloud Function to avoid client timeouts and quota
    // pressure when deleting many nested documents.
    await _deleteCollectionInBatches(productionRef.collection('roles'));
    await _deleteCollectionInBatches(productionRef.collection('events'));
    await _deleteCollectionInBatches(productionRef.collection('auditions'));
    await productionRef.delete();
  }

  Stream<List<ProductionModel>> watchMyProductions(String uid) {
    return _productionsCollection
        .where('memberIds', arrayContains: uid)
        .orderBy('startDate')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(ProductionModel.fromDoc)
              .toList(growable: false),
        );
  }

  Future<ProductionModel?> getProduction(String prodId) async {
    final doc = await _productionsCollection.doc(prodId).get();
    if (!doc.exists) {
      return null;
    }
    return ProductionModel.fromDoc(doc);
  }

  Future<void> addMemberId(String prodId, String userId) async {
    await _productionsCollection.doc(prodId).update({
      'memberIds': FieldValue.arrayUnion(<String>[userId]),
    });
  }

  Future<void> _deleteCollectionInBatches(
    CollectionReference<Map<String, dynamic>> collectionRef,
  ) async {
    while (true) {
      final snapshot = await collectionRef.limit(500).get();
      if (snapshot.docs.isEmpty) {
        break;
      }

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }
  }
}