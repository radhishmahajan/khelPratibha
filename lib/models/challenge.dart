// lib/models/challenge.dart
import 'package:khelpratibha/models/fitness_test.dart';

class Challenge {
  final String id;
  final String title;
  final String description;
  final String type;
  final double goal;
  final FitnessTest linkedTest;
  final bool isJoined;
  final DateTime? timeLimit;

  Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.goal,
    required this.linkedTest,
    this.isJoined = false,
    this.timeLimit,
  });

  factory Challenge.fromMap(Map<String, dynamic> map) {
    return Challenge(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      type: map['type'],
      goal: (map['goal'] as num).toDouble(),
      linkedTest: FitnessTest.fromMap(map['fitness_tests']),
      isJoined: map['is_joined'] ?? false,
      timeLimit: map['time_limit'] != null ? DateTime.tryParse(map['time_limit']) : null,
    );
  }
}