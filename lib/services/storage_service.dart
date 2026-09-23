import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  StorageService({FirebaseStorage? storage}) : _storage = storage;

  final FirebaseStorage? _storage;

  FirebaseStorage? get storage => _storage;

  Future<String?> uploadProductionPoster(
    String prodId,
    File imageFile,
  ) async {
    // Firebase Storage upload is bypassed for now to allow production creation
    // without requiring an active Storage bucket.
    return null;
  }
}
