import 'package:flutter/material.dart';
import 'package:khelpratibha/providers/leaderboard_provider.dart';
import 'package:provider/provider.dart';
import 'package:khelpratibha/widgets/profile_avatar.dart';

class PlayerLeaderboardTab extends StatelessWidget {
  const PlayerLeaderboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    final leaderboardProvider = context.watch<LeaderboardProvider>();
    final leaderboard = leaderboardProvider.leaderboard;
    final theme = Theme.of(context);

    return leaderboardProvider.isLoading
        ? const Center(child: CircularProgressIndicator())
        : leaderboard.isEmpty
        ? const Center(
      child: Text('Leaderboard is empty.'),
    )
        : ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: leaderboard.length,
      itemBuilder: (context, index) {
        final entry = leaderboard[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            leading: CircleAvatar(
              child: Text((index + 1).toString()),
            ),
            title: Text(entry.fullName),
            subtitle: ProfileAvatar(imageUrl: entry.avatarUrl, radius: 20),
            trailing: Text(
              entry.totalScore.toStringAsFixed(1),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        );
      },
    );
  }
}