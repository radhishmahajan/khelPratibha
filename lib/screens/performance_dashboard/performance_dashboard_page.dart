import 'package:flutter/material.dart';
import 'package:khelpratibha/models/sport_program.dart';
import 'package:khelpratibha/providers/achievement_provider.dart';
import 'package:khelpratibha/providers/session_provider.dart';
import 'package:khelpratibha/providers/user_provider.dart';
import 'tabs/achievements_tab.dart';
import 'tabs/goals_tab.dart';
import 'tabs/media_analysis_tab.dart';
import 'tabs/overview_tab.dart';
import 'tabs/progress_tab.dart';
import 'tabs/recommendations_tab.dart';
import 'package:provider/provider.dart';

class PerformanceDashboardPage extends StatefulWidget {
  final SportProgram program;
  const PerformanceDashboardPage({super.key, required this.program});

  @override
  State<PerformanceDashboardPage> createState() => _PerformanceDashboardPageState();
}

class _PerformanceDashboardPageState extends State<PerformanceDashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  void _fetchData() {
    context.read<SessionProvider>().fetchSessions(widget.program.id);
    context.read<AchievementProvider>().fetchAchievements();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Performance Dashboard'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Overview'),
              Tab(text: 'Progress'),
              Tab(text: 'Media Analysis'),
              Tab(text: 'Goals'),
              Tab(text: 'Achievements'),
              Tab(text: 'Recommendations'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.exit_to_app),
              tooltip: 'Leave Program',
              onPressed: () async {
                final didRequestLeave = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Leave Program?'),
                    content: const Text(
                        'Are you sure you want to leave this program? Your progress might be lost.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Leave'),
                      ),
                    ],
                  ),
                );

                if (didRequestLeave ?? false) {
                  if (context.mounted) {
                    await context
                        .read<UserProvider>()
                        .leaveProgram(programId: widget.program.id);
                    Navigator.of(context).pop();
                  }
                }
              },
            ),
          ],
        ),
        body: TabBarView(
          children: [
            const OverviewTab(),
            const ProgressTab(),
            MediaAnalysisTab(program: widget.program),
            const GoalsTab(),
            const AchievementsTab(), // Added Achievements tab view back
            const RecommendationsTab(),
          ],
        ),
      ),
    );
  }
}