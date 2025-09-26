import 'package:flutter/material.dart';
import 'package:khelpratibha/models/goal.dart';
import 'package:khelpratibha/services/database_service.dart';

class GoalProvider extends ChangeNotifier {
  final DatabaseService _db;
  GoalProvider(this._db);

  List<Goal> _goals = [];
  bool _isLoading = false;

  List<Goal> get goals => _goals;
  bool get isLoading => _isLoading;

  void clearData() {
    _goals = [];
    notifyListeners();
  }


  Future<void> fetchGoals() async {
    _isLoading = true;
    notifyListeners();
    try {
      _goals = await _db.fetchGoals();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addGoal(String description) async {
    await _db.addGoal(description);
    await fetchGoals();
  }
}