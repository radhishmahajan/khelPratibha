import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF0D47A1);
  static const Color accentColor = Color(0xFF4CAF50);
  static const Color errorColor = Color(0xFFD32F2F);

  // LIGHT THEME
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF5F7FA),
    appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: primaryColor, // Use solid color here
      iconTheme: const IconThemeData(color: Colors.white),
      titleTextStyle: GoogleFonts.poppins(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    textTheme: _buildTextTheme(const Color(0xFF333333)),
    elevatedButtonTheme: _buildGradientButtonTheme(),
    inputDecorationTheme: _buildInputDecorationTheme(const Color(0xFFE0E0E0)),
    cardTheme: CardThemeData(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      shadowColor: Colors.black26,
    ),
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      secondary: accentColor,
      error: errorColor,
      surface: Colors.white,
    ),
  );

  // DARK THEME
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF0D0D0D),
    appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: const Color(0xFF0D47A1),
      iconTheme: const IconThemeData(color: Colors.white),
      titleTextStyle: GoogleFonts.poppins(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    textTheme: _buildTextTheme(Colors.white),
    elevatedButtonTheme: _buildGradientButtonTheme(),
    inputDecorationTheme: _buildInputDecorationTheme(const Color(0xFF424242)),
    cardTheme: CardThemeData(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: const Color(0xFF1E1E1E).withValues(alpha: 0.8),
      shadowColor: Colors.black54,
    ),
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: accentColor,
      error: errorColor,
      surface: Color(0xFF1E1E1E),
    ),
  );

  // TEXT THEME
  static TextTheme _buildTextTheme(Color textColor) {
    return TextTheme(
      displayLarge: GoogleFonts.poppins(
        fontSize: 30,
        fontWeight: FontWeight.w900,
        color: textColor,
      ),
      displayMedium: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: textColor,
      ),
      displaySmall: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      bodyLarge: GoogleFonts.poppins(
        fontSize: 16,
        color: textColor,
      ),
      bodyMedium: GoogleFonts.poppins(
        fontSize: 14,
        color: textColor.withValues(alpha: 0.8),
      ),
      labelLarge: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: textColor,
      ),
    );
  }

  // GRADIENT BUTTONS
  static ElevatedButtonThemeData _buildGradientButtonTheme() {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
        backgroundColor: Colors.transparent, // for gradient wrapper
        shadowColor: Colors.black45,
        elevation: 4,
      ),
    );
  }

  static InputDecorationTheme _buildInputDecorationTheme(Color borderColor) {
    return InputDecorationTheme(
      filled: true,
      fillColor: borderColor.withValues(alpha: 0.05),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
    );
  }
}

// Custom gradient card widget
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry margin;
  final double elevation;
  final List<Color>? gradientColors;

  const AppCard({
    super.key,
    required this.child,
    this.margin = const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
    this.elevation = 6,
    this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors ??
                [Theme.of(context).colorScheme.surface, Theme.of(context).cardTheme.color!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Card(
          elevation: 0,
          color: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: child,
          ),
        ),
      ),
    );
  }
}
