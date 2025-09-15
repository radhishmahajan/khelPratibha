import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:khelpratibha/config/theme_notifier.dart';
import 'package:khelpratibha/screens/auth/signup_page.dart';
import 'package:khelpratibha/services/auth_service.dart';
import 'package:khelpratibha/widgets/custom_input_field.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  late final AnimationController _controller;
  String _quote = "";
  String _author = "";

  final List<Map<String, String>> _quotes = [
    {'quote': 'The only way to prove that you’re a good sport is to lose.', 'author': 'Ernie Banks'},
    {'quote': 'It’s not whether you get knocked down; it’s whether you get up.', 'author': 'Vince Lombardi'},
    {'quote': 'The harder the battle, the sweeter the victory.', 'author': 'Les Brown'},
    {'quote': 'You miss 100% of the shots you don’t take.', 'author': 'Wayne Gretzky'},
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _selectRandomQuote();
  }

  void _selectRandomQuote() {
    final random = math.Random();
    final selectedQuote = _quotes[random.nextInt(_quotes.length)];
    if (mounted) {
      setState(() {
        _quote = selectedQuote['quote']!;
        _author = selectedQuote['author']!;
      });
    }
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await context.read<AuthService>().signInWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // The pop call was missing here. It's not needed if AuthGate is handling navigation.
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign-in failed: ${e.toString()}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Widget _buildGradientButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFEA3B81), Color(0xFF6B47EE)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required String text,
    required IconData icon,
    required VoidCallback onPressed,
    Color? iconColor,
    bool isGoogle = false,
  }) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isLight ? Colors.white : theme.colorScheme.surface.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isLight ? Colors.grey.shade300 : Colors.grey.shade800),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isGoogle)
              ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (Rect bounds) => const LinearGradient(
                  colors: [
                    Color(0xFF4285F4), // Blue
                    Color(0xFF34A853), // Green
                    Color(0xFFFBBC05), // Yellow
                    Color(0xFFEA4335), // Red
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds),
                child: FaIcon(icon, size: 24),
              )
            else
              FaIcon(
                icon,
                color: iconColor,
                size: 24,
              ),
            const SizedBox(width: 12),
            Text(
              text,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isLight ? Colors.black87 : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuoteSection(bool isLight) {
    return Padding(
      padding: const EdgeInsets.only(top: 32.0),
      child: Column(
        children: [
          Text(
            '"$_quote"',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontStyle: FontStyle.italic,
              color: isLight ? Colors.grey.shade700 : Colors.grey.shade300,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '- $_author',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isLight ? Colors.grey.shade800 : Colors.grey.shade200,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final isLight = themeNotifier.themeMode == ThemeMode.light;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Khel Pratibha"),
        actions: [
          IconButton(
            icon: Icon(
              isLight ? Icons.dark_mode : Icons.light_mode,
              color: isLight? Colors.black : Colors.white,
            ),
            onPressed: () => themeNotifier.toggleTheme(),
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: isLight
              ? const LinearGradient(
            colors: [
              Color(0xFFFFF1F5), // Light Pink
              Color(0xFFE8E2FF), // Light Lavender
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
              : const LinearGradient(
            colors: [Color(0xFF0f0c29), Color(0xFF302b63), Color(0xFF24243e)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      double scale = 1.0 + 0.05 * math.sin(_controller.value * 2 * math.pi);
                      double angle = 0.15 * math.sin(_controller.value * 2 * math.pi * 2);

                      return Transform.rotate(
                        angle: angle,
                        child: Transform.scale(
                          scale: scale,
                          child: child,
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: isLight
                                ? const Color(0xFFEA3B81).withValues(alpha: 0.4)
                                : Colors.amber.withValues(alpha: 0.4),
                            blurRadius: 15,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.emoji_events,
                        size: 90,
                        color: isLight ? const Color(0xFFEA3B81) : Colors.amber,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Khel Pratibha",
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Unleash Your Sports Talent!",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 40),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.all(24.0),
                        decoration: BoxDecoration(
                            color: isLight ? Colors.white.withValues(alpha: 0.5) : Colors.black.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                                color: isLight ? Colors.white.withValues(alpha: 0.7) : Colors.grey.shade800
                            )
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              CustomInputField(
                                controller: _emailController,
                                labelText: "Email",
                                prefixIcon: Icons.email_outlined,
                                validator: (v) => v == null || v.isEmpty
                                    ? "Please enter an email"
                                    : null,
                              ),
                              const SizedBox(height: 20),
                              CustomInputField(
                                controller: _passwordController,
                                labelText: "Password",
                                prefixIcon: Icons.lock_outline,
                                isPassword: true,
                                validator: (v) => v == null || v.isEmpty
                                    ? "Please enter a password"
                                    : null,
                              ),
                              const SizedBox(height: 32),
                              _isLoading
                                  ? const CircularProgressIndicator(color: Colors.amber)
                                  : _buildGradientButton(
                                text: "Sign In",
                                onPressed: _signIn,
                              ),
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  const Expanded(child: Divider()),
                                  Padding(
                                    padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                    child: Text(
                                      "OR",
                                      style: TextStyle(color: isLight ? Colors.grey.shade600 : Colors.grey.shade400),
                                    ),
                                  ),
                                  const Expanded(child: Divider()),
                                ],
                              ),
                              const SizedBox(height: 24),
                              _buildSocialButton(
                                text: "Continue with Google",
                                icon: FontAwesomeIcons.google,
                                isGoogle: true,
                                onPressed: () {},
                              ),
                              const SizedBox(height: 12),
                              _buildSocialButton(
                                text: "Continue with Apple",
                                icon: FontAwesomeIcons.apple,
                                iconColor: isLight ? Colors.black : Colors.white,
                                onPressed: () {},
                              ),
                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account?",
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const SignUpPage(),
                            ),
                          );
                        },
                        child: const Text(
                          "Sign Up",
                          style: TextStyle(
                              color: Colors.pinkAccent,
                              fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  ),
                  _buildQuoteSection(isLight),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}