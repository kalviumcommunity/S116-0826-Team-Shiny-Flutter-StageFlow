import 'package:cloud_firestore/cloud_firestore.dart';

class RoleModel {
  final String id;
  final String productionId;
  final String name;
  final String? assignedUserId;
  final String? assignedUserName;

  const RoleModel({
    required this.id,
    required this.productionId,
    required this.name,
    this.assignedUserId,
    this.assignedUserName,
  });

  bool get isAssigned => assignedUserId != null && assignedUserId!.isNotEmpty;

  factory RoleModel.fromFirestore(DocumentSnapshot doc, String productionId, [String? assignedUserName]) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return RoleModel(
      id: doc.id,
      productionId: productionId,
      name: data['name'] as String? ?? '',
      assignedUserId: data['assignedUserId'] as String?,
      assignedUserName: assignedUserName,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'assignedUserId': assignedUserId,
    };
  }

  RoleModel copyWith({
    String? id,
    String? productionId,
    String? name,
    String? assignedUserId,
    String? assignedUserName,
  }) {
    return RoleModel(
      id: id ?? this.id,
      productionId: productionId ?? this.productionId,
      name: name ?? this.name,
      assignedUserId: assignedUserId ?? this.assignedUserId,
      assignedUserName: assignedUserName ?? this.assignedUserName,
    );
  }
}
