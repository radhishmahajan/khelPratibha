import 'package:flutter/material.dart';
import 'package:khelpratibha/models/sport_category.dart';
import 'package:khelpratibha/models/user_role.dart';
import 'package:khelpratibha/screens/dashboard/player/player_dashboard.dart';
import 'package:khelpratibha/screens/dashboard/scout/scout_dashboard.dart';

class NavigationHelper {

  // This function is for navigating from the category selection screen
  static void navigateToDashboard(BuildContext context, UserRole role, SportCategory category) {
    final dashboard = getDashboardFromRole(role, category);
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => dashboard));
  }

  // This function is for navigating directly from the AuthGate
  static Widget getDashboardFromRole(UserRole role, SportCategory category) {
    switch (role) {
      case UserRole.player:
        return PlayerDashboard(category: category);
      case UserRole.scout:
        return ScoutDashboard(category: category);
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