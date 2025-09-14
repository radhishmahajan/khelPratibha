import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:khelpratibha/api/supabase_client.dart';
import 'package:khelpratibha/config/app_theme.dart';
import 'package:khelpratibha/providers/user_provider.dart';
import 'package:khelpratibha/screens/core/splash_screen.dart';
import 'package:khelpratibha/services/auth_service.dart';
import 'package:khelpratibha/services/database_service.dart';
import 'package:khelpratibha/services/storage_service.dart'; // Import StorageService
import 'package:provider/provider.dart';
import 'package:khelpratibha/services/analysis_service.dart';
import 'package:khelpratibha/providers/session_provider.dart';
import 'package:khelpratibha/providers/achievement_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await SupabaseClientManager.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<DatabaseService>(create: (_) => DatabaseService()),
        Provider<StorageService>(create: (_) => StorageService()), // Add StorageService here
        ChangeNotifierProxyProvider<DatabaseService, UserProvider>(
          create: (context) => UserProvider(context.read<DatabaseService>()),
          update: (context, dbService, previous) => UserProvider(dbService),
        ),
        Provider<AnalysisService>(create: (_) => AnalysisService()),
        ChangeNotifierProxyProvider<DatabaseService, SessionProvider>(
          create: (context) => SessionProvider(context.read<DatabaseService>()),
          update: (context, dbService, previous) => SessionProvider(dbService),
        ),
        ChangeNotifierProxyProvider<DatabaseService, AchievementProvider>(
          create: (context) => AchievementProvider(context.read<DatabaseService>()),
          update: (context, dbService, previous) => AchievementProvider(dbService),
        ),
      ],
      child: MaterialApp(
        title: 'Khel Pratibha',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark,
        home: const SplashScreen(),
      ),
    );
  }
}