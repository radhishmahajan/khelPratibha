import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:khelpratibha/api/supabase_client.dart';
import 'package:khelpratibha/config/app_theme.dart';
import 'package:khelpratibha/config/theme_notifier.dart';
import 'package:khelpratibha/providers/achievement_provider.dart';
import 'package:khelpratibha/providers/session_provider.dart';
import 'package:khelpratibha/providers/user_provider.dart';
import 'package:khelpratibha/screens/core/splash_screen.dart';
import 'package:khelpratibha/services/analysis_service.dart';
import 'package:khelpratibha/services/auth_service.dart';
import 'package:khelpratibha/services/database_service.dart';
import 'package:khelpratibha/services/storage_service.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await SupabaseClientManager.initialize();
  runApp(
    // All providers are now at the top level of the app, protecting them from rebuilds.
    MultiProvider(
      providers: [
        // Core Services that don't change
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<DatabaseService>(create: (_) => DatabaseService()),
        Provider<StorageService>(create: (_) => StorageService()),
        Provider<AnalysisService>(create: (_) => AnalysisService()),

        // UI State Notifier
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),

        // Data Providers that hold state and depend on services
        ChangeNotifierProxyProvider<DatabaseService, UserProvider>(
          create: (context) => UserProvider(context.read<DatabaseService>()),
          update: (context, dbService, previous) => previous ?? UserProvider(dbService),
        ),
        ChangeNotifierProxyProvider<DatabaseService, SessionProvider>(
          create: (context) => SessionProvider(context.read<DatabaseService>()),
          update: (context, dbService, previous) => previous ?? SessionProvider(dbService),
        ),
        ChangeNotifierProxyProvider<DatabaseService, AchievementProvider>(
          create: (context) => AchievementProvider(context.read<DatabaseService>()),
          update: (context, dbService, previous) => previous ?? AchievementProvider(dbService),
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
    // This Consumer *only* rebuilds the MaterialApp, leaving the providers above it untouched.
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