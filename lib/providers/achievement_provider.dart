import 'package:flutter/material.dart';
import 'package:khelpratibha/models/achievement.dart';
import 'package:khelpratibha/services/database_service.dart';

class AchievementProvider extends ChangeNotifier {
  final DatabaseService _db;
  AchievementProvider(this._db);

  List<Achievement> _achievements = [];
  bool _isLoading = false;

  List<Achievement> get achievements => _achievements;
  bool get isLoading => _isLoading;

  void clearData() {
    _achievements = [];
    notifyListeners();
  }

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

  Future<void> checkAndUnlockAchievements(int pushupReps, int situpReps) async {
    final unlockedKeys =
    _achievements.where((a) => a.isUnlocked).map((a) => a.key).toSet();

    final achievementIdMap = {for (var a in _achievements) a.key: a.id};

    Future<void> unlock(String key) async {
      if (!unlockedKeys.contains(key) && achievementIdMap.containsKey(key)) {
        await _db.unlockAchievement(achievementIdMap[key]!);
      }
    }

    // --- Achievement Logic ---
    await unlock('first_strength_test');

    if (pushupReps >= 50) {
      await unlock('pushup_pro');
    }
    if (situpReps >= 100) {
      await unlock('situp_star');
    }

    await fetchAchievements();
  }
}