import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:khelpratibha/models/assessment.dart';
import 'package:khelpratibha/widgets/info_card.dart';

class AssessmentResultPage extends StatelessWidget {
  final Assessment assessment;
  const AssessmentResultPage({super.key, required this.assessment});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assessment Results'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Performance Analysis', style: theme.textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(
              'Metrics recorded on ${assessment.date.toLocal().toString().split(' ')[0]}',
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            _buildMetricsChart(),
            const SizedBox(height: 32),
            // CORRECTED: Passed a Text widget to the 'child' parameter instead of 'content'.
            InfoCard(
              title: 'AI Analysis',
              icon: Icons.psychology_alt_rounded,
              iconColor: Colors.purple,
              child: Text(assessment.analysis), // The 'analysis' getter exists on the model.
            ),
            const SizedBox(height: 24),
            _buildRecommendations(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsChart() {
    final metrics = assessment.metrics;
    final barGroups = <BarChartGroupData>[];
    int index = 0;
    metrics.forEach((key, value) {
      barGroups.add(
        BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(toY: value, color: Colors.blueAccent, width: 16, borderRadius: BorderRadius.circular(4))
          ],
        ),
      );
      index++;
    });

    final maxY = metrics.values.isEmpty
        ? 10.0
        : (metrics.values.reduce((a, b) => a > b ? a : b) * 1.2);

    return SizedBox(
      height: 250,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY,
          barGroups: barGroups,
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (double value, TitleMeta meta) {
                  if (value.toInt() >= metrics.keys.length) return const SizedBox.shrink();
                  final title = metrics.keys.elementAt(value.toInt()).replaceAll('_', ' ').toUpperCase();
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  );
                },
                reservedSize: 30,
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: true, drawVerticalLine: false),
        ),
      ),
    );
  }

  Widget _buildRecommendations(ThemeData theme) {
    // CORRECTED: Added a null check for recommendations before trying to access it.
    final recommendations = assessment.recommendations;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recommendations', style: theme.textTheme.headlineMedium),
        const SizedBox(height: 16),
        if (recommendations == null || recommendations.isEmpty)
          const Center(child: Text("No recommendations available.")),
        // Use the local, null-checked variable here.
        if (recommendations != null)
          ...recommendations.map(
                (rec) => Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: const Icon(Icons.star_rounded, color: Colors.amber),
                title: Text(rec),
              ),
            ),
          ),
      ],
    );
  }
}
