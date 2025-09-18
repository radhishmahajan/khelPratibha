import 'package:flutter/material.dart';
import 'package:khelpratibha/models/leaderboard_entry.dart';
import 'package:khelpratibha/services/database_service.dart';

class LeaderboardProvider extends ChangeNotifier {
  final DatabaseService _db;
  LeaderboardProvider(this._db);

  List<LeaderboardEntry> _leaderboard = [];
  bool _isLoading = false;

  List<LeaderboardEntry> get leaderboard => _leaderboard;
  bool get isLoading => _isLoading;

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
}