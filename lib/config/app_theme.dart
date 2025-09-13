// app_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand colors
  static const Color primaryColor = Color(0xFF0D47A1);
  static const Color accentColor = Color(0xFF4CAF50);
  static const Color errorColor = Color(0xFFD32F2F);

  // Light theme
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: const Color(0xFFF5F5F5),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0.5,
      iconTheme: const IconThemeData(color: Color(0xFF333333)),
      titleTextStyle: GoogleFonts.poppins(
        color: const Color(0xFF333333),
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),
    textTheme: _buildTextTheme(const Color(0xFF333333)),
    elevatedButtonTheme: _buildElevatedButtonTheme(primaryColor),
    inputDecorationTheme: _buildInputDecorationTheme(const Color(0xFFE0E0E0)),
    // CORRECTED: Changed CardTheme to CardThemeData
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: accentColor,
      error: errorColor,
      surface: Colors.white, // Card background
    ),
  );

  // Dark theme
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: const Color(0xFF121212),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF1E1E1E),
      elevation: 0.5,
      iconTheme: const IconThemeData(color: Colors.white),
      titleTextStyle: GoogleFonts.poppins(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),
    textTheme: _buildTextTheme(Colors.white),
    elevatedButtonTheme: _buildElevatedButtonTheme(primaryColor),
    inputDecorationTheme: _buildInputDecorationTheme(const Color(0xFF424242)),
    // CORRECTED: Changed CardTheme to CardThemeData
    cardTheme: CardThemeData(
      elevation: 4,
      color: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: accentColor,
      error: errorColor,
      surface: Color(0xFF1E1E1E), // Card background
    ),
  );

  // Text theme builder
  static TextTheme _buildTextTheme(Color textColor) {
    return TextTheme(
      displayLarge: GoogleFonts.poppins(
          fontSize: 28, fontWeight: FontWeight.bold, color: textColor),
      displayMedium: GoogleFonts.poppins(
          fontSize: 24, fontWeight: FontWeight.w600, color: textColor),
      displaySmall: GoogleFonts.poppins(
          fontSize: 20, fontWeight: FontWeight.w600, color: textColor),
      bodyLarge: GoogleFonts.poppins(fontSize: 16, color: textColor),
      bodyMedium: GoogleFonts.poppins(fontSize: 14, color: textColor.withValues(alpha: 0.8)),
      labelLarge: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: textColor),
    );
  }

  static ElevatedButtonThemeData _buildElevatedButtonTheme(Color bg) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }

  static InputDecorationTheme _buildInputDecorationTheme(Color borderColor) {
    return InputDecorationTheme(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
    );
  }
}

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry margin;
  final double elevation;
  final Color? color;
  const AppCard({
    super.key,
    required this.child,
    this.margin = const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
    this.elevation = 2,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: Card(
        // Use the color and elevation from the theme by default
        color: color ?? Theme.of(context).cardTheme.color,
        elevation: elevation,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: child,
        ),
      ),
    );
  }
}

