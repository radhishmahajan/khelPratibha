import 'package:flutter/material.dart';
import 'package:khelpratibha/screens/core/auth_gate.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  void _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const AuthGate()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/animations/trophy.json',
              width: 220,
              height: 220,
              repeat: true,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 32),
            Text(
              'KhelPratibha',
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.w900,
                color: theme.colorScheme.primary,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Unlocking Sports Potential',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
