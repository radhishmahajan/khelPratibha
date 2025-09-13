import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const List<Color> primaryGradient = [
    Color(0xFF0D47A1),
    Color(0xFF42A5F5),
  ];

  static const List<Color> secondaryGradient = [
    Color(0xFF4CAF50),
    Color(0xFF81C784),
  ];

  static const Color errorColor = Color(0xFFD32F2F);

  // LIGHT THEME
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF5F7FA),
    appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.transparent,
      iconTheme: const IconThemeData(color: Colors.white),
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
    textTheme: _buildTextTheme(const Color(0xFF333333)),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF0D47A1),
      secondary: Color(0xFF4CAF50),
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
      backgroundColor: Colors.transparent,
      iconTheme: const IconThemeData(color: Colors.white),
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
    textTheme: _buildTextTheme(Colors.white),
    colorScheme: const ColorScheme.dark(
      primary: Color(0xFF0D47A1),
      secondary: Color(0xFF4CAF50),
      error: errorColor,
      surface: Color(0xFF1E1E1E),
    ),
  );

  // TEXT THEME
  static TextTheme _buildTextTheme(Color textColor) => TextTheme(
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

// FULL-GRADIENT BUTTON
class GradientButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final List<Color>? gradient;
  final double borderRadius;
  final EdgeInsetsGeometry padding;

  const GradientButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.gradient,
    this.borderRadius = 14,
    this.padding = const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
  });

  @override
  Widget build(BuildContext context) {
    final colors = gradient ?? AppTheme.primaryGradient;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: padding,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
          textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        onPressed: onPressed,
        child: Text(text),
      ),
    );
  }
}

// FULL-GRADIENT CARD
class GradientCard extends StatelessWidget {
  final Widget child;
  final List<Color>? gradient;
  final double borderRadius;
  final EdgeInsetsGeometry padding;

  const GradientCard({
    super.key,
    required this.child,
    this.gradient,
    this.borderRadius = 16,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    final colors = gradient ?? AppTheme.primaryGradient;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
}

// USAGE:
// GradientButton(onPressed: () {}, text: "Click Me")
// GradientCard(child: Text("Hello Gradient Card"))
