import 'package:flutter/material.dart';
import 'package:khelpratibha/models/achievement.dart';
import 'package:khelpratibha/models/performance_session.dart';
import 'package:khelpratibha/services/database_service.dart';

class AchievementProvider extends ChangeNotifier {
  final DatabaseService _db;
  AchievementProvider(this._db);

  List<Achievement> _achievements = [];
  bool _isLoading = false;

  List<Achievement> get achievements => _achievements;
  bool get isLoading => _isLoading;

  Future<void> fetchAchievements() async {
    _isLoading = true;
    notifyListeners();
    try {
      _achievements = await _db.fetchAchievements();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> checkAndUnlockAchievements(List<PerformanceSession> sessions, String currentLevel) async {
    final unlockedKeys =
    _achievements.where((a) => a.isUnlocked).map((a) => a.key).toSet();

    final achievementIdMap = {for (var a in _achievements) a.key: a.id};

    Future<void> unlock(String key) async {
      if (!unlockedKeys.contains(key) && achievementIdMap.containsKey(key)) {
        await _db.unlockAchievement(achievementIdMap[key]!);
      }
    }

    // --- Achievement Logic ---
    if (sessions.isNotEmpty) {
      await unlock('first_session');
    }
    if (sessions.length >= 5) {
      await unlock('video_virtuoso');
    }
    if (sessions.length >= 10) {
      await unlock('consistent_performer');
    }
    if (sessions.any((s) => s.score >= 85)) {
      await unlock('high_scorer');
    }
    if (currentLevel.toLowerCase() == 'advanced') {
      await unlock('top_tier');
    }

    final sessionsThisWeek = sessions.where((s) => s.createdAt.isAfter(DateTime.now().subtract(const Duration(days: 7))));
    if (sessionsThisWeek.length >= 3) {
      await unlock('weekly_warrior');
    }

    await fetchAchievements();
  }
}