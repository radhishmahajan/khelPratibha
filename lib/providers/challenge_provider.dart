import 'package:flutter/material.dart';
import 'package:khelpratibha/models/challenge.dart';
import 'package:khelpratibha/models/challenge_leaderboard_entry.dart';
import 'package:khelpratibha/services/database_service.dart';

class ChallengeProvider extends ChangeNotifier {
  final DatabaseService _db;
  ChallengeProvider(this._db);

  List<Challenge> _challenges = [];
  bool _isLoading = false;

  List<Challenge> get challenges => _challenges;
  bool get isLoading => _isLoading;

  Future<void> fetchChallenges() async {
    _isLoading = true;
    notifyListeners();
    try {
      _challenges = await _db.fetchChallenges();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<ChallengeLeaderboardEntry>> fetchChallengeLeaderboard(String challengeId) async {
    return await _db.fetchChallengeLeaderboard(challengeId);
  }
}