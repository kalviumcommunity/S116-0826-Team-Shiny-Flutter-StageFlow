import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  StorageService({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;

  Future<String> uploadProductionPoster(
    String prodId,
    File imageFile,
  ) async {
    final ref = _storage.ref('posters/$prodId.jpg');
    await ref.putFile(imageFile);
    return ref.getDownloadURL();
  }
}