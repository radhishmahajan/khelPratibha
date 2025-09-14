import 'package:flutter/material.dart';
import 'package:khelpratibha/data/mock_performance_data.dart';
import 'package:khelpratibha/models/performance_session.dart';

class OverviewTab extends StatelessWidget {
  const OverviewTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final sessions = mockPerformanceSessions;
    double averageScoreValue = 0.0;
    if (sessions.isNotEmpty) {
      final double sumOfScores = sessions.map((s) => s.score).reduce((a, b) => a + b);
      averageScoreValue = (sumOfScores / sessions.length) / 100.0;
    }
    final int averageScorePercentage = (averageScoreValue * 100).toInt();

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
          children:  [
            KpiCard(title: 'Current Level', value: 'Intermediate', icon: Icons.track_changes, iconColor: Colors.blueAccent),
            KpiCard(title: 'Overall Progress', value: '68%', icon: Icons.trending_up, iconColor: Colors.greenAccent),
            KpiCard(title: 'Sessions This Week', value: sessions.length.toString(), icon: Icons.timer_outlined, iconColor: Colors.orangeAccent),
            KpiCard(title: 'Achievements', value: '3', icon: Icons.emoji_events, iconColor: Colors.amber),
          ],
        ),
        const SizedBox(height: 24),
        const RecentPerformanceCard(sessions: mockPerformanceSessions),
        const SizedBox(height: 16),
        TrainingSummaryCard(totalSessions: sessions.length, averageScore: averageScorePercentage),
        const SizedBox(height: 16),
        // Card(
        //   child: Padding(
        //     padding: const EdgeInsets.all(16.0),
        //     child: Column(
        //       crossAxisAlignment: CrossAxisAlignment.start,
        //       children: [
        //         Text('Weekly Score Average', style: theme.textTheme.titleMedium),
        //         const SizedBox(height: 16),
        //         LinearProgressIndicator(
        //           // Use the dynamically calculated value
        //           value: weeklyProgressValue,
        //           minHeight: 12,
        //           borderRadius: BorderRadius.circular(6),
        //           backgroundColor: Colors.grey.shade700,
        //           color: theme.colorScheme.primary,
        //         ),
        //         const SizedBox(height: 8),
        //         Align(
        //           alignment: Alignment.centerRight,
        //           // Display the dynamic percentage
        //           child: Text('$weeklyProgressPercentage% average score'),
        //         )
        //       ],
        //     ),
        //   ),
        // )
      ],
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
            ...sessions.map((session) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                children: [
                  Text(session.sessionName, style: Theme.of(context).textTheme.bodySmall),
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
            )),
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
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
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

