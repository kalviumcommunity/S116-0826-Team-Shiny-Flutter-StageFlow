import 'package:cloud_firestore/cloud_firestore.dart';

class ProductionModel {
  ProductionModel({
    this.id,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.directorId,
    this.imageURL,
    required this.memberIds,
    required this.createdAt,
  });

  final String? id;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final String directorId;
  final String? imageURL;
  final List<String> memberIds;
  final DateTime createdAt;

  factory ProductionModel.fromMap(Map<String, dynamic> map, String id) {
    return ProductionModel(
      id: id,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      startDate: _coerceDateTime(
        map['startDate'],
        fallback: DateTime.fromMillisecondsSinceEpoch(0),
      ),
      endDate: _coerceDateTime(
        map['endDate'],
        fallback: DateTime.fromMillisecondsSinceEpoch(0),
      ),
      directorId: map['directorId'] as String? ?? '',
      imageURL: map['imageURL'] as String?,
      memberIds:
          List<String>.from((map['memberIds'] as List?) ?? const <dynamic>[]),
      createdAt: _coerceDateTime(
        map['createdAt'],
        fallback: DateTime.fromMillisecondsSinceEpoch(0),
      ),
    );
  }

  factory ProductionModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? <String, dynamic>{};
    return ProductionModel.fromMap(data, doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'startDate': startDate,
      'endDate': endDate,
      'directorId': directorId,
      'imageURL': imageURL,
      'memberIds': memberIds,
      'createdAt': createdAt,
    };
  }

  static DateTime _coerceDateTime(dynamic value, {required DateTime fallback}) {
    if (value is DateTime) {
      return value;
    }
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is String) {
      final parsed = DateTime.tryParse(value);
      if (parsed != null) {
        return parsed;
      }
    }
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    return fallback;
  }
}
