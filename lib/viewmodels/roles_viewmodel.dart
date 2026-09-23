import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:stagesync/models/role_model.dart';
import 'package:stagesync/models/user_model.dart';
import 'package:stagesync/services/role_service.dart';

class RolesViewModel extends ChangeNotifier {
  RolesViewModel({
    required RoleService roleService,
  }) : _roleService = roleService;

  final RoleService _roleService;
  StreamSubscription<List<RoleModel>>? _rolesSubscription;

  List<RoleModel> roles = const <RoleModel>[];
  List<UserModel> castUsers = const <UserModel>[];
  bool isLoading = false;
  String? errorMessage;

  void startWatching(String prodId) {
    _rolesSubscription?.cancel();
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    _rolesSubscription = _roleService.watchRoles(prodId).listen(
      (data) {
        roles = data;
        isLoading = false;
        errorMessage = null;
        notifyListeners();
      },
      onError: (Object error) {
        isLoading = false;
        errorMessage = 'Failed to load roles: $error';
        notifyListeners();
      },
    );

    loadCastUsers();
  }

  Future<void> loadCastUsers() async {
    try {
      castUsers = await _roleService.getAllCastUsers();
      notifyListeners();
    } catch (e) {
      // Non-critical, but log
      debugPrint('Failed to load cast users: $e');
    }
  }

  Future<bool> addRole(String prodId, String name) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _roleService.addRole(prodId, name);
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = 'Failed to add role: $e';
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> assignRole(String prodId, String roleId, String userId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _roleService.assignRole(prodId, roleId, userId);
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = 'Failed to assign role: $e';
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> unassignRole(String prodId, String roleId) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _roleService.unassignRole(prodId, roleId);
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = 'Failed to unassign role: $e';
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _rolesSubscription?.cancel();
    super.dispose();
  }
}
