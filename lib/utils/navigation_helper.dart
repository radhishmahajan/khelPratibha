import 'package:flutter/material.dart';
import 'package:khelpratibha/models/user_role.dart';
import 'package:khelpratibha/screens/dashboard/player/player_dashboard.dart';
import 'package:khelpratibha/screens/dashboard/scout/scout_dashboard.dart';

// REMOVED import for coach_dashboard.dart

class NavigationHelper {
  static Widget getDashboardFromRole(UserRole role) {
    switch (role) {
      case UserRole.player:
        return const PlayerDashboard();
      case UserRole.scout:
        return const ScoutDashboard();
    // REMOVED the case for UserRole.coach
      default:
        return const Scaffold(
          body: Center(
            child: Text('Error: Unknown user role.'),
          ),
        );
    }
  }

  static void navigateToPage(BuildContext context, Widget page) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => page),
    );
  }
}