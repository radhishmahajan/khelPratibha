import 'package:flutter/material.dart';
import 'package:khelpratibha/models/user_profile.dart';
import 'package:khelpratibha/services/database_service.dart';

class UserProvider extends ChangeNotifier {
  // CORRECTED: Accepts the DatabaseService via the constructor
  // instead of creating its own instance.
  final DatabaseService _db;
  UserProvider(this._db);

  UserProfile? _userProfile;
  bool _isLoading = false;

  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;

  Future<void> fetchUserProfile(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _userProfile = await _db.fetchUserProfile(userId);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveUserProfile(UserProfile profile) async {
    _isLoading = true;
    notifyListeners();
    try {
      _userProfile = await _db.upsertUserProfile(profile);
    } finally {
      _isLoading = false;
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

