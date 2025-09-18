import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:khelpratibha/config/theme_notifier.dart';
import 'package:khelpratibha/providers/achievement_provider.dart';
import 'package:khelpratibha/providers/challenge_provider.dart';
import 'package:khelpratibha/providers/goal_provider.dart';
import 'package:khelpratibha/providers/leaderboard_provider.dart';
import 'package:khelpratibha/providers/performance_provider.dart';
import 'package:khelpratibha/providers/user_provider.dart';
import 'package:khelpratibha/screens/dashboard/player/tabs/ai_coach_tab.dart';
import 'package:khelpratibha/screens/dashboard/player/tabs/challenges_tab.dart';
import 'package:khelpratibha/screens/dashboard/player/tabs/fitness_test_menu.dart';
import 'package:khelpratibha/screens/dashboard/player/tabs/overall_performance_tab.dart';
import 'package:khelpratibha/screens/dashboard/player/tabs/player_leaderboard_tab.dart';
import 'package:khelpratibha/screens/dashboard/profile/user_profile_page.dart';
import 'package:khelpratibha/utils/navigation_helper.dart';
import 'package:khelpratibha/widgets/profile_avatar.dart';
import 'package:provider/provider.dart';

class PlayerDashboard extends StatefulWidget {
  const PlayerDashboard({super.key});

  @override
  State<PlayerDashboard> createState() => _PlayerDashboardState();
}

class _PlayerDashboardState extends State<PlayerDashboard> {
  @override
  void initState() {
    super.initState();
    // Fetch initial data for all providers when the dashboard loads
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
    final userProfile = context.watch<UserProvider>().userProfile;
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final isLight = themeNotifier.themeMode == ThemeMode.light;
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 5,
      child: Scaffold(
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
            child: Column(
              children: [
                // Custom Header
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Dashboard',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(isLight ? Icons.dark_mode : Icons.light_mode),
                            color: isLight ? Colors.black : Colors.white,
                            onPressed: () => themeNotifier.toggleTheme(),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () =>
                                NavigationHelper.navigateToPage(context, const ProfilePage()),
                            child: Hero(
                              tag: "user-avatar",
                              child: ProfileAvatar(imageUrl: userProfile?.avatarUrl, radius: 20),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Custom TabBar with glassmorphism
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isLight ? Colors.white.withValues(alpha: 0.5) : Colors.black.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: TabBar(
                          indicator: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            gradient: const LinearGradient(
                              colors: [Color(0xFFEA3B81), Color(0xFF6B47EE)],
                            ),
                          ),
                          indicatorSize: TabBarIndicatorSize.tab,
                          labelColor: Colors.white,
                          unselectedLabelColor: isLight ? Colors.black87 : Colors.white70,
                          tabs: const [
                            Tab(icon: Icon(Icons.fitness_center), ),
                            Tab(icon: Icon(Icons.show_chart), ),
                            Tab(icon: Icon(Icons.leaderboard), ),
                            Tab(icon: Icon(Icons.psychology), ),
                            Tab(icon: Icon(Icons.military_tech), ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // TabBarView
                const Expanded(
                  child: TabBarView(
                    children: [
                      FitnessTestMenu(),
                      OverallPerformanceTab(),
                      PlayerLeaderboardTab(),
                      AICoachTab(),
                      ChallengesTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}