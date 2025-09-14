import 'package:flutter/material.dart';
import 'package:khelpratibha/models/performance_session.dart';
import 'package:khelpratibha/providers/achievement_provider.dart';
import 'package:khelpratibha/providers/session_provider.dart';
import 'package:provider/provider.dart';

class OverviewTab extends StatelessWidget {
  const OverviewTab({super.key});

  String _calculateLevel(int sessionCount, double averageScore) {
    if (sessionCount >= 10 && averageScore >= 80) {
      return 'Advanced';
    } else if (sessionCount >= 5 && averageScore >= 50) {
      return 'Intermediate';
    } else {
      return 'Beginner';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer<SessionProvider>(
        builder: (context, sessionProvider, child) {
          if (sessionProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final allSessions = sessionProvider.sessions;
          final sessionsThisWeek = allSessions
              .where((s) => s.createdAt.isAfter(DateTime.now().subtract(const Duration(days: 7))))
              .toList();

          final overallScore = allSessions.isNotEmpty
              ? (allSessions.map((s) => s.score).reduce((a, b) => a + b) / allSessions.length)
              : 0.0;

          final currentLevel = _calculateLevel(allSessions.length, overallScore);

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              GridView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 2.2,
                ),
                children: [
                  KpiCard(
                      title: 'Current Level',
                      value: currentLevel,
                      icon: Icons.track_changes,
                      iconColor: Colors.blueAccent),
                  KpiCard(
                      title: 'Overall Score',
                      value: '${overallScore.toStringAsFixed(1)}/100',
                      icon: Icons.star,
                      iconColor: Colors.amber),
                  KpiCard(
                      title: 'Sessions This Week',
                      value: sessionsThisWeek.length.toString(),
                      icon: Icons.timer_outlined,
                      iconColor: Colors.orangeAccent),
                  Consumer<AchievementProvider>(
                    builder: (context, achievementProvider, child) {
                      final unlockedCount = achievementProvider.achievements
                          .where((a) => a.isUnlocked)
                          .length;
                      return KpiCard(
                          title: 'Achievements',
                          value: unlockedCount.toString(),
                          icon: Icons.emoji_events,
                          iconColor: Colors.amber);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              RecentPerformanceCard(sessions: allSessions),
              const SizedBox(height: 16),
              TrainingSummaryCard(
                  totalSessions: allSessions.length,
                  averageScore: overallScore.toInt()),
            ],
          );
        },
      ),
    );
  }
}


class KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  const KpiCard({super.key, required this.title, required this.value, required this.icon, required this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: Theme.of(context).textTheme.bodySmall),
                Icon(icon, color: iconColor, size: 20),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class RecentPerformanceCard extends StatelessWidget {
  final List<PerformanceSession> sessions;
  const RecentPerformanceCard({super.key, required this.sessions});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Recent Performance Scores', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            if (sessions.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.0),
                  child: Column(
                    children: [
                      Icon(Icons.analytics_outlined, size: 40, color: Colors.grey),
                      SizedBox(height: 8),
                      Text('Complete your first session to see your scores here!'),
                    ],
                  ),
                ),
              )
            else
              ...sessions.take(10).toList().asMap().entries.map((entry) {
                int index = entry.key;
                PerformanceSession session = entry.value;
                int sessionNumber = sessions.length - index;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    children: [
                      Text("Session $sessionNumber", style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(width: 8),
                      Expanded(
                        child: LinearProgressIndicator(
                          value: session.score / 100,
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('${session.score.toInt()}%', style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}

class TrainingSummaryCard extends StatelessWidget {
  final int totalSessions;
  final int averageScore;
  const TrainingSummaryCard({super.key, required this.totalSessions, required this.averageScore});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Training Summary', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: SummaryBox(value: totalSessions.toString(), label: 'Total Sessions')),
                const SizedBox(width: 16),
                Expanded(child: SummaryBox(value: '$averageScore%', label: 'Average Score')),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class SummaryBox extends StatelessWidget {
  final String value;
  final String label;
  const SummaryBox({super.key, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withAlpha(128),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(value, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 4),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}