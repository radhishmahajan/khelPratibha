import 'package:flutter/material.dart';
import 'package:khelpratibha/models/user_profile.dart';
import 'package:khelpratibha/models/user_role.dart';
import 'package:khelpratibha/providers/user_provider.dart';
import 'package:khelpratibha/screens/auth/login_page.dart';
import 'package:khelpratibha/screens/core/role_selection_page.dart';
import 'package:khelpratibha/screens/core/selection_home_page.dart';
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
  Future<UserProfile?>? _profileFuture;

  Future<UserProfile?> _fetchInitialData(BuildContext context, String userId) async {
    final userProvider = context.read<UserProvider>();
    // This fetches all user data and stores it in the provider
    await userProvider.fetchInitialData(userId);
    // We return the profile to the FutureBuilder to reliably control navigation
    return userProvider.userProfile;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: context.watch<AuthService>().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final session = snapshot.data?.session;

        if (session != null) {
          // This ensures the data is fetched only once per login session.
          _profileFuture ??= _fetchInitialData(context, session.user.id);

          return FutureBuilder<UserProfile?>(
            future: _profileFuture,
            builder: (context, profileSnapshot) {
              if (profileSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }

              if (profileSnapshot.hasError || !profileSnapshot.hasData || profileSnapshot.data == null) {
                return Scaffold(
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Failed to load user profile.'),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            setState(() { _profileFuture = null; });
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final userProfile = profileSnapshot.data!;

              if (userProfile.role == UserRole.unknown) {
                return const RoleSelectionPage();
              } else if (userProfile.role == UserRole.scout) {
                return const SelectionHomePage();
              } else if (userProfile.role == UserRole.player) {
                if (userProfile.selectedCategory != null) {
                  return NavigationHelper.getDashboardFromRole(
                    userProfile.role,
                    userProfile.selectedCategory!,
                  );
                } else {
                  return const SelectionHomePage();
                }
              }

              return const LoginPage();
            },
          );
        } else {
          // When the user logs out, we clear the future so the next login can fetch new data.
          _profileFuture = null;
          return const LoginPage();
        }
      },
    );
  }
}