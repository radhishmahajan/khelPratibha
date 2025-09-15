class LeaderboardEntry {
  final String userId;
  final String fullName;
  final String? avatarUrl;
  final double averageScore;
  final int rank;

  LeaderboardEntry({
    required this.userId,
    required this.fullName,
    this.avatarUrl,
    required this.averageScore,
    required this.rank,
  });

  factory LeaderboardEntry.fromMap(Map<String, dynamic> map, int rank) {
    return LeaderboardEntry(
      userId: map['user_id'],
      fullName: map['full_name'] ?? 'Anonymous Athlete',
      avatarUrl: map['avatar_url'],
      averageScore: (map['average_score'] as num).toDouble(),
      rank: rank,
    );
  }
}