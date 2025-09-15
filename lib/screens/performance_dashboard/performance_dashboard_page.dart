import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:khelpratibha/config/theme_notifier.dart';
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

class _PerformanceDashboardPageState extends State<PerformanceDashboardPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });

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

  void _fetchData() {
    context.read<SessionProvider>().fetchSessions(widget.program.id);
    context.read<AchievementProvider>().fetchAchievements();
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final isLight = themeNotifier.themeMode == ThemeMode.light;

    return DefaultTabController(
      length: 6,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: const Text('Performance Dashboard'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              icon: Icon(isLight ? Icons.dark_mode : Icons.light_mode),
              color: isLight ? Colors.black : Colors.white,
              onPressed: () => themeNotifier.toggleTheme(),
            ),
            IconButton(
              icon: Icon(Icons.exit_to_app, color: isLight ? Colors.black : Colors.white),
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
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  }
                }
              },
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(50),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: isLight ? Colors.white.withValues(alpha: 0.5) : Colors.black.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(
                      color: isLight ? Colors.white.withValues(alpha: 0.7) : Colors.grey.shade800,
                    ),
                  ),
                  child: const TabBar(
                    isScrollable: false, // Set to false to remove scrollbar
                    tabs: [
                      Tab(icon: Tooltip(message: 'Overview', child: Icon(Icons.dashboard_outlined))),
                      Tab(icon: Tooltip(message: 'Progress', child: Icon(Icons.show_chart_outlined))),
                      Tab(icon: Tooltip(message: 'Media Analysis', child: Icon(Icons.video_camera_back_outlined))),
                      Tab(icon: Tooltip(message: 'Goals', child: Icon(Icons.flag_outlined))),
                      Tab(icon: Tooltip(message: 'Achievements', child: Icon(Icons.emoji_events_outlined))),
                      Tab(icon: Tooltip(message: 'Recommendations', child: Icon(Icons.lightbulb_outline))),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: isLight
                ? const LinearGradient(
              colors: [Color(0xFFFFF1F5), Color(0xFFE8E2FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
                : const LinearGradient(
              colors: [Color(0xFF0f0c29), Color(0xFF302b63), Color(0xFF24243e)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: TabBarView(
                  children: [
                    const OverviewTab(),
                    const ProgressTab(),
                    MediaAnalysisTab(program: widget.program),
                    const GoalsTab(),
                    const AchievementsTab(),
                    const RecommendationsTab(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}