import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stagesync/models/user_model.dart';

class UserService {
  UserService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

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

  Stream<UserModel?> watchUserProfile(String uid) {
    return _usersCollection.doc(uid).snapshots().map((doc) {
      if (!doc.exists) {
        return null;
      }
      return UserModel.fromDoc(doc);
    });
  }
}
