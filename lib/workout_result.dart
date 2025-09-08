// lib/workout_result.dart

class WorkoutResult {
  final bool verified;
  final String exercise;
  final int goodReps;
  final int badReps;
  final List<String> feedbackLog;
  final int score; // New field for the score

  WorkoutResult({
    required this.verified,
    required this.exercise,
    required this.goodReps,
    required this.badReps,
    required this.feedbackLog,
    required this.score, // Added to constructor
  });

  factory WorkoutResult.fromJson(Map<String, dynamic> json) {
    return WorkoutResult(
      verified: json['verified'] ?? false,
      exercise: json['exercise'] ?? 'Unknown',
      goodReps: json['good_reps'] ?? 0,
      badReps: json['bad_reps'] ?? 0,
      feedbackLog: List<String>.from(json['feedback_log'] ?? []),
      score: json['score'] ?? 0, // Parse the new score
    );
  }
}