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
    return Scaffold(
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
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
      ),
    );
  }
}