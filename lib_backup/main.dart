import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://gmkzigozmguakrkeefbz.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdta3ppZ296bWd1YWtya2VlZmJ6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY4ODEwMTUsImV4cCI6MjA3MjQ1NzAxNX0.qHc8mRr1lV0A57_BU0RGgIXYEFPYhIzo8DqKfKuXnl4',
  );

  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Exercise Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: const Color(0xFF1A1A2E),
          primaryColor: const Color(0xFFE94560),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFE94560),
            secondary: Color(0xFF0F3460),
            surface: Color(0xFF16213E),
            error: Color(0xFFFF4C61),
            onPrimary: Colors.white,
            onSecondary: Colors.white,
            onSurface: Colors.white70,
          ),
          textTheme: GoogleFonts.interTextTheme(
            ThemeData.dark().textTheme.apply(
              bodyColor: Colors.white,
              displayColor: Colors.white,
            ),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF16213E),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE94560),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFF0F3460),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE94560)),
            ),
            hintStyle: TextStyle(color: Colors.white54),
            prefixIconColor: Colors.white54,
          ),

          // ▼▼▼ THIS IS THE CORRECTED LINE ▼▼▼
          cardTheme: CardThemeData(
            color: const Color(0xFF16213E),
            elevation: 5,
            shadowColor: Colors.black.withValues(alpha: 0.5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),

          snackBarTheme: const SnackBarThemeData(
            backgroundColor: Color(0xFF0F3460),
            contentTextStyle: TextStyle(color: Colors.white),
          )
      ),
      home: const AuthGate(),
    );
  }
}