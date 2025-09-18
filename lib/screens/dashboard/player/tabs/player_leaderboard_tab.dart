import 'package:flutter/material.dart';
import 'package:khelpratibha/providers/fitness_provider.dart';
import 'package:khelpratibha/providers/leaderboard_provider.dart';
import 'package:khelpratibha/widgets/profile_avatar.dart';
import 'package:provider/provider.dart';

class PlayerLeaderboardTab extends StatefulWidget {
  const PlayerLeaderboardTab({super.key});

  @override
  State<PlayerLeaderboardTab> createState() => _PlayerLeaderboardTabState();
}

class _PlayerLeaderboardTabState extends State<PlayerLeaderboardTab> {
  String? _selectedTest;

  @override
  Widget build(BuildContext context) {
    final leaderboardProvider = context.watch<LeaderboardProvider>();
    final fitnessProvider = context.watch<FitnessProvider>();
    final theme = Theme.of(context);

    final leaderboard = _selectedTest == null
        ? leaderboardProvider.leaderboard
        : leaderboardProvider.activityLeaderboard;

    final isLoading = _selectedTest == null
        ? leaderboardProvider.isLoading
        : leaderboardProvider.isActivityLoading;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: DropdownButtonFormField<String>(
            value: _selectedTest,
            hint: const Text('Select a Test to see Leaderboard'),
            onChanged: (value) {
              setState(() {
                _selectedTest = value;
                if (value != null) {
                  leaderboardProvider.fetchLeaderboardForTest(value);
                }
              });
            },
            items: fitnessProvider.fitnessTestCategories
                .expand((category) => category.tests)
                .map((test) => DropdownMenuItem(
              value: test.name,
              child: Text(test.name),
            ))
                .toList(),
          ),
        ),
        Expanded(
          child: isLoading
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
                  subtitle:
                  ProfileAvatar(imageUrl: entry.avatarUrl, radius: 20),
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
          ),
        ),
      ],
    );
  }
}