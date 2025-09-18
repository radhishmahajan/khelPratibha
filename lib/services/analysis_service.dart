import 'dart:math';
import 'package:image_picker/image_picker.dart';

class AnalysisService {
  Future<Map<String, dynamic>> analyzeHeightWeight(XFile mediaFile) async {
    // Simulate a network delay for a realistic testing experience
    await Future.delayed(const Duration(seconds: 3));

    // Generate random results for demonstration purposes
    final random = Random();
    final randomHeight = 150 + random.nextDouble() * 50; // Height between 150cm and 200cm
    final randomWeight = 50 + random.nextDouble() * 50;  // Weight between 50kg and 100kg

    return {
      'height_cm': randomHeight,
      'weight_kg': randomWeight,
    };
  }

  Future<Map<String, dynamic>> analyzeStrengthAndPower(XFile videoFile) async {
    // Simulate a network delay for a realistic testing experience
    await Future.delayed(const Duration(seconds: 3));

    // Generate random results for demonstration purposes
    final random = Random();
    final randomScore = 50 + random.nextDouble() * 50; // Score between 50 and 100
    final randomReps = 10 + random.nextInt(41); // Reps between 10 and 50

    return {
      'score': randomScore,
      'reps': randomReps,
    };
  }
}