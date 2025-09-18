// lib/models/fitness_test.dart
import 'package:flutter/material.dart';

class FitnessTest {
  final String name;
  final String description;
  final String duration;
  final String difficulty;
  final String videoUrl;
  IconData get icon => _getIconForTest(name);

  FitnessTest({
    required this.name,
    required this.description,
    required this.duration,
    required this.difficulty,
    required this.videoUrl,
  });

  factory FitnessTest.fromMap(Map<String, dynamic> map) {
    return FitnessTest(
      name: map['name'] ?? 'Unknown Test',
      description: map['description'] ?? 'No description available.',
      duration: map['duration'] ?? 'N/A',
      difficulty: map['difficulty'] ?? 'N/A',
      videoUrl: map['video_url'] ?? '',
    );
  }
}

IconData _getIconForTest(String testName) {
  final lowerCaseName = testName.toLowerCase();
  if (lowerCaseName.contains('jump')) {
    return Icons.arrow_upward;
  } else if (lowerCaseName.contains('push-up')) {
    return Icons.fitness_center;
  } else if (lowerCaseName.contains('sit-up')) {
    return Icons.self_improvement;
  } else if (lowerCaseName.contains('run') || lowerCaseName.contains('sprint')) {
    return Icons.directions_run;
  } else if (lowerCaseName.contains('flexibility') || lowerCaseName.contains('sit-and-reach')) {
    return Icons.accessibility_new;
  }
  return Icons.fitness_center;
}