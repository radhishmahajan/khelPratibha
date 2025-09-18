import 'package:flutter/material.dart';
import 'package:khelpratibha/models/leaderboard_entry.dart';
import 'package:khelpratibha/services/database_service.dart';

class LeaderboardProvider extends ChangeNotifier {
  final DatabaseService _db;
  LeaderboardProvider(this._db);

  List<LeaderboardEntry> _leaderboard = [];
  bool _isLoading = false;
  List<LeaderboardEntry> _activityLeaderboard = [];
  bool _isActivityLoading = false;


  List<LeaderboardEntry> get leaderboard => _leaderboard;
  bool get isLoading => _isLoading;
  List<LeaderboardEntry> get activityLeaderboard => _activityLeaderboard;
  bool get isActivityLoading => _isActivityLoading;

  Future<void> fetchLeaderboard() async {
    _isLoading = true;
    notifyListeners();
    try {
      _leaderboard = await _db.fetchLeaderboard();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchLeaderboardForTest(String testName) async {
    _isActivityLoading = true;
    notifyListeners();
    try {
      _activityLeaderboard = await _db.fetchLeaderboardForTest(testName);
    } finally {
      _isActivityLoading = false;
      notifyListeners();
    }
  }
}