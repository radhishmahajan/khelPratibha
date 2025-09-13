import 'package:flutter/material.dart';
import 'package:khelpratibha/providers/user_provider.dart';
import 'package:khelpratibha/screens/dashboard/common/placeholder_page.dart';
import 'package:khelpratibha/screens/dashboard/profile/user_profile_page.dart';
import 'package:khelpratibha/utils/navigation_helper.dart';
import 'package:khelpratibha/widgets/dashboard_card.dart';
import 'package:khelpratibha/widgets/profile_avatar.dart';
import 'package:provider/provider.dart';

class ScoutDashboard extends StatelessWidget {
  const ScoutDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final userProfile = context.watch<UserProvider>().userProfile;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scout Dashboard'),
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
            'Discover Talent',
            style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Find and track promising new athletes.',
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
                title: 'Search Players',
                icon: Icons.search_outlined,
                color: Colors.redAccent,
                onTap: () => NavigationHelper.navigateToPage(context, const PlaceholderPage(title: 'Search Players')),
              ),
              DashboardCard(
                title: 'My Watchlist',
                icon: Icons.star_border_outlined,
                color: Colors.amber,
                onTap: () => NavigationHelper.navigateToPage(context, const PlaceholderPage(title: 'My Watchlist')),
              ),
              DashboardCard(
                title: 'Event Reports',
                icon: Icons.emoji_events_outlined,
                color: Colors.deepOrange,
                onTap: () => NavigationHelper.navigateToPage(context, const PlaceholderPage(title: 'Event Reports')),
              ),
              DashboardCard(
                title: 'My Profile',
                icon: Icons.person_outline,
                color: Colors.brown,
                onTap: () => NavigationHelper.navigateToPage(context, const ProfilePage()),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

