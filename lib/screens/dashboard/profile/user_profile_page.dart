import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:khelpratibha/config/theme_notifier.dart';
import 'package:khelpratibha/providers/user_provider.dart';
import 'package:khelpratibha/screens/core/auth_gate.dart';
import 'package:khelpratibha/screens/dashboard/profile/edit_profile_page.dart';
import 'package:khelpratibha/services/auth_service.dart';
import 'package:khelpratibha/widgets/profile_avatar.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final userProfile = userProvider.userProfile;
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final isLight = themeNotifier.themeMode == ThemeMode.light;
    final theme = Theme.of(context);

    return SafeArea(
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: const Text('Profile'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              tooltip: 'Sign Out',
              icon: Icon(Icons.logout, color: isLight? Colors.black : Colors.white,),
              onPressed: () async {
                await context.read<AuthService>().signOut();
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const AuthGate()),
                        (route) => false,
                  );
                }
              },
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
              colors: [Color(0xFF0f0c29), Color(0xFF302b63), Color(0xFF24243e)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: userProfile == null
                ? const Center(child: CircularProgressIndicator())
                : FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    const SizedBox(height: 16),
                    Center(
                      child: ProfileAvatar(
                        imageUrl: userProfile.avatarUrl,
                        radius: 60,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      userProfile.fullName ?? 'Athlete',
                      style: theme.textTheme.displaySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      userProfile.email,
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isLight ? Colors.white.withOpacity(0.5) : Colors.black.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: isLight ? Colors.white.withOpacity(0.7) : Colors.grey.shade800,
                            ),
                          ),
                          child: Column(
                            children: [
                              _buildProfileInfoTile(
                                icon: Icons.shield_outlined,
                                title: 'Role',
                                subtitle: userProfile.role.name[0].toUpperCase() + userProfile.role.name.substring(1),
                                theme: theme,
                              ),
                              const Divider(height: 1),
                              _buildProfileInfoTile(
                                icon: Icons.sports_soccer_outlined,
                                title: 'Primary Sport',
                                subtitle: userProfile.sport ?? 'Not specified',
                                theme: theme,
                              ),
                              const Divider(height: 1),
                              _buildProfileInfoTile(
                                icon: Icons.cake_outlined,
                                title: 'Date of Birth',
                                subtitle: userProfile.dateOfBirth?.toLocal().toString().split(' ')[0] ?? 'Not specified',
                                theme: theme,
                              ),
                              const Divider(height: 1),
                              _buildProfileInfoTile(
                                icon: Icons.height,
                                title: 'Height',
                                subtitle: userProfile.heightCm != null ? '${userProfile.heightCm!.toStringAsFixed(1)} cm' : 'Not specified',
                                theme: theme,
                              ),
                              const Divider(height: 1),
                              _buildProfileInfoTile(
                                icon: Icons.fitness_center,
                                title: 'Weight',
                                subtitle: userProfile.weightKg != null ? '${userProfile.weightKg!.toStringAsFixed(1)} kg' : 'Not specified',
                                theme: theme,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    _buildGradientButton(
                      text: 'Edit Profile',
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => const EditProfilePage(),
                        ));
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required ThemeData theme,
  }) {
    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(title, style: theme.textTheme.bodySmall),
      subtitle: Text(subtitle, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
    );
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
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.edit_outlined, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}