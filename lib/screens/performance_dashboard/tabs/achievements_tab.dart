import 'package:flutter/material.dart';
import 'package:khelpratibha/models/achievement.dart';
import 'package:khelpratibha/providers/achievement_provider.dart';
import 'package:provider/provider.dart';

class AchievementsTab extends StatelessWidget {
  const AchievementsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<AchievementProvider>(
      builder: (context, achievementProvider, child) {
        if (achievementProvider.isLoading && achievementProvider.achievements.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final achievements = achievementProvider.achievements;

        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Text(
              'Your Achievements',
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Unlock new milestones as you progress in your training.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ...achievements.map((achievement) => AchievementCard(achievement: achievement)),
          ],
        );
      },
    );
  }
}

class AchievementCard extends StatelessWidget {
  final Achievement achievement;

  const AchievementCard({super.key, required this.achievement});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUnlocked = achievement.isUnlocked;
    final color = isUnlocked ? achievement.color : Colors.grey.shade700;
    final iconColor = isUnlocked ? Colors.white : Colors.grey.shade800;
    final textColor = isUnlocked ? theme.colorScheme.onSurface : Colors.grey.shade500;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: isUnlocked ? theme.cardColor : theme.cardColor.withAlpha(100),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: color,
              child: Icon(achievement.icon, size: 28, color: iconColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    achievement.title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    achievement.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: textColor.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            if (!isUnlocked)
              const Padding(
                padding: EdgeInsets.only(left: 16.0),
                child: Icon(Icons.lock, color: Colors.grey, size: 28),
              ),
          ],
        ),
      ),
    );
  }
}