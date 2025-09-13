import 'package:flutter/material.dart';
import 'package:khelpratibha/providers/user_provider.dart';
import 'package:khelpratibha/screens/dashboard/coach/create_assessment_page.dart';
import 'package:khelpratibha/screens/dashboard/common/placeholder_page.dart';
import 'package:khelpratibha/screens/dashboard/profile/user_profile_page.dart';
import 'package:khelpratibha/utils/navigation_helper.dart';
import 'package:khelpratibha/widgets/dashboard_card.dart';
import 'package:khelpratibha/widgets/profile_avatar.dart';
import 'package:provider/provider.dart';

class CoachDashboard extends StatelessWidget {
  const CoachDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final userProfile = context.watch<UserProvider>().userProfile;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Coach Dashboard'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () => NavigationHelper.navigateToPage(context, const ProfilePage()),
              child: ProfileAvatar(imageUrl: userProfile?.avatarUrl, radius: 20),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text(
            'Hello, Coach ${userProfile?.fullName?.split(' ').last ?? ''}!',
            style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Manage your players and their assessments.',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              DashboardCard(
                title: 'New Assessment',
                icon: Icons.add_chart_outlined,
                color: Colors.teal,
                onTap: () => NavigationHelper.navigateToPage(context, const CreateAssessmentPage()),
              ),
              DashboardCard(
                title: 'My Players',
                icon: Icons.groups_outlined,
                color: Colors.cyan,
                onTap: () => NavigationHelper.navigateToPage(context, const PlaceholderPage(title: 'My Players')),
              ),
              DashboardCard(
                title: 'View Reports',
                icon: Icons.bar_chart_outlined,
                color: Colors.indigo,
                onTap: () => NavigationHelper.navigateToPage(context, const PlaceholderPage(title: 'Reports')),
              ),
              DashboardCard(
                title: 'My Profile',
                icon: Icons.person_outline,
                color: Colors.blueGrey,
                onTap: () => NavigationHelper.navigateToPage(context, const ProfilePage()),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

