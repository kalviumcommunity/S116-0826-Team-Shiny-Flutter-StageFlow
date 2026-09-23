import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  final FirebaseStorage? _injectedStorage;
  final ImagePicker _picker;

  StorageService({
    FirebaseStorage? storage,
    ImagePicker? picker,
  })  : _injectedStorage = storage,
        _picker = picker ?? ImagePicker();

  FirebaseStorage get _storage => _injectedStorage ?? FirebaseStorage.instance;

  /// Prompts user to pick an image from Gallery or Camera
  Future<XFile?> pickPosterImage({ImageSource source = ImageSource.gallery}) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1600,
        imageQuality: 85,
      );
      return image;
    } catch (e) {
      debugPrint('Error picking image: $e');
      return null;
    }
  }

  /// Uploads a poster image to `posters/{productionId}.jpg` and returns download URL.
  Future<String?> uploadProductionPoster({
    required String productionId,
    required XFile imageFile,
    Function(double progress)? onProgress,
  }) async {
    try {
      final ref = _storage.ref().child('posters/$productionId.jpg');
      UploadTask uploadTask;

      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {'productionId': productionId},
      );

      if (kIsWeb) {
        final bytes = await imageFile.readAsBytes();
        uploadTask = ref.putData(bytes, metadata);
      } else {
        final file = File(imageFile.path);
        uploadTask = ref.putFile(file, metadata);
      }

      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          onProgress(progress);
        });
      }

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      debugPrint('Firebase Storage upload error: $e');
      throw Exception('Failed to upload poster image: ${e.toString()}');
    }
  }

  /// Delete poster from Firebase Storage
  Future<void> deleteProductionPoster(String productionId) async {
    try {
      final ref = _storage.ref().child('posters/$productionId.jpg');
      await ref.delete();
    } catch (e) {
      debugPrint('Notice: Poster might already be deleted or not found: $e');
    }
  }
}
