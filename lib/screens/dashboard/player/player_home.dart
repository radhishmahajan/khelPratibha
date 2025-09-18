import 'package:flutter/material.dart';
import 'package:khelpratibha/config/theme_notifier.dart';
import 'package:khelpratibha/models/user_role.dart';
import 'package:khelpratibha/providers/user_provider.dart';
import 'package:khelpratibha/screens/dashboard/player/player_dashboard.dart';
import 'package:khelpratibha/screens/dashboard/scout/scout_dashboard.dart';
import 'package:khelpratibha/screens/dashboard/profile/user_profile_page.dart'; // Make sure this import is correct
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey _featuresKey = GlobalKey();

  void _scrollToFeatures() {
    Scrollable.ensureVisible(
      _featuresKey.currentContext!,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final isLight = themeNotifier.themeMode == ThemeMode.light;
    final theme = Theme.of(context);
    final userProvider = Provider.of<UserProvider>(context);
    final userProfile = userProvider.userProfile;

    String avatarText = 'U';
    if (userProfile != null) {
      if (userProfile.fullName != null && userProfile.fullName!.isNotEmpty) {
        avatarText = userProfile.fullName![0].toUpperCase();
      } else if (userProfile.email.isNotEmpty) {
        avatarText = userProfile.email[0].toUpperCase();
      }
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset('assets/images/app_logo.png'),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "SAI TalentFinder",
              style:
              theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              "Sports Authority of India",
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
                isLight ? Icons.dark_mode_outlined : Icons.light_mode_outlined),
            onPressed: () {
              context.read<ThemeNotifier>().toggleTheme();
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none_outlined),
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              },
              child: CircleAvatar(
                backgroundImage: userProfile?.avatarUrl != null &&
                    userProfile!.avatarUrl!.isNotEmpty
                    ? NetworkImage(userProfile.avatarUrl!)
                    : null,
                child: userProfile?.avatarUrl == null ||
                    userProfile!.avatarUrl!.isEmpty
                    ? Text(avatarText)
                    : null,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: isLight
              ? const LinearGradient(
            colors: [Color(0xFFFFF1F5), Color(0xFFE8E2FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
              : const LinearGradient(
            colors: [
              Color(0xFF0f0c29),
              Color(0xFF302b63),
              Color(0xFF24243e)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(0),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 32),
                    _buildMadeInIndiaTag(isLight),
                    const SizedBox(height: 16),
                    _buildHeadline(theme),
                    const SizedBox(height: 16),
                    Text(
                      "Join thousands of aspiring athletes across India. Record your fitness assessments, get AI-powered analysis, and take the first step towards representing your country.",
                      textAlign: TextAlign.left,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        height: 1.5,
                        color: (isLight ? Colors.black : Colors.white)
                            .withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.play_arrow_rounded),
                            label: const Text("Start Assessment"),
                            onPressed: () {
                              if (userProvider.userProfile?.role ==
                                  UserRole.player) {
                                Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                        builder: (_) => const PlayerDashboard()));
                              } else if (userProvider.userProfile?.role ==
                                  UserRole.scout) {
                                Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                        builder: (_) => const ScoutDashboard()));
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: isLight
                                  ? const Color(0xFF303F9F)
                                  : theme.colorScheme.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _scrollToFeatures,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              foregroundColor: isLight
                                  ? const Color(0xFF303F9F)
                                  : Colors.white,
                              side: BorderSide(
                                color: isLight
                                    ? const Color(0xFF303F9F)
                                    : Colors.white,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text("View Details"),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        "https://images.pexels.com/photos/1618269/pexels-photo-1618269.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2",
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  key: _featuresKey,
                  children: [
                    Text(
                      "Revolutionary Sports Assessment",
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Our AI-powered platform brings professional-grade talent assessment to every corner of India",
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: (isLight ? Colors.black : Colors.white)
                            .withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 32),
                    _FeatureCard(
                      icon: Icons.shield_outlined,
                      title: "AI Verification",
                      description:
                      "Advanced cheat detection ensures fair and accurate assessments",
                      iconColor: Colors.green,
                      isLight: isLight,
                    ),
                    const SizedBox(height: 16),
                    _FeatureCard(
                      icon: Icons.trending_up_rounded,
                      title: "Real-time Analysis",
                      description:
                      "Instant performance feedback and benchmarking against peers",
                      iconColor: Colors.purple,
                      isLight: isLight,
                    ),
                    const SizedBox(height: 16),
                    _FeatureCard(
                      icon: Icons.emoji_events_outlined,
                      title: "Gamification",
                      description:
                      "Earn badges, climb leaderboards, and track your progress",
                      iconColor: Colors.orange,
                      isLight: isLight,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    Text(
                      "Standardized Fitness Assessments",
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Complete the same scientific tests used by professional sports academies worldwide",
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: (isLight ? Colors.black : Colors.white)
                            .withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 32),
                    _AssessmentCard(
                      isLight: isLight,
                      icon: Icons.height,
                      title: 'Height & Weight',
                      description: 'Basic anthropometric data',
                      iconColor: const Color(0xFF6B47EE), // Purple
                    ),
                    const SizedBox(height: 16),
                    _AssessmentCard(
                      isLight: isLight,
                      icon: Icons.fitness_center,
                      title: 'Vertical Jump',
                      description: 'Measure explosive leg power',
                      iconColor: const Color(0xFFF5AF19), // Orange
                    ),
                    const SizedBox(height: 16),
                    _AssessmentCard(
                      isLight: isLight,
                      icon: Icons.directions_run,
                      title: 'Shuttle Run',
                      description: 'Test agility and speed',
                      iconColor: const Color(0xFFF12711), // Red-Orange
                    ),
                    const SizedBox(height: 16),
                    _AssessmentCard(
                      isLight: isLight,
                      icon: Icons.accessibility_new,
                      title: 'Flexibility',
                      description: 'Range of motion assessment',
                      iconColor: const Color(0xFF00C9FF), // Light Blue
                    ),
                    const SizedBox(height: 16),
                    _AssessmentCard(
                      isLight: isLight,
                      icon: Icons.sports_gymnastics,
                      title: 'Sit-ups',
                      description: 'Core strength assessment',
                      iconColor: Colors.lightGreen, // Light Green
                    ),
                    const SizedBox(height: 16),
                    _AssessmentCard(
                      isLight: isLight,
                      icon: Icons.timer,
                      title: 'Endurance Run',
                      description: 'Test cardiovascular stamina',
                      iconColor: Colors.deepPurpleAccent, // Deep Purple
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.track_changes_outlined),
                      label: const Text("Begin Assessment Tests"),
                      onPressed: () {
                        if (userProvider.userProfile?.role ==
                            UserRole.player) {
                          Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (_) => const PlayerDashboard()));
                        } else if (userProvider.userProfile?.role ==
                            UserRole.scout) {
                          Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                  builder: (_) => const ScoutDashboard()));
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 24),
                        backgroundColor: isLight
                            ? Colors.black
                            : theme.colorScheme.onSurface,
                        foregroundColor: isLight
                            ? Colors.white
                            : theme.colorScheme.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              _buildStatsSection(isLight),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSection(bool isLight) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6B47EE), Color(0xFFEA3B81)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Column(
        children: [
          _StatItem(value: "50,000+", label: "Athletes Registered"),
          SizedBox(height: 32),
          _StatItem(value: "28", label: "States Covered"),
          SizedBox(height: 32),
          _StatItem(value: "1,200+", label: "Talents Identified"),
          SizedBox(height: 32),
          _StatItem(value: "99.2%", label: "Accuracy Rate"),
        ],
      ),
    );
  }

  Widget _buildMadeInIndiaTag(bool isLight) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isLight ? Colors.white : Colors.grey.shade800.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: isLight ? Colors.grey.shade300 : Colors.grey.shade700),
        ),
        child: const Text("IN Proudly Made in India"),
      ),
    );
  }

  Widget _buildHeadline(ThemeData theme) {
    return Align(
      alignment: Alignment.centerLeft,
      child: RichText(
        textAlign: TextAlign.left,
        text: TextSpan(
          style: theme.textTheme.displayLarge?.copyWith(
            fontWeight: FontWeight.bold,
            height: 1.2,
            fontSize: 50,
          ),
          children: [
            const TextSpan(text: "Discover Your Athletic\n"),
            WidgetSpan(
              child: ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFFF12711), Color(0xFFF5AF19)],
                ).createShader(bounds),
                child: Text(
                  "Potential",
                  style: theme.textTheme.displayLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                    color: Colors.white,
                    fontSize: 50,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color iconColor;
  final bool isLight;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.iconColor,
    required this.isLight,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color:
        isLight ? Colors.white : theme.colorScheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isLight ? Colors.grey.shade200 : Colors.grey.shade800),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: iconColor.withValues(alpha: 0.1),
            child: Icon(icon, size: 32, color: iconColor),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style:
            theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: (isLight ? Colors.black : Colors.white).withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;

  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.displayMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}

class _AssessmentCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool isLight;
  final Color iconColor;

  const _AssessmentCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.isLight,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
        isLight ? Colors.white : theme.colorScheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isLight ? Colors.grey.shade200 : Colors.grey.shade800),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: iconColor.withValues(alpha: 0.15),
            child: Icon(icon, size: 24, color: iconColor),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: (isLight ? Colors.black : Colors.white).withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}