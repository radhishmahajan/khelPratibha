import 'package:flutter/material.dart';
import 'package:khelpratibha/models/user_role.dart';
import 'package:khelpratibha/providers/user_provider.dart';
import 'package:khelpratibha/screens/auth/login_page.dart';
import 'package:khelpratibha/screens/core/role_selection_page.dart';
import 'package:khelpratibha/services/auth_service.dart';
import 'package:khelpratibha/utils/navigation_helper.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    // Listen to the auth state stream from your AuthService.
    return StreamBuilder<AuthState>(
      stream: context.watch<AuthService>().authStateChanges,
      builder: (context, snapshot) {
        // While waiting for the first auth event, show a loading screen.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final session = snapshot.data?.session;

        if (session != null) {
          // If a user is logged in, use a FutureBuilder to load their profile.
          // This ensures data fetching happens outside of the main build cycle.
          return FutureBuilder(
            future: _getProfile(context, session.user.id),
            builder: (context, profileSnapshot) {
              if (profileSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }

              // After fetching, watch the provider for the profile data.
              final userProfile = context.watch<UserProvider>().userProfile;

              if (userProfile == null || userProfile.role == UserRole.unknown) {
                return const RoleSelectionPage();
              } else {
                return NavigationHelper.getDashboardFromRole(userProfile.role);
              }
            },
          );
        } else {
          // If no session, show the login page.
          return const LoginPage();
        }
      },
    );
  }

  // This helper function ensures we only fetch the profile if it's not already in the provider.
  Future<void> _getProfile(BuildContext context, String userId) async {
    final userProvider = context.read<UserProvider>();
    if (userProvider.userProfile?.id != userId) {
      await userProvider.fetchUserProfile(userId);
    }
  }
}
