import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:khelpratibha/models/leaderboard_entry.dart';
import 'package:khelpratibha/providers/fitness_provider.dart';
import 'package:khelpratibha/providers/leaderboard_provider.dart';
import 'package:khelpratibha/widgets/profile_avatar.dart';
import 'package:provider/provider.dart';
import 'package:khelpratibha/config/theme_notifier.dart';


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
    final isLight = Provider.of<ThemeNotifier>(context).themeMode == ThemeMode.light;

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
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: isLight ? Colors.white.withValues(alpha: 0.5) : Colors.black.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isLight ? Colors.white.withValues(alpha: 0.7) : Colors.grey.shade800,
                  ),
                ),
                child: DropdownButtonFormField<String>(
                  value: _selectedTest,
                  hint: Text(
                    'Select a Test to see Leaderboard',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: isLight ? Colors.black : Colors.white,
                    ),
                  ),
                  isExpanded: true,
                  icon: Icon(Icons.arrow_drop_down_rounded, color: theme.colorScheme.primary),
                  dropdownColor: isLight ? Colors.white.withValues(alpha: 0.8) : Colors.black.withValues(alpha: 0.7),
                  items: fitnessProvider.fitnessTestCategories
                      .expand((category) => category.tests)
                      .map((test) => DropdownMenuItem(
                    value: test.name,
                    child: Text(test.name, style: theme.textTheme.bodyLarge),
                  ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedTest = value;
                      if (value != null) {
                        leaderboardProvider.fetchLeaderboardForTest(value);
                      }
                    });
                  },
                ),
              ),
            ),
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
              return _LeaderboardCard(entry: entry, index: index);
            },
          ),
        ),
      ],
    );
  }
}

class _LeaderboardCard extends StatelessWidget {
  final LeaderboardEntry entry;
  final int index;

  const _LeaderboardCard({required this.entry, required this.index});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    Color rankColor = Colors.grey.shade600;

    if (index == 0) {
      rankColor = Colors.amber;
    } else if (index == 1) {
      rankColor = Colors.grey.shade400;
    } else if (index == 2) {
      rankColor = Colors.brown.shade400;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: isLight ? Colors.white.withValues(alpha: 0.5) : Colors.black.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isLight ? Colors.white.withValues(alpha: 0.7) : Colors.grey.shade800,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: rankColor.withValues(alpha: 0.2),
                  border: Border.all(color: rankColor, width: 2),
                ),
                child: Center(
                  child: Text(
                    (index + 1).toString(),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: rankColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              ProfileAvatar(
                imageUrl: entry.avatarUrl,
                radius: 20,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.fullName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Total Score',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.hintColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Text(
                entry.totalScore.toStringAsFixed(1),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}