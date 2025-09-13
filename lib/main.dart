import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:khelpratibha/api/supabase_client.dart';
import 'package:khelpratibha/config/app_theme.dart';
import 'package:khelpratibha/providers/user_provider.dart';
import 'package:khelpratibha/screens/core/splash_screen.dart';
import 'package:khelpratibha/services/ai_analysis_service.dart';
import 'package:khelpratibha/services/auth_service.dart';
import 'package:khelpratibha/services/database_service.dart';
import 'package:provider/provider.dart';

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
        ChangeNotifierProxyProvider<DatabaseService, UserProvider>(
          create: (context) => UserProvider(context.read<DatabaseService>()),
          update: (context, dbService, previous) => UserProvider(dbService),
        ),
        ProxyProvider<DatabaseService, AiAnalysisService>(
          update: (context, dbService, previous) => AiAnalysisService(dbService),
        ),
      ],
      child: MaterialApp(
        title: 'Khel Pratibha',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark,
        // CORRECTED: The home screen is now the SplashScreen
        home: const SplashScreen(),
      ),
    );
  }
}