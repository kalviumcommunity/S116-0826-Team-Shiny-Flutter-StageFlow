import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stagesync/models/user_model.dart';

class UserService {
  UserService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  static const Set<String> allowedEditableFields = {'name', 'photoURL'};

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  Future<void> createUserProfile(UserModel user) async {
    await _usersCollection.doc(user.uid).set(user.toMap());
  }

  Future<UserModel?> getUserProfile(String uid) async {
    final doc = await _usersCollection.doc(uid).get();
    if (!doc.exists) {
      return null;
    }
    return UserModel.fromDoc(doc);
  }

  Future<UserModel?> getCurrentUserProfile() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      return null;
    }
    return getUserProfile(uid);
  }

  Future<void> updateUserProfile({
    required String uid,
    required Map<String, dynamic> data,
  }) async {
    final trimmedUid = uid.trim();
    if (trimmedUid.isEmpty) {
      throw ArgumentError('User ID cannot be empty.');
    }

    final authenticatedUid = _auth.currentUser?.uid;
    if (authenticatedUid == null) {
      throw StateError('Cannot update profile: No authenticated user.');
    }

    if (authenticatedUid != trimmedUid) {
      throw StateError(
        'User is not authorized to update another user\'s profile.',
      );
    }

    if (data.isEmpty) {
      throw ArgumentError('Update data cannot be empty.');
    }

    final invalidKeys =
        data.keys.where((k) => !allowedEditableFields.contains(k)).toList();
    if (invalidKeys.isNotEmpty) {
      throw ArgumentError(
        'Cannot update protected field(s): ${invalidKeys.join(', ')}. Only editable fields ($allowedEditableFields) can be updated.',
      );
    }

    if (data.containsKey('name')) {
      final name = data['name'];
      if (name is! String || name.trim().isEmpty) {
        throw ArgumentError('Name must be a non-empty string.');
      }
    }

    await _usersCollection.doc(trimmedUid).update(data);
  }

  Future<void> updateProfileFields({
    required String uid,
    String? name,
    String? photoURL,
  }) async {
    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name.trim();
    if (photoURL != null) {
      updates['photoURL'] =
          photoURL.trim().isEmpty ? null : photoURL.trim();
    }
    await updateUserProfile(uid: uid, data: updates);
  }

  Stream<UserModel?> watchUserProfile(String uid) {
    return _usersCollection.doc(uid).snapshots().map((doc) {
      if (!doc.exists) {
        return null;
      }
      return UserModel.fromDoc(doc);
    });
  }
}
