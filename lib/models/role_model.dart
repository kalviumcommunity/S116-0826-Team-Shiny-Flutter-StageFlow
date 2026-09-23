import 'package:cloud_firestore/cloud_firestore.dart';

class RoleModel {
  RoleModel({
    this.id,
    required this.name,
    this.assignedUserId,
  });

  final String? id;
  final String name;
  final String? assignedUserId;

  factory RoleModel.fromMap(Map<String, dynamic> map, String id) {
    return RoleModel(
      id: id,
      name: map['name'] as String? ?? '',
      assignedUserId: map['assignedUserId'] as String?,
    );
  }

  factory RoleModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? <String, dynamic>{};
    return RoleModel.fromMap(data, doc.id);
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'assignedUserId': assignedUserId,
    };
  }
}
