import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:khelpratibha/config/theme_notifier.dart';
import 'package:khelpratibha/models/sport_program.dart';
import 'package:provider/provider.dart';
import 'tabs/category_selection_tab.dart';
import 'tabs/requirements_info_tab.dart';

class ProgramDetailPage extends StatelessWidget {
  final SportProgram program;
  const ProgramDetailPage({super.key, required this.program});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final isLight = themeNotifier.themeMode == ThemeMode.light;

    final appBar = AppBar(
      title: Text('${program.title} Program'),
      backgroundColor: Colors.transparent,
      elevation: 0,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isLight
                    ? Colors.white.withValues(alpha: 0.5)
                    : Colors.black.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(50),
                border: Border.all(
                  color: isLight
                      ? Colors.white.withValues(alpha: 0.7)
                      : Colors.grey.shade800,
                ),
              ),
              child: const TabBar(
                tabs: [
                  Tab(text: 'Select Categories'),
                  Tab(text: 'Requirements & Info'),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: appBar,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: isLight
                ? const LinearGradient(
              colors: [Color(0xFFFFF1F5), Color(0xFFE8E2FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
                : const LinearGradient(
              colors: [
                Color(0xFF0f0c29),
                Color(0xFF302b63),
                Color(0xFF24243e)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.only(
              top: appBar.preferredSize.height +
                  MediaQuery.of(context).padding.top,
            ),
            child: TabBarView(
              children: [
                CategorySelectionTab(program: program),
                const RequirementsInfoTab(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}