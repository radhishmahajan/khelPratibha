import 'package:flutter/material.dart';
import 'package:khelpratibha/config/theme_notifier.dart';
import 'package:khelpratibha/providers/user_provider.dart';
import 'package:khelpratibha/screens/dashboard/profile/user_profile_page.dart';
import 'package:khelpratibha/utils/navigation_helper.dart';
import 'package:khelpratibha/widgets/profile_avatar.dart';
import 'package:provider/provider.dart';

class ScoutDashboard extends StatelessWidget {
  const ScoutDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final userProfile = context.watch<UserProvider>().userProfile;
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final isLight = themeNotifier.themeMode == ThemeMode.light;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Scout Dashboard'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(isLight ? Icons.dark_mode : Icons.light_mode),
            color: isLight ? Colors.black : Colors.white,
            onPressed: () => themeNotifier.toggleTheme(),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: GestureDetector(
              onTap: () =>
                  NavigationHelper.navigateToPage(context, const ProfilePage()),
              child: Hero(
                tag: "user-avatar",
                child: ProfileAvatar(imageUrl: userProfile?.avatarUrl, radius: 20),
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
            colors: [Color(0xFF0f0c29), Color(0xFF302b63), Color(0xFF24243e)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_rounded, size: 100, color: Colors.orange),
              SizedBox(height: 20),
              Text(
                'Discover Players',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.0),
                child: Text(
                  'A searchable list of available players and their stats will appear here.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}