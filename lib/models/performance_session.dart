class PerformanceSession {
  final String id;
  final String userId;
  final String programId;
  final double score;
  final String feedback;
  final DateTime createdAt;

  PerformanceSession({
    required this.id,
    required this.userId,
    required this.programId,
    required this.score,
    required this.feedback,
    required this.createdAt,
  });

  factory PerformanceSession.fromMap(Map<String, dynamic> map) {
    return PerformanceSession(
      id: map['id'],
      userId: map['user_id'],
      programId: map['program_id'],
      score: (map['score'] as num).toDouble(),
      feedback: map['feedback'] ?? '',
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}