import 'package:flutter/material.dart';
import 'package:khelpratibha/models/sport_category.dart';
import 'package:khelpratibha/models/sport_program.dart';
import 'package:khelpratibha/screens/dashboard/common/generic_dashboard_scaffold.dart';
import 'package:khelpratibha/screens/program_detail/program_detail_page.dart';

class PlayerDashboard extends StatelessWidget {
  final SportCategory category;
  const PlayerDashboard({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final categoryName =
        category.name[0].toUpperCase() + category.name.substring(1);

    void onProgramTap(SportProgram program) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ProgramDetailPage(program: program),
      ));
    }

    return GenericDashboardScaffold(
      appBarTitle: '$categoryName Programs',
      headerTitle: 'Choose Your Program',
      headerSubtitle: 'Select a sport to begin your assessment journey.',
      onProgramTap: onProgramTap,
      category: category,
    );
  }
}