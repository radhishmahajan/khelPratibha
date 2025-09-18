import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:khelpratibha/api/supabase_client.dart';
import 'package:khelpratibha/config/app_theme.dart';
import 'package:khelpratibha/config/theme_notifier.dart';
import 'package:khelpratibha/providers/achievement_provider.dart';
import 'package:khelpratibha/providers/challenge_provider.dart';
import 'package:khelpratibha/providers/fitness_provider.dart';
import 'package:khelpratibha/providers/goal_provider.dart';
import 'package:khelpratibha/providers/leaderboard_provider.dart';
import 'package:khelpratibha/providers/performance_provider.dart';
import 'package:khelpratibha/providers/user_provider.dart';
import 'package:khelpratibha/screens/core/splash_screen.dart';
import 'package:khelpratibha/services/auth_service.dart';
import 'package:khelpratibha/services/database_service.dart';
import 'package:khelpratibha/services/storage_service.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await SupabaseClientManager.initialize();
  runApp(
    MultiProvider(
      providers: [
        // Core Services that don't change
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<DatabaseService>(create: (_) => DatabaseService()),
        Provider<StorageService>(create: (_) => StorageService()),

        // UI State Notifier
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),

        // Data Providers that hold state and depend on services
        ChangeNotifierProxyProvider<DatabaseService, UserProvider>(
          create: (context) => UserProvider(context.read<DatabaseService>()),
          update: (context, dbService, previous) => previous ?? UserProvider(dbService),
        ),
        ChangeNotifierProxyProvider<DatabaseService, AchievementProvider>(
          create: (context) => AchievementProvider(context.read<DatabaseService>()),
          update: (context, dbService, previous) => previous ?? AchievementProvider(dbService),
        ),
        ChangeNotifierProxyProvider<DatabaseService, GoalProvider>(
          create: (context) => GoalProvider(context.read<DatabaseService>()),
          update: (context, dbService, previous) => previous ?? GoalProvider(dbService),
        ),
        ChangeNotifierProxyProvider<DatabaseService, LeaderboardProvider>(
          create: (context) => LeaderboardProvider(context.read<DatabaseService>()),
          update: (context, dbService, previous) => previous ?? LeaderboardProvider(dbService),
        ),
        ChangeNotifierProxyProvider<DatabaseService, PerformanceProvider>(
          create: (context) => PerformanceProvider(context.read<DatabaseService>()),
          update: (context, dbService, previous) => previous ?? PerformanceProvider(dbService),
        ),
        ChangeNotifierProxyProvider<DatabaseService, ChallengeProvider>(
          create: (context) => ChallengeProvider(context.read<DatabaseService>()),
          update: (context, dbService, previous) => previous ?? ChallengeProvider(dbService),
        ),
        ChangeNotifierProxyProvider<DatabaseService, FitnessProvider>(
          create: (context) => FitnessProvider(context.read<DatabaseService>()),
          update: (context, dbService, previous) => previous ?? FitnessProvider(dbService),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
        return MaterialApp(
          title: 'Khel Pratibha',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeNotifier.themeMode,
          home: const SplashScreen(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}