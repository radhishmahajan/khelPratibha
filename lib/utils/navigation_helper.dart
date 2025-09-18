import 'package:flutter/material.dart';
import 'package:khelpratibha/models/user_role.dart';
import 'package:khelpratibha/screens/dashboard/player/player_dashboard.dart';
import 'package:khelpratibha/screens/dashboard/scout/scout_dashboard.dart';

class NavigationHelper {

  // This function is for navigating from the role selection screen
  static void navigateToDashboard(BuildContext context, UserRole role) {
    final dashboard = getDashboardFromRole(role);
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => dashboard));
  }

  // This function is for navigating directly from the AuthGate
  static Widget getDashboardFromRole(UserRole role) {
    switch (role) {
      case UserRole.player:
        return const PlayerDashboard();
      case UserRole.scout:
        return const ScoutDashboard();
      default:
        return const Scaffold(
          body: Center(child: Text('Error: Unknown user role.')),
        );
    }
  }

  static void navigateToPage(BuildContext context, Widget page) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => page),
    );
  }

  static void navigateToPageReplaced(BuildContext context, Widget page) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => page),
    );
  }
}