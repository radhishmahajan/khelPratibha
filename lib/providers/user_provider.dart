import 'package:flutter/material.dart';
import 'package:khelpratibha/models/user_profile.dart';
import 'package:khelpratibha/services/database_service.dart';

class UserProvider extends ChangeNotifier {
  final DatabaseService _db;
  UserProvider(this._db);

  UserProfile? _userProfile;
  // The isLoading flag can be removed as FutureBuilder will manage loading states.
  // bool _isLoading = false;

  UserProfile? get userProfile => _userProfile;
  // bool get isLoading => _isLoading;

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
