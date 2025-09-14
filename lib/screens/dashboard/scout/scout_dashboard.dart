import 'package:flutter/material.dart';
import 'package:khelpratibha/data/program_data.dart';
import 'package:khelpratibha/models/sport_category.dart';
import 'package:khelpratibha/models/sport_program.dart';
import 'package:khelpratibha/screens/dashboard/common/generic_dashboard_scaffold.dart';

class ScoutDashboard extends StatelessWidget {
  final SportCategory category;
  const ScoutDashboard({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final categoryName = category.name[0].toUpperCase() + category.name.substring(1);
    void onProgramTap(SportProgram program){

    }
    return GenericDashboardScaffold(
      appBarTitle: 'Scout: $categoryName',
      headerTitle: 'Discover Talent',
      headerSubtitle: 'Browse programs to find and track promising athletes.',
      onProgramTap: onProgramTap,
      programs: category == SportCategory.olympics
          ? olympicPrograms
          : paralympicPrograms,
    );
  }
}