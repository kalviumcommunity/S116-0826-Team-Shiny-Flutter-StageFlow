import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:stagesync/models/audition_model.dart';
import 'package:stagesync/services/audition_service.dart';

class AuditionsViewModel extends ChangeNotifier {
  AuditionsViewModel({
    required AuditionService auditionService,
  }) : _auditionService = auditionService;

  final AuditionService _auditionService;
  StreamSubscription<List<AuditionModel>>? _auditionsSubscription;

  List<AuditionModel> auditions = const <AuditionModel>[];
  bool isLoading = false;
  String? errorMessage;

  void startWatching(String prodId) {
    _auditionsSubscription?.cancel();
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    _auditionsSubscription = _auditionService.watchAuditions(prodId).listen(
      (data) {
        auditions = data;
        isLoading = false;
        errorMessage = null;
        notifyListeners();
      },
      onError: (Object error) {
        isLoading = false;
        errorMessage = 'Failed to load auditions: $error';
        notifyListeners();
      },
    );
  }

  Future<bool> createAudition(String prodId, AuditionModel audition) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _auditionService.createAudition(prodId, audition);
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = 'Failed to create audition slot: $e';
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateAudition(String prodId, AuditionModel audition) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _auditionService.updateAudition(prodId, audition);
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = 'Failed to update audition slot: $e';
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteAudition(String prodId, String audId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _auditionService.deleteAudition(prodId, audId);
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = 'Failed to delete audition slot: $e';
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUp(String prodId, String audId, String userId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _auditionService.signUp(prodId, audId, userId);
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = 'Failed to sign up for audition: $e';
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> withdraw(String prodId, String audId, String userId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _auditionService.withdraw(prodId, audId, userId);
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = 'Failed to withdraw from audition: $e';
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void stopWatching() {
    _auditionsSubscription?.cancel();
    _auditionsSubscription = null;
    auditions = const <AuditionModel>[];
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
