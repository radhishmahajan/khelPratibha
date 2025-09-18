import 'package:flutter/material.dart';
import 'package:khelpratibha/models/fitness_test_category.dart';
import 'package:khelpratibha/services/database_service.dart';

class FitnessProvider extends ChangeNotifier {
  final DatabaseService _db;
  FitnessProvider(this._db);

  List<FitnessTestCategory> _fitnessTestCategories = [];
  bool _isLoading = false;

  List<FitnessTestCategory> get fitnessTestCategories => _fitnessTestCategories;
  bool get isLoading => _isLoading;

  Future<void> fetchFitnessTests() async {
    _isLoading = true;
    notifyListeners();
    try {
      _fitnessTestCategories = await _db.fetchFitnessTestCategories();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}