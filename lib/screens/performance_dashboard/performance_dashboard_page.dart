// lib/screens/performance_dashboard/performance_dashboard_page.dart
import 'package:flutter/material.dart';
import 'tabs/overview_tab.dart';

class PerformanceDashboardPage extends StatelessWidget {
  const PerformanceDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4, // The number of tabs
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Performance Dashboard'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Overview'),
              Tab(text: 'Progress'),
              Tab(text: 'Media Analysis'),
              Tab(text: 'Goals'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            // We will build the content for the Overview tab.
            // The others can be placeholders for now.
            OverviewTab(),
            Center(child: Text('Progress Details Coming Soon')),
            Center(child: Text('Media Analysis Feature Coming Soon')),
            Center(child: Text('Goals Feature Coming Soon')),
          ],
        ),
      ),
    );
  }
}