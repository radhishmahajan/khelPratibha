import 'package:flutter/material.dart';
import 'package:khelpratibha/models/user_role.dart';
import 'package:khelpratibha/providers/user_provider.dart';
import 'package:khelpratibha/screens/core/auth_gate.dart';
import 'package:khelpratibha/screens/dashboard/profile/edit_profile_page.dart';
import 'package:khelpratibha/services/auth_service.dart';
import 'package:khelpratibha/widgets/profile_avatar.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final userProfile = userProvider.userProfile;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            tooltip: 'Sign Out',
            icon: const Icon(Icons.logout),
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
      body: userProfile == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
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
          Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
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
                  if (userProfile.role == UserRole.player && userProfile.selectedCategory != null) ...[
                    const Divider(height: 1),
                    _buildProfileInfoTile(
                      icon: Icons.category_outlined,
                      title: 'Sport Category',
                      subtitle: userProfile.selectedCategory!.name[0].toUpperCase() + userProfile.selectedCategory!.name.substring(1),
                      theme: theme,
                    ),
                  ]
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Edit Profile'),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const EditProfilePage(),
              ));
            },
          ),
        ],
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
}