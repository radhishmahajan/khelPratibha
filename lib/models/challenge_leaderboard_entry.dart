class ChallengeLeaderboardEntry {
  final String userId;
  final String fullName;
  final String? avatarUrl;
  final double progress;
  final int rank;

  ChallengeLeaderboardEntry({
    required this.userId,
    required this.fullName,
    this.avatarUrl,
    required this.progress,
    required this.rank,
  });

  factory ChallengeLeaderboardEntry.fromMap(Map<String, dynamic> map, int rank) {
    return ChallengeLeaderboardEntry(
      userId: map['user_id'],
      fullName: map['full_name'] ?? 'Anonymous Athlete',
      avatarUrl: map['avatar_url'],
      progress: (map['progress'] as num).toDouble(),
      rank: rank,
    );
  }
}