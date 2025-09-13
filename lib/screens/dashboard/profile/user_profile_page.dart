import 'package:flutter/material.dart';
import 'package:khelpratibha/providers/user_provider.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // First, sign the user out.
              await context.read<AuthService>().signOut();

              // THEN, pop all pages off the navigation stack until we get back to the root.
              // This ensures the AuthGate becomes the visible screen again.
              if (context.mounted) {
                Navigator.of(context).popUntil((route) => route.isFirst);
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
          Center(
            child: ProfileAvatar(
              imageUrl: userProfile.avatarUrl,
              radius: 60,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            userProfile.fullName ?? 'No Name',
            style: Theme.of(context).textTheme.displayMedium,
            textAlign: TextAlign.center,
          ),
          Text(
            userProfile.email,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => const EditProfilePage(),
              ));
            },
            child: const Text('Edit Profile'),
          ),
          const SizedBox(height: 24),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.shield_outlined),
            title: const Text('Role'),
            subtitle: Text(userProfile.role.name),
          ),
          ListTile(
            leading: const Icon(Icons.sports_soccer_outlined),
            title: const Text('Primary Sport'),
            subtitle: Text(userProfile.sport ?? 'Not set'),
          ),
          ListTile(
            leading: const Icon(Icons.cake_outlined),
            title: const Text('Date of Birth'),
            subtitle: Text(userProfile.dateOfBirth?.toLocal().toString().split(' ')[0] ?? 'Not set'),
          ),
        ],
      ),
    );
  }
}
