class PerformanceSession {
  final String id;
  final String testName;
  final double score;
  final int? reps;
  final DateTime recordedAt;

  PerformanceSession({
    required this.id,
    required this.testName,
    required this.score,
    this.reps,
    required this.recordedAt,
  });

  factory PerformanceSession.fromMap(Map<String, dynamic> map) {
    return PerformanceSession(
      id: map['id'],
      testName: map['fitness_tests']['name'] ?? 'Unknown Test',
      score: (map['score'] as num).toDouble(),
      reps: map['reps'],
      recordedAt: DateTime.parse(map['recorded_at']),
    );
  }
}