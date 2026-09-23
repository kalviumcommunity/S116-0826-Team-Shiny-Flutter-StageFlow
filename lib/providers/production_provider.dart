import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../models/production.dart';
import '../models/role_model.dart';
import '../models/event_model.dart';
import '../models/audition.dart';
import '../models/app_user.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';

class ProductionProvider extends ChangeNotifier {
  final FirestoreService _firestoreService;
  final StorageService _storageService;

  List<Production> _productions = [];
  List<AppUser> _allUsers = [];
  Map<String, AppUser> _usersMap = {};

  Production? _selectedProduction;
  List<RoleModel> _currentRoles = [];
  List<EventModel> _currentEvents = [];
  List<Audition> _currentAuditions = [];
  List<Audition> _allAuditions = [];

  bool _isLoading = false;
  bool _isUploadingPoster = false;
  double _uploadProgress = 0.0;
  String? _errorMessage;

  StreamSubscription? _productionsSub;
  StreamSubscription? _rolesSub;
  StreamSubscription? _eventsSub;
  StreamSubscription? _auditionsSub;
  StreamSubscription? _allAuditionsSub;

  ProductionProvider({
    FirestoreService? firestoreService,
    StorageService? storageService,
  })  : _firestoreService = firestoreService ?? FirestoreService(),
        _storageService = storageService ?? StorageService();

  List<Production> get productions => _productions;
  List<AppUser> get allUsers => _allUsers;
  Map<String, AppUser> get usersMap => _usersMap;
  Production? get selectedProduction => _selectedProduction;
  List<RoleModel> get currentRoles => _currentRoles;
  List<EventModel> get currentEvents => _currentEvents;
  List<Audition> get currentAuditions => _currentAuditions;
  List<Audition> get allAuditions => _allAuditions;
  bool get isLoading => _isLoading;
  bool get isUploadingPoster => _isUploadingPoster;
  double get uploadProgress => _uploadProgress;
  String? get errorMessage => _errorMessage;

  void fetchInitialData(String? currentUserId, bool isDirector) {
    _loadUsers();
    _subscribeProductions(currentUserId, isDirector);
    _subscribeAllAuditions();
  }

  void _subscribeAllAuditions() {
    _allAuditionsSub?.cancel();
    _allAuditionsSub = _firestoreService.getAllAuditionsStream().listen((list) {
      _allAuditions = list;
      notifyListeners();
    }, onError: (err) {
      debugPrint('Error listening to all auditions: $err');
    });
  }

  Future<void> _loadUsers() async {
    try {
      _allUsers = await _firestoreService.getAllUsers();
      _usersMap = {for (var u in _allUsers) u.id: u};
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading users: $e');
    }
  }

  void _subscribeProductions(String? userId, bool isDirector) {
    _productionsSub?.cancel();
    if (userId == null) return;

    if (isDirector) {
      _productionsSub = _firestoreService.getDirectorProductionsStream(userId).listen((list) {
        _productions = list;
        notifyListeners();
      }, onError: (err) {
        _errorMessage = err.toString();
        notifyListeners();
      });
    } else {
      // Cast member sees all active productions they might be cast in
      _productionsSub = _firestoreService.getProductionsStream().listen((list) {
        _productions = list;
        notifyListeners();
      }, onError: (err) {
        _errorMessage = err.toString();
        notifyListeners();
      });
    }
  }

  void selectProduction(Production prod) {
    _selectedProduction = prod;
    _subscribeSubcollections(prod.id);
    notifyListeners();
  }

  void _subscribeSubcollections(String productionId) {
    _rolesSub?.cancel();
    _eventsSub?.cancel();
    _auditionsSub?.cancel();

    _rolesSub = _firestoreService.getRolesStream(productionId).listen((roles) {
      _currentRoles = roles.map((r) {
        final assignedName = r.assignedUserId != null ? _usersMap[r.assignedUserId]?.name : null;
        return r.copyWith(assignedUserName: assignedName);
      }).toList();
      notifyListeners();
    });

    _eventsSub = _firestoreService.getProductionEventsStream(productionId, _selectedProduction?.title).listen((events) {
      _currentEvents = events;
      notifyListeners();
    });

    _auditionsSub = _firestoreService.getProductionAuditionsStream(productionId, _selectedProduction?.title).listen((auds) {
      _currentAuditions = auds;
      notifyListeners();
    });
  }

  Future<bool> createProduction({
    required String title,
    required String description,
    required DateTime startDate,
    required DateTime endDate,
    required String directorId,
    XFile? posterImage,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final newProd = Production(
        id: '',
        title: title.trim(),
        description: description.trim(),
        startDate: startDate,
        endDate: endDate,
        directorId: directorId,
      );

      final docId = await _firestoreService.createProduction(newProd);

      String? uploadedUrl;
      if (posterImage != null) {
        _isUploadingPoster = true;
        notifyListeners();

        uploadedUrl = await _storageService.uploadProductionPoster(
          productionId: docId,
          imageFile: posterImage,
          onProgress: (p) {
            _uploadProgress = p;
            notifyListeners();
          },
        );

        if (uploadedUrl != null) {
          await _firestoreService.updateProduction(
            newProd.copyWith(id: docId, imageURL: uploadedUrl),
          );
        }
      }

      _isLoading = false;
      _isUploadingPoster = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      _isUploadingPoster = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProduction({
    required Production production,
    XFile? newPosterImage,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      String? imageUrl = production.imageURL;
      if (newPosterImage != null) {
        _isUploadingPoster = true;
        notifyListeners();

        imageUrl = await _storageService.uploadProductionPoster(
          productionId: production.id,
          imageFile: newPosterImage,
          onProgress: (p) {
            _uploadProgress = p;
            notifyListeners();
          },
        );
      }

      final updated = production.copyWith(imageURL: imageUrl);
      await _firestoreService.updateProduction(updated);

      if (_selectedProduction?.id == production.id) {
        _selectedProduction = updated;
      }

      _isLoading = false;
      _isUploadingPoster = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      _isUploadingPoster = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteProduction(String productionId) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _storageService.deleteProductionPoster(productionId);
      await _firestoreService.deleteProduction(productionId);

      if (_selectedProduction?.id == productionId) {
        _selectedProduction = null;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Role management
  Future<void> addRole(String name, String? assignedUserId) async {
    if (_selectedProduction == null) return;
    await _firestoreService.addRole(
      productionId: _selectedProduction!.id,
      roleName: name,
      assignedUserId: assignedUserId,
    );
  }

  Future<void> updateRole(String roleId, String name, String? assignedUserId) async {
    if (_selectedProduction == null) return;
    await _firestoreService.updateRole(
      productionId: _selectedProduction!.id,
      roleId: roleId,
      roleName: name,
      assignedUserId: assignedUserId,
    );
  }

  Future<void> deleteRole(String roleId) async {
    if (_selectedProduction == null) return;
    await _firestoreService.deleteRole(_selectedProduction!.id, roleId);
  }

  // Audition management
  Future<void> createAudition({
    required DateTime date,
    required String time,
    required String venue,
  }) async {
    if (_selectedProduction == null) return;
    final audition = Audition(
      id: '',
      productionId: _selectedProduction!.id,
      productionTitle: _selectedProduction!.title,
      date: date,
      time: time,
      venue: venue,
      castIds: const [],
    );
    await _firestoreService.createAudition(audition);
  }

  Future<void> deleteAudition(String auditionId, [String? productionId]) async {
    final prodId = productionId ?? _selectedProduction?.id;
    if (prodId == null) return;
    await _firestoreService.deleteAudition(prodId, auditionId);
  }

  Future<void> signUpForAudition(String auditionId, String userId, [String? productionId]) async {
    final prodId = productionId ?? _selectedProduction?.id;
    if (prodId == null) return;
    await _firestoreService.signUpForAudition(
      productionId: prodId,
      auditionId: auditionId,
      userId: userId,
    );
  }

  @override
  void dispose() {
    _productionsSub?.cancel();
    _rolesSub?.cancel();
    _eventsSub?.cancel();
    _auditionsSub?.cancel();
    _allAuditionsSub?.cancel();
    super.dispose();
  }
}
