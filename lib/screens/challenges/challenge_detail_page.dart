import 'package:flutter/material.dart';
import 'package:khelpratibha/models/challenge.dart';
import 'package:khelpratibha/models/challenge_leaderboard_entry.dart';
import 'package:khelpratibha/providers/challenge_provider.dart';
import 'package:khelpratibha/widgets/profile_avatar.dart';
import 'package:provider/provider.dart';

class ChallengeDetailPage extends StatelessWidget {
  final Challenge challenge;

  const ChallengeDetailPage({super.key, required this.challenge});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(challenge.title),
      ),
      body: FutureBuilder<List<ChallengeLeaderboardEntry>>(
        future: context.read<ChallengeProvider>().fetchChallengeLeaderboard(challenge.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No one has participated in this challenge yet.'),
            );
          }

          final leaderboard = snapshot.data!;

          return ListView.builder(
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
                    entry.progress.toStringAsFixed(1),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}