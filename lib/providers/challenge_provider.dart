// lib/providers/challenge_provider.dart
import 'package:flutter/material.dart';
import 'package:khelpratibha/models/challenge.dart';
import 'package:khelpratibha/models/challenge_leaderboard_entry.dart';
import 'package:khelpratibha/services/database_service.dart';

class ChallengeProvider extends ChangeNotifier {
  final DatabaseService _db;
  ChallengeProvider(this._db);

  List<Challenge> _availableChallenges = [];
  List<Challenge> _joinedChallenges = [];
  bool _isLoading = false;

  List<Challenge> get availableChallenges => _availableChallenges;
  List<Challenge> get joinedChallenges => _joinedChallenges;
  bool get isLoading => _isLoading;

  void clearData() {
    _availableChallenges = [];
    _joinedChallenges = [];
    notifyListeners();
  }

  Future<void> fetchChallenges() async {
    _isLoading = true;
    notifyListeners();
    try {
      final allChallenges = await _db.fetchChallenges();
      final joinedChallenges = await _db.fetchJoinedChallenges();

      _joinedChallenges = joinedChallenges;

      final joinedIds = joinedChallenges.map((c) => c.id).toSet();
      _availableChallenges = allChallenges.where((c) => !joinedIds.contains(c.id)).toList();

    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> joinChallenge(String challengeId) async {
    await _db.joinChallenge(challengeId);
    await fetchChallenges();
  }

  Future<List<ChallengeLeaderboardEntry>> fetchChallengeLeaderboard(String challengeId) async {
    return await _db.fetchChallengeLeaderboard(challengeId);
  }

  Future<void> saveChallengeResult({
    required String challengeId,
    required double score,
    required int reps,
    required String testName,
  }) async {
    await _db.saveChallengeResult(challengeId: challengeId, score: score, reps: reps, testName: testName);
    await fetchChallenges();
  }
}