import 'package:flutter/material.dart';
import 'package:khelpratibha/api/supabase_client.dart';
import 'package:khelpratibha/providers/user_provider.dart';
import 'package:khelpratibha/screens/core/auth_gate.dart';
import 'package:khelpratibha/services/ai_analysis_service.dart';
import 'package:khelpratibha/services/auth_service.dart';
import 'package:khelpratibha/services/database_service.dart';
import 'package:provider/provider.dart';

import 'config/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
        theme: AppTheme.lightTheme,       // Set the light theme
        darkTheme: AppTheme.darkTheme,     // Set the dark theme
        themeMode: ThemeMode.dark,         // Force dark mode on
        home: const AuthGate(),
      ),
    );
  }
}

