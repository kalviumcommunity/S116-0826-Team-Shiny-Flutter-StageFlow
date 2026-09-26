import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:stagesync/models/audition_model.dart';
import 'package:stagesync/models/event_model.dart';
import 'package:stagesync/models/production_model.dart';
import 'package:stagesync/models/role_model.dart';
import 'package:stagesync/models/user_model.dart';
import 'package:stagesync/services/audition_service.dart';
import 'package:stagesync/services/auth_service.dart';
import 'package:stagesync/services/event_service.dart';
import 'package:stagesync/services/production_service.dart';
import 'package:stagesync/services/role_service.dart';
import 'package:stagesync/services/storage_service.dart';
import 'package:stagesync/services/user_service.dart';

const String _kUninitializedMsg =
    'Firebase is not initialized for this platform. Please configure Firebase to enable cloud features.';

/// Safe uninitialized delegate for [AuthService] when Firebase is unavailable.
/// Returns null/unauthenticated state without fake users or fake authentication.
class UninitializedAuthService implements AuthService {
  @override
  Stream<User?> get authStateChanges => Stream<User?>.value(null);

  @override
  String? get currentUserId => null;

  @override
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    throw AuthException(_kUninitializedMsg);
  }

  @override
  Future<UserCredential> signUp({
    required String email,
    required String password,
  }) async {
    throw AuthException(_kUninitializedMsg);
  }

  @override
  Future<void> signOut() async {}

  @override
  Future<void> deleteCurrentUser() async {}

  @override
  Future<bool> sendPasswordResetEmail(String email) async {
    throw AuthException(_kUninitializedMsg);
  }
}

/// Safe uninitialized delegate for [UserService] when Firebase is unavailable.
class UninitializedUserService implements UserService {
  @override
  Future<void> createUserProfile(UserModel user) async {
    throw Exception(_kUninitializedMsg);
  }

  @override
  Future<UserModel?> getUserProfile(String uid) async => null;

  @override
  Future<UserModel?> getCurrentUserProfile() async => null;

  @override
  Future<void> updateUserProfile({
    required String uid,
    required Map<String, dynamic> data,
  }) async {
    throw Exception(_kUninitializedMsg);
  }

  @override
  Future<void> updateProfileFields({
    required String uid,
    String? name,
    String? photoURL,
  }) async {
    throw Exception(_kUninitializedMsg);
  }

  @override
  Stream<UserModel?> watchUserProfile(String uid) =>
      Stream<UserModel?>.value(null);
}

/// Safe uninitialized delegate for [ProductionService] when Firebase is unavailable.
/// Provides empty production streams without fabricating fake records.
class UninitializedProductionService implements ProductionService {
  @override
  Future<String> createProduction(ProductionModel production) async {
    throw Exception(_kUninitializedMsg);
  }

  @override
  Future<void> updateProduction(
    String prodId,
    Map<String, dynamic> updates,
  ) async {
    throw Exception(_kUninitializedMsg);
  }

  @override
  Future<void> deleteProduction(String prodId) async {
    throw Exception(_kUninitializedMsg);
  }

  @override
  Stream<List<ProductionModel>> watchMyProductions(String uid) =>
      Stream<List<ProductionModel>>.value(<ProductionModel>[]);

  @override
  Future<ProductionModel?> getProduction(String prodId) async => null;

  @override
  Future<void> addMemberId(String prodId, String userId) async {
    throw Exception(_kUninitializedMsg);
  }
}

/// Safe uninitialized delegate for [StorageService] when Firebase is unavailable.
class UninitializedStorageService implements StorageService {
  @override
  FirebaseStorage? get storage => null;

  @override
  Future<String?> uploadProductionPoster(
    String prodId,
    File imageFile,
  ) async =>
      null;
}

/// Safe uninitialized delegate for [EventService] when Firebase is unavailable.
class UninitializedEventService implements EventService {
  @override
  DateTime normalizeDate(DateTime date) =>
      DateTime.utc(date.year, date.month, date.day);

  @override
  Future<String> createEvent(String prodId, EventModel newEvent) async {
    throw Exception(_kUninitializedMsg);
  }

  @override
  Future<void> updateEvent(
    String prodId,
    String eventId,
    EventModel updatedEvent,
  ) async {
    throw Exception(_kUninitializedMsg);
  }

  @override
  Future<void> deleteEvent(String prodId, String eventId) async {
    throw Exception(_kUninitializedMsg);
  }

  @override
  Stream<List<EventModel>> watchEvents(String prodId) =>
      Stream<List<EventModel>>.value(<EventModel>[]);
}

/// Safe uninitialized delegate for [RoleService] when Firebase is unavailable.
class UninitializedRoleService implements RoleService {
  UninitializedRoleService({ProductionService? productionService})
      : _productionService =
            productionService ?? UninitializedProductionService();

  final ProductionService _productionService;

  @override
  ProductionService get productionService => _productionService;

  @override
  Future<String> addRole(String prodId, String name) async {
    throw Exception(_kUninitializedMsg);
  }

  @override
  Future<void> updateRole(String prodId, RoleModel role) async {
    throw Exception(_kUninitializedMsg);
  }

  @override
  Future<void> deleteRole(String prodId, String roleId) async {
    throw Exception(_kUninitializedMsg);
  }

  @override
  Future<void> assignRole(
      String prodId, String roleId, String userId) async {
    throw Exception(_kUninitializedMsg);
  }

  @override
  Future<void> unassignRole(String prodId, String roleId) async {
    throw Exception(_kUninitializedMsg);
  }

  @override
  Stream<List<RoleModel>> watchRoles(String prodId) =>
      Stream<List<RoleModel>>.value(<RoleModel>[]);

  @override
  Future<List<UserModel>> getAllCastUsers() async => <UserModel>[];
}

/// Safe uninitialized delegate for [AuditionService] when Firebase is unavailable.
class UninitializedAuditionService implements AuditionService {
  UninitializedAuditionService({ProductionService? productionService})
      : _productionService =
            productionService ?? UninitializedProductionService();

  final ProductionService? _productionService;

  @override
  ProductionService? get productionService => _productionService;

  @override
  Future<String> createAudition(
      String prodId, AuditionModel audition) async {
    throw Exception(_kUninitializedMsg);
  }

  @override
  Future<void> updateAudition(
      String prodId, AuditionModel audition) async {
    throw Exception(_kUninitializedMsg);
  }

  @override
  Future<void> deleteAudition(String prodId, String audId) async {
    throw Exception(_kUninitializedMsg);
  }

  @override
  Future<void> signUp(String prodId, String audId, String userId) async {
    throw Exception(_kUninitializedMsg);
  }

  @override
  Future<void> withdraw(String prodId, String audId, String userId) async {
    throw Exception(_kUninitializedMsg);
  }

  @override
  Stream<List<AuditionModel>> watchAuditions(String prodId) =>
      Stream<List<AuditionModel>>.value(<AuditionModel>[]);
}
