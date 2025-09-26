import 'package:flutter/material.dart';
import 'package:khelpratibha/models/user_profile.dart';
import 'package:khelpratibha/services/database_service.dart';

class UserProvider extends ChangeNotifier {
  final DatabaseService _db;
  UserProvider(this._db);

  UserProfile? _userProfile;
  bool _isLoading = false;

  UserProfile? get userProfile => _userProfile;
  bool get isLoading => _isLoading;

  Future<void> fetchInitialData(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _userProfile = await _db.fetchUserProfile(userId);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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

  void clearData() {
    _userProfile = null;
    notifyListeners();
  }
}