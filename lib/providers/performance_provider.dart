import 'package:flutter/material.dart';
import 'package:khelpratibha/models/performance_session.dart';
import 'package:khelpratibha/services/database_service.dart';
import 'dart:math';

class PerformanceProvider extends ChangeNotifier {
  final DatabaseService _db;
  PerformanceProvider(this._db);

  List<PerformanceSession> _performanceHistory = [];
  List<Map<String, dynamic>> _personalBests = [];
  bool _isLoading = false;

  List<PerformanceSession> get performanceHistory => _performanceHistory;
  List<Map<String, dynamic>> get personalBests => _personalBests;
  bool get isLoading => _isLoading;

  double get bestScore {
    if (_performanceHistory.isEmpty) return 0;
    return _performanceHistory.map((s) => s.score).reduce(max);
  }

  double get averageScore {
    if (_performanceHistory.isEmpty) return 0;
    return _performanceHistory.map((s) => s.score).reduce((a, b) => a + b) /
        _performanceHistory.length;
  }

  Future<void> fetchPerformanceHistory() async {
    _isLoading = true;
    notifyListeners();
    try {
      _performanceHistory = await _db.fetchPerformanceHistory();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchPersonalBests() async {
    _isLoading = true;
    notifyListeners();
    try {
      _personalBests = await _db.fetchPersonalBests();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  PerformanceSession? getPreviousBestSession(PerformanceSession currentSession) {
    // Get all sessions for the same test that occurred before the current one
    final previousSessionsForTest = _performanceHistory.where((s) =>
    s.testName == currentSession.testName &&
        s.recordedAt.isBefore(currentSession.recordedAt)).toList();

    // If there are no previous sessions, there's no best to compare to
    if (previousSessionsForTest.isEmpty) {
      return null;
    }

    // Find the session with the maximum score among the previous ones
    previousSessionsForTest.sort((a, b) => b.score.compareTo(a.score));
    return previousSessionsForTest.first;
  }
}