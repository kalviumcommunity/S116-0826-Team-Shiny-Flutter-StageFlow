import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stagesync/models/production_model.dart';

class ProductionService {
  ProductionService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _productionsCollection =>
      _firestore.collection('productions');

  static DateTime? _extractDateTime(dynamic val) {
    if (val is DateTime) return val;
    if (val is Timestamp) return val.toDate();
    if (val is String) return DateTime.tryParse(val);
    if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
    return null;
  }

  Future<String> createProduction(ProductionModel production) async {
    if (production.startDate.isAfter(production.endDate)) {
      throw ArgumentError('Production start date cannot be after end date.');
    }

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
    final trimmedProdId = prodId.trim();
    if (trimmedProdId.isEmpty) {
      throw ArgumentError('Production ID cannot be empty.');
    }

    final hasStart =
        updates.containsKey('startDate') && updates['startDate'] != null;
    final hasEnd = updates.containsKey('endDate') && updates['endDate'] != null;

    if (hasStart || hasEnd) {
      final updatedStart =
          hasStart ? _extractDateTime(updates['startDate']) : null;
      final updatedEnd = hasEnd ? _extractDateTime(updates['endDate']) : null;

      if (hasStart && hasEnd && updatedStart != null && updatedEnd != null) {
        if (updatedStart.isAfter(updatedEnd)) {
          throw ArgumentError('Production start date cannot be after end date.');
        }
      } else {
        final existing = await getProduction(trimmedProdId);
        if (existing != null) {
          final finalStart = updatedStart ?? existing.startDate;
          final finalEnd = updatedEnd ?? existing.endDate;
          if (finalStart.isAfter(finalEnd)) {
            throw ArgumentError(
                'Production start date cannot be after end date.');
          }
        }
      }
    }

    await _productionsCollection.doc(trimmedProdId).update(updates);
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
        .snapshots()
        .map(
          (snapshot) {
            final productions = snapshot.docs
                .map(ProductionModel.fromDoc)
                .toList(growable: true);
            productions.sort((a, b) => a.startDate.compareTo(b.startDate));
            return List<ProductionModel>.unmodifiable(productions);
          },
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
