import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:khelpratibha/models/performance_session.dart';
import 'package:khelpratibha/providers/achievement_provider.dart';
import 'package:khelpratibha/providers/session_provider.dart';
import 'package:provider/provider.dart';

class OverviewTab extends StatefulWidget {
  const OverviewTab({super.key});

  @override
  State<OverviewTab> createState() => _OverviewTabState();
}

class _OverviewTabState extends State<OverviewTab> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

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

          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  GridView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.2,
                    ),
                    children: [
                      KpiCard(
                          title: 'Current Level',
                          value: currentLevel,
                          icon: Icons.track_changes,
                          gradient: const LinearGradient(colors: [Colors.blueAccent, Colors.lightBlueAccent])),
                      KpiCard(
                          title: 'Overall Score',
                          value: '${overallScore.toStringAsFixed(1)}/100',
                          icon: Icons.star,
                          gradient: const LinearGradient(colors: [Colors.amber, Colors.orangeAccent])),
                      KpiCard(
                          title: 'Sessions This Week',
                          value: sessionsThisWeek.length.toString(),
                          icon: Icons.timer_outlined,
                          gradient: const LinearGradient(colors: [Colors.purpleAccent, Colors.deepPurpleAccent])),
                      Consumer<AchievementProvider>(
                        builder: (context, achievementProvider, child) {
                          final unlockedCount = achievementProvider.achievements
                              .where((a) => a.isUnlocked)
                              .length;
                          return KpiCard(
                              title: 'Achievements',
                              value: unlockedCount.toString(),
                              icon: Icons.emoji_events,
                              gradient: const LinearGradient(colors: [Colors.pinkAccent, Colors.redAccent]));
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
              ),
            ),
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
  final Gradient gradient;
  const KpiCard({super.key, required this.title, required this.value, required this.icon, required this.gradient});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isLight ? Colors.white.withValues(alpha: 0.5) : Colors.black.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isLight ? Colors.white.withValues(alpha: 0.7) : Colors.grey.shade800,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: gradient,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 24),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(title, style: theme.textTheme.bodyMedium),
                ],
              ),
            ],
          ),
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
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: isLight ? Colors.white.withValues(alpha: 0.5) : Colors.black.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isLight ? Colors.white.withValues(alpha: 0.7) : Colors.grey.shade800,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Recent Performance Scores', style: theme.textTheme.titleMedium),
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
                        Text("Session $sessionNumber", style: theme.textTheme.bodySmall),
                        const SizedBox(width: 8),
                        Expanded(
                          child: LinearProgressIndicator(
                            value: session.score / 100,
                            minHeight: 8,
                            borderRadius: BorderRadius.circular(4),
                            backgroundColor: theme.colorScheme.surfaceContainerHighest,
                            valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('${session.score.toInt()}%', style: theme.textTheme.bodySmall),
                      ],
                    ),
                  );
                }),
            ],
          ),
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
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: isLight ? Colors.white.withValues(alpha: 0.5) : Colors.black.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isLight ? Colors.white.withValues(alpha: 0.7) : Colors.grey.shade800,
            ),
          ),
          child: Column(
            children: [
              Text('Training Summary', style: theme.textTheme.titleMedium),
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
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
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