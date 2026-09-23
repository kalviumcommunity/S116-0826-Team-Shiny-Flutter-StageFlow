import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:stagesync/models/production_model.dart';
import 'package:stagesync/services/production_service.dart';
import 'package:stagesync/services/storage_service.dart';

class ProductionsViewModel extends ChangeNotifier {
  ProductionsViewModel({
    required ProductionService productionService,
    required StorageService storageService,
  })  : _productionService = productionService,
        _storageService = storageService;

  final ProductionService _productionService;
  final StorageService _storageService;

  StreamSubscription<List<ProductionModel>>? _productionsSubscription;

  List<ProductionModel> productions = const <ProductionModel>[];
  bool isLoading = false;
  String? errorMessage;

  void startWatching(String uid) {
    _productionsSubscription?.cancel();
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    _productionsSubscription =
        _productionService.watchMyProductions(uid).listen(
      (data) {
        productions = data;
        isLoading = false;
        errorMessage = null;
        notifyListeners();
      },
      onError: (Object error) {
        isLoading = false;
        errorMessage = 'Failed to load productions: $error';
        notifyListeners();
      },
    );
  }

  Future<ProductionModel?> getProduction(String prodId) async {
    try {
      final existing = productions.where((p) => p.id == prodId);
      if (existing.isNotEmpty) {
        return existing.first;
      }
      return await _productionService.getProduction(prodId);
    } catch (e) {
      errorMessage = 'Failed to fetch production: $e';
      notifyListeners();
      return null;
    }
  }

  Future<bool> createProduction({
    required String title,
    required String description,
    required DateTime startDate,
    required DateTime endDate,
    required String directorId,
    File? posterFile,
  }) async {
    if (startDate.isAfter(endDate)) {
      isLoading = false;
      errorMessage = 'Start date cannot be after end date.';
      notifyListeners();
      return false;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      String? imageURL;
      final tempProd = ProductionModel(
        title: title.trim(),
        description: description.trim(),
        startDate: startDate,
        endDate: endDate,
        directorId: directorId,
        imageURL: null,
        memberIds: <String>[directorId],
        createdAt: DateTime.now(),
      );

      final newProdId = await _productionService.createProduction(tempProd);

      if (posterFile != null) {
        imageURL = await _storageService.uploadProductionPoster(
          newProdId,
          posterFile,
        );
        if (imageURL != null && imageURL.isNotEmpty) {
          await _productionService.updateProduction(newProdId, {
            'imageURL': imageURL,
          });
        }
      }

      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = 'Failed to create production: $e';
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProduction({
    required String prodId,
    required String title,
    required String description,
    required DateTime startDate,
    required DateTime endDate,
    File? newPosterFile,
    String? existingImageURL,
  }) async {
    if (startDate.isAfter(endDate)) {
      isLoading = false;
      errorMessage = 'Start date cannot be after end date.';
      notifyListeners();
      return false;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      String? imageURL = existingImageURL;
      if (newPosterFile != null) {
        final uploadedUrl = await _storageService.uploadProductionPoster(
          prodId,
          newPosterFile,
        );
        if (uploadedUrl != null && uploadedUrl.isNotEmpty) {
          imageURL = uploadedUrl;
        }
      }

      final updates = <String, dynamic>{
        'title': title.trim(),
        'description': description.trim(),
        'startDate': startDate,
        'endDate': endDate,
        'imageURL': imageURL,
      };

      await _productionService.updateProduction(prodId, updates);
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = 'Failed to update production: $e';
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteProduction(String prodId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _productionService.deleteProduction(prodId);
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = 'Failed to delete production: $e';
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void stopWatching() {
    _productionsSubscription?.cancel();
    _productionsSubscription = null;
    productions = const <ProductionModel>[];
    isLoading = false;
    errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    stopWatching();
    super.dispose();
  }
}
