import 'package:flutter/material.dart';
import 'package:khelpratibha/providers/user_provider.dart';
import 'package:khelpratibha/screens/dashboard/common/placeholder_page.dart';
// Import restored to your original file name, which contains the 'ProfilePage' class.
import 'package:khelpratibha/screens/dashboard/profile/user_profile_page.dart';
import 'package:khelpratibha/utils/navigation_helper.dart';
import 'package:khelpratibha/widgets/dashboard_card.dart';
import 'package:khelpratibha/widgets/profile_avatar.dart';
import 'package:provider/provider.dart';

class PlayerDashboard extends StatelessWidget {
  const PlayerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final userProfile = context.watch<UserProvider>().userProfile;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Player Dashboard'),
        actions: [
          // A tappable profile avatar in the app bar for quick access to the profile.
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              // CORRECTED: Navigate to ProfilePage, which is the correct class name.
              onTap: () => NavigationHelper.navigateToPage(context, const ProfilePage()),
              child: ProfileAvatar(imageUrl: userProfile?.avatarUrl, radius: 20),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // A welcoming header for the user.
          Text(
            'Welcome, ${userProfile?.fullName?.split(' ').first ?? 'Player'}!',
            style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Ready to track your progress?',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),

          // The main grid of actions for the player.
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              DashboardCard(
                title: 'My Performance',
                icon: Icons.analytics_outlined,
                color: Colors.blue,
                onTap: () => NavigationHelper.navigateToPage(context, const PlaceholderPage(title: 'My Performance')),
              ),
              DashboardCard(
                title: 'View Assessments',
                icon: Icons.checklist_rtl_outlined,
                color: Colors.green,
                onTap: () => NavigationHelper.navigateToPage(context, const PlaceholderPage(title: 'Assessments')),
              ),
              DashboardCard(
                title: 'Training Log',
                icon: Icons.fitness_center_outlined,
                color: Colors.orange,
                onTap: () => NavigationHelper.navigateToPage(context, const PlaceholderPage(title: 'Training Log')),
              ),
              DashboardCard(
                title: 'My Profile',
                icon: Icons.person_outline,
                color: Colors.purple,
                // CORRECTED: Navigate to ProfilePage, which is the correct class name.
                onTap: () => NavigationHelper.navigateToPage(context, const ProfilePage()),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

