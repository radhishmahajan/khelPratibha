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

  Future<void> leaveProgram({required String programId}) async {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null || !_joinedProgramIds.contains(programId)) return;

    await _db.leaveProgram(userId: userId, programId: programId);
    _joinedProgramIds.remove(programId);
    notifyListeners();
  }

  Future<void> fetchUserProfile(String userId) async {
    try {
      _userProfile = await _db.fetchUserProfile(userId);
    } finally {
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

  void setUserProfile(UserProfile profile) {
    _userProfile = profile;
    notifyListeners();
  }

  void clearUserProfile() {
    _userProfile = null;
    notifyListeners();
  }
}