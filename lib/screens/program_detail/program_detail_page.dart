import 'package:flutter/material.dart';
import 'package:khelpratibha/models/sport_program.dart';
import 'tabs/category_selection_tab.dart';
import 'tabs/requirements_info_tab.dart';

class ProgramDetailPage extends StatelessWidget {
  final SportProgram program;
  const ProgramDetailPage({super.key, required this.program});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('${program.title} Program'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Select Categories'),
              Tab(text: 'Requirements & Info'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            CategorySelectionTab(program: program),
            const RequirementsInfoTab(),
          ],
        ),
      ),
    );
  }
}