import 'package:flutter/material.dart';
import 'package:khelpratibha/models/performance_session.dart';
import 'package:khelpratibha/services/database_service.dart';

class SessionProvider extends ChangeNotifier {
  final DatabaseService _db;
  SessionProvider(this._db);

  List<PerformanceSession> _sessions = [];
  bool _isLoading = false;

  List<PerformanceSession> get sessions => _sessions;
  bool get isLoading => _isLoading;

  Future<void> fetchSessions(String programId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _sessions = await _db.fetchSessions(programId);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}