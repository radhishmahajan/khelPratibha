// lib/screens/dashboard/player/player_dashboard.dart
import 'package:flutter/material.dart';
import 'package:khelpratibha/providers/achievement_provider.dart';
import 'package:khelpratibha/providers/challenge_provider.dart';
import 'package:khelpratibha/providers/goal_provider.dart';
import 'package:khelpratibha/providers/leaderboard_provider.dart';
import 'package:khelpratibha/providers/performance_provider.dart';
import 'package:khelpratibha/screens/dashboard/player/tabs/ai_coach_tab.dart';
import 'package:khelpratibha/screens/dashboard/player/tabs/challenges_tab.dart';
import 'package:khelpratibha/screens/dashboard/player/tabs/fitness_test_menu.dart';
import 'package:khelpratibha/screens/dashboard/player/tabs/overall_performance_tab.dart';
import 'package:khelpratibha/screens/dashboard/player/tabs/player_leaderboard_tab.dart';
import 'package:khelpratibha/widgets/dashboard_app_bar.dart';
import 'package:provider/provider.dart';
import 'package:khelpratibha/config/theme_notifier.dart';

class PlayerDashboard extends StatefulWidget {
  const PlayerDashboard({super.key});

  @override
  State<PlayerDashboard> createState() => _PlayerDashboardState();
}

class _PlayerDashboardState extends State<PlayerDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const FitnessTestMenu(),
    const OverallPerformanceTab(),
    const PlayerLeaderboardTab(),
    const AICoachTab(),
    const ChallengesTab(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PerformanceProvider>().fetchPerformanceHistory();
      context.read<PerformanceProvider>().fetchPersonalBests();
      context.read<LeaderboardProvider>().fetchLeaderboard();
      context.read<GoalProvider>().fetchGoals();
      context.read<AchievementProvider>().fetchAchievements();
      context.read<ChallengeProvider>().fetchChallenges();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final isLight = themeNotifier.themeMode == ThemeMode.light;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: DashboardAppBar(
        title: 'Player Dashboard',
        onFitnessTestsSelected: () {
          setState(() {
            _selectedIndex = 0;
          });
        },
        onPerformanceSelected: () {
          setState(() {
            _selectedIndex = 1;
          });
        },
        onLeaderboardSelected: () {
          setState(() {
            _selectedIndex = 2;
          });
        },
        onAICoachSelected: () {
          setState(() {
            _selectedIndex = 3;
          });
        },
        onChallengesSelected: () {
          setState(() {
            _selectedIndex = 4;
          });
        },
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
            colors: [
              Color(0xFF0f0c29),
              Color(0xFF302b63),
              Color(0xFF24243e)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: IndexedStack(
            index: _selectedIndex,
            children: _pages,
          ),
        ),
      ),
    );
  }
}