import 'package:flutter/material.dart';
import 'package:khelpratibha/config/theme_notifier.dart';
import 'package:khelpratibha/providers/user_provider.dart';
import 'package:khelpratibha/screens/core/home_page.dart';
import 'package:khelpratibha/screens/dashboard/profile/user_profile_page.dart';
import 'package:khelpratibha/utils/navigation_helper.dart';
import 'package:khelpratibha/widgets/profile_avatar.dart';
import 'package:provider/provider.dart';

class DashboardAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback onFitnessTestsSelected;
  final VoidCallback onPerformanceSelected;
  final VoidCallback onLeaderboardSelected;
  final VoidCallback onAICoachSelected;
  final VoidCallback onChallengesSelected;

  const DashboardAppBar({
    super.key,
    required this.title,
    required this.onFitnessTestsSelected,
    required this.onPerformanceSelected,
    required this.onLeaderboardSelected,
    required this.onAICoachSelected,
    required this.onChallengesSelected,
  });

  @override
  Widget build(BuildContext context) {
    final userProfile = context.watch<UserProvider>().userProfile;
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final isLight = themeNotifier.themeMode == ThemeMode.light;
    final theme = Theme.of(context);

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const HomePage()),
                  (route) => false,
            );
          },
          child: Image.asset('assets/images/app_logo.png'),
        ),
      ),
      title: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
      ),
      actions: [
        IconButton(
          icon: Icon(
            isLight ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
            color: isLight? Colors.black : Colors.white,),
          onPressed: () {
            context.read<ThemeNotifier>().toggleTheme();
          },
        ),
        PopupMenuButton<int>(
          icon: Icon(
            Icons.menu_rounded,
            color: isLight? Colors.black : Colors.white,),
          onSelected: (index) {
            if (index == 0) {
              NavigationHelper.navigateToPage(context, const ProfilePage());
            } else if (index == 1) {
              onFitnessTestsSelected();
            } else if (index == 2) {
              onPerformanceSelected();
            } else if (index == 3) {
              onLeaderboardSelected();
            } else if (index == 4) {
              onAICoachSelected();
            } else if (index == 5) {
              onChallengesSelected();
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 0,
              child: Row(
                children: [
                  ProfileAvatar(
                    radius: 18,
                    imageUrl: userProfile?.avatarUrl,
                  ),
                  const SizedBox(width: 8),
                  const Text('Profile'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 1,
              child: Row(
                children: [
                  Icon(Icons.fitness_center, color: isLight? Colors.black : Colors.white,),
                  SizedBox(width: 8),
                  Text('Fitness Tests'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 2,
              child: Row(
                children: [
                  Icon(Icons.show_chart, color: isLight? Colors.black : Colors.white,),
                  SizedBox(width: 8),
                  Text('Performance'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 3,
              child: Row(
                children: [
                  Icon(Icons.leaderboard, color: isLight? Colors.black : Colors.white,),
                  SizedBox(width: 8),
                  Text('Leaderboard'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 4,
              child: Row(
                children: [
                  Icon(Icons.psychology, color: isLight? Colors.black : Colors.white,),
                  SizedBox(width: 8),
                  Text('AI Coach'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 5,
              child: Row(
                children: [
                  Icon(Icons.military_tech, color: isLight? Colors.black : Colors.white,),
                  SizedBox(width: 8),
                  Text('Challenges'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}