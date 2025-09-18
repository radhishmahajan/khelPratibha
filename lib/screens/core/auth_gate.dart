import 'package:flutter/material.dart';
import 'package:khelpratibha/models/user_role.dart';
import 'package:khelpratibha/providers/user_provider.dart';
import 'package:khelpratibha/screens/auth/login_page.dart';
import 'package:khelpratibha/screens/core/home_page.dart';
import 'package:khelpratibha/screens/core/role_selection_page.dart';
import 'package:khelpratibha/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch the AuthService for login/logout events
    return StreamBuilder<AuthState>(
      stream: context.watch<AuthService>().authStateChanges,
      builder: (context, snapshot) {
        final session = snapshot.data?.session;

        if (session != null) {
          // If the user is logged in, watch the UserProvider for profile changes
          return Consumer<UserProvider>(
            builder: (context, userProvider, child) {
              // Fetch initial data if the profile hasn't been loaded yet
              if (userProvider.userProfile == null && !userProvider.isLoading) {
                // Use a post-frame callback to avoid calling provider during build
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  userProvider.fetchInitialData(session.user.id);
                });
              }

              if (userProvider.isLoading || userProvider.userProfile == null) {
                return const Scaffold(
                    body: Center(child: CircularProgressIndicator()));
              }

              final userProfile = userProvider.userProfile!;

              // Now, the navigation logic will react to any change in the user's role
              if (userProfile.role == UserRole.unknown) {
                return const RoleSelectionPage();
              } else {
                return const HomePage();
              }
            },
          );
        } else {
          // If there's no session, show the LoginPage
          return const LoginPage();
        }
      },
    );
  }
}