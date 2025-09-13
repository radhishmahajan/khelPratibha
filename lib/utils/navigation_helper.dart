import 'package:flutter/material.dart';
import 'package:khelpratibha/models/user_role.dart';
import 'package:khelpratibha/screens/dashboard/coach/coach_dashboard.dart';
import 'package:khelpratibha/screens/dashboard/player/player_dashboard.dart';
import 'package:khelpratibha/screens/dashboard/scout/scout_dashboard.dart';

// A utility class to handle all navigation logic, keeping the UI code clean.
class NavigationHelper {
  // Determines the correct dashboard for a user based on their role.
  // This removes complex if/else logic from the AuthGate.
  static Widget getDashboardFromRole(UserRole role) {
    switch (role) {
      case UserRole.player:
        return const PlayerDashboard();
      case UserRole.coach:
        return const CoachDashboard();
      case UserRole.scout:
        return const ScoutDashboard();
    // A safe fallback to prevent crashes if an unexpected role is encountered.
      default:
        return const Scaffold(
          body: Center(
            child: Text('Error: Unknown user role.'),
          ),
        );
    }
  }

  // A standardized method for navigating to a new page with a clean animation.
  static void navigateToPage(BuildContext context, Widget page) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => page),
    );
  }
}

