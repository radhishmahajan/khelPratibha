import 'package:flutter/material.dart';
import 'package:khelpratibha/models/user_profile.dart';
import 'package:khelpratibha/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:khelpratibha/models/user_role.dart';

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

  Future<void> _onRoleSelected(BuildContext context, UserRole role) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final currentUser = Supabase.instance.client.auth.currentUser;

    if (currentUser == null) return;

    UserProfile? profile = userProvider.userProfile ?? UserProfile(
      id: currentUser.id,
      email: currentUser.email ?? '',
      role: UserRole.unknown,
    );

    final updatedProfile = profile.copyWith(role: role);
    await userProvider.saveUserProfile(updatedProfile);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select Your Role")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            RoleCard(
              icon: Icons.sports_soccer,
              title: "Player",
              onTap: () => _onRoleSelected(context, UserRole.player),
            ),
            const SizedBox(height: 16),
            RoleCard(
              icon: Icons.search,
              title: "Scout",
              onTap: () => _onRoleSelected(context, UserRole.scout),
            ),
            // REMOVED the RoleCard for "Coach"
          ],
        ),
      ),
    );
  }
}

class RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const RoleCard({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Icon(icon, size: 40, color: Theme.of(context).primaryColor),
              const SizedBox(width: 20),
              Text(
                title,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}