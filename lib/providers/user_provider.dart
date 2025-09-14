import 'package:flutter/material.dart';
import 'package:khelpratibha/models/user_profile.dart';
import 'package:khelpratibha/services/database_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserProvider extends ChangeNotifier {
  final DatabaseService _db;
  UserProvider(this._db);

  UserProfile? _userProfile;
  List<String> _joinedProgramIds = [];
  bool _isLoading = false;

  UserProfile? get userProfile => _userProfile;
  List<String> get joinedProgramIds => _joinedProgramIds;
  bool get isLoading => _isLoading;

  Future<void> fetchInitialData(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      // Fetch user profile and joined programs in parallel
      final profileFuture = _db.fetchUserProfile(userId);
      final programsFuture = _db.fetchJoinedProgramIds(userId);

      final results = await Future.wait([profileFuture, programsFuture]);
      _userProfile = results[0] as UserProfile?;
      _joinedProgramIds = results[1] as List<String>;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> joinProgram({required String programId}) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null || _joinedProgramIds.contains(programId)) return;

    await _db.joinProgram(userId: userId, programId: programId);
    _joinedProgramIds.add(programId);
    notifyListeners();
  }

  Future<void> fetchUserProfile(String userId) async {
    // We don't notify listeners at the start anymore.
    try {
      _userProfile = await _db.fetchUserProfile(userId);
    } finally {
      // We only notify listeners once, after the data fetching is complete.
      notifyListeners();
    }
  }

  Future<void> saveUserProfile(UserProfile profile) async {
    try {
      _userProfile = await _db.upsertUserProfile(profile);
    } finally {
      notifyListeners();
    }
  }

  /// A method to update the local state immediately after a profile edit.
  void setUserProfile(UserProfile profile) {
    _userProfile = profile;
    notifyListeners();
  }

  void clearUserProfile() {
    _userProfile = null;
    notifyListeners();
  }
}
