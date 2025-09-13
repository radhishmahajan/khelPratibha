import 'package:flutter/material.dart';
import 'package:khelpratibha/api/supabase_client.dart';
import 'package:khelpratibha/providers/user_provider.dart';
import 'package:khelpratibha/screens/core/auth_gate.dart';
import 'package:khelpratibha/services/ai_analysis_service.dart';
import 'package:khelpratibha/services/auth_service.dart';
import 'package:khelpratibha/services/database_service.dart';
import 'package:provider/provider.dart';

void main() async {
  // Ensure Flutter bindings are initialized before calling async code.
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize your Supabase client. This must be done before runApp.
  // CORRECTED: Changed Supabase_ to SupabaseManager
  await SupabaseClientManager.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // 1. AuthService: Manages user authentication state.
        Provider<AuthService>(create: (_) => AuthService()),

        // 2. DatabaseService: Handles all direct database interactions.
        Provider<DatabaseService>(create: (_) => DatabaseService()),

        // 3. UserProvider: Depends on DatabaseService.
        //    It uses a ProxyProvider to get the DatabaseService instance.
        ChangeNotifierProxyProvider<DatabaseService, UserProvider>(
          create: (context) => UserProvider(context.read<DatabaseService>()),
          update: (context, dbService, previous) => UserProvider(dbService),
        ),

        // 4. AiAnalysisService: Also depends on DatabaseService.
        //    This ProxyProvider creates the AiAnalysisService and gives it the
        //    DatabaseService it needs to function correctly.
        ProxyProvider<DatabaseService, AiAnalysisService>(
          update: (context, dbService, previous) => AiAnalysisService(dbService),
        ),
      ],
      child: MaterialApp(
        title: 'Khel Pratibha',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          textTheme: const TextTheme(
            displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
            ),
          ),
        ),
        home: const AuthGate(),
      ),
    );
  }
}

