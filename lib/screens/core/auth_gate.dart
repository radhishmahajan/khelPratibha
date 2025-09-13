import 'package:flutter/material.dart';
import 'package:khelpratibha/models/user_role.dart';
import 'package:khelpratibha/providers/user_provider.dart';
import 'package:khelpratibha/screens/auth/login_page.dart';
import 'package:khelpratibha/screens/core/role_selection_page.dart';
import 'package:khelpratibha/services/auth_service.dart';
import 'package:khelpratibha/utils/navigation_helper.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    // Start listening to auth changes as soon as the widget is initialized.
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final Session? session = data.session;
      if (session != null) {
        // When a user logs in, fetch their profile immediately.
        context.read<UserProvider>().fetchUserProfile(session.user.id);
      } else {
        // When a user logs out, clear their data.
        context.read<UserProvider>().clearUserProfile();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch both the auth service and user provider for changes.
    final authService = context.watch<AuthService>();
    final userProvider = context.watch<UserProvider>();
    final session = authService.currentSession;

    if (session != null) {
      // If the user is logged in, we determine the state of their profile.
      if (userProvider.isLoading) {
        // If the profile is actively being fetched, show a loading spinner.
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }

      // If loading is finished, but the profile is null or the role is unknown,
      // the user needs to select their role. This handles new users correctly.
      if (userProvider.userProfile == null || userProvider.userProfile!.role == UserRole.unknown) {
        return const RoleSelectionPage();
      }

      // If we have a profile with a known role, navigate to their dashboard.
      return NavigationHelper.getDashboardFromRole(userProvider.userProfile!.role);

    } else {
      // If there is no session, the user is not logged in.
      return const LoginPage();
    }
  }
}

