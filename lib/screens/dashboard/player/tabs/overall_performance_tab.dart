import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:khelpratibha/models/performance_session.dart';
import 'package:khelpratibha/providers/performance_provider.dart';
import 'package:khelpratibha/screens/dashboard/player/tabs/activity_history_page.dart';
import 'package:khelpratibha/screens/dashboard/player/tabs/personal_bests_page.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class OverallPerformanceTab extends StatefulWidget {
  const OverallPerformanceTab({super.key});

  @override
  State<OverallPerformanceTab> createState() => _OverallPerformanceTabState();
}

class _OverallPerformanceTabState extends State<OverallPerformanceTab> {
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    final performanceProvider = context.watch<PerformanceProvider>();
    final performanceHistory = performanceProvider.performanceHistory;
    final personalBests = performanceProvider.personalBests;
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;

    // Group performance history by test name
    final Map<String, List<PerformanceSession>> categorySpecificHistory = {};
    for (var session in performanceHistory) {
      if (!categorySpecificHistory.containsKey(session.testName)) {
        categorySpecificHistory[session.testName] = [];
      }
      categorySpecificHistory[session.testName]!.add(session);
    }

    final categories = categorySpecificHistory.keys.toList();
    if (_selectedCategory == null && categories.isNotEmpty) {
      _selectedCategory = categories.first;
    }

    final selectedHistory = _selectedCategory != null
        ? categorySpecificHistory[_selectedCategory!] ?? [] // If lookup is null, use an empty list
        : performanceHistory;

    final Map<DateTime, double> dailyScores = {};
    for (var session in selectedHistory!) {
      final day = DateTime(
          session.recordedAt.year, session.recordedAt.month, session.recordedAt.day);
      dailyScores[day] = (dailyScores[day] ?? 0) + session.score;
    }

    final sortedDailyScores = dailyScores.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return performanceProvider.isLoading
        ? const Center(child: CircularProgressIndicator())
        : performanceHistory.isEmpty
        ? const Center(child: Text('No performance data available yet.'))
        : ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Text('Performance Overview',
            style: theme.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 18),
        // ENHANCED DROPDOWN
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: isLight
                    ? Colors.white.withValues(alpha: 0.5)
                    : Colors.black.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isLight
                      ? Colors.white.withValues(alpha: 0.7)
                      : Colors.grey.shade800,
                ),
              ),
              child: DropdownButton<String>(
                value: _selectedCategory,
                hint: const Text("Select a Category"),
                isExpanded: true,
                underline: const SizedBox.shrink(),
                icon: Icon(Icons.arrow_drop_down_rounded, color: theme.colorScheme.primary),
                dropdownColor: isLight ? Colors.white.withValues(alpha: 0.8) : Colors.black.withValues(alpha: 0.7),
                items: categories
                    .map((category) => DropdownMenuItem(
                  value: category,
                  child: Text(category, style: theme.textTheme.bodyLarge),
                ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: _PerformanceSummaryCard(
                title: 'Best Score',
                value: performanceProvider
                    .getBestScoreForCategory(_selectedCategory)
                    .toStringAsFixed(1),
                icon: Icons.emoji_events,
                startColor: const Color(0xFFF9A825),
                endColor: const Color(0xFFF57F17),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _PerformanceSummaryCard(
                title: 'Average Score',
                value: performanceProvider
                    .getAverageScoreForCategory(_selectedCategory)
                    .toStringAsFixed(1),
                icon: Icons.show_chart,
                startColor: const Color(0xFF42A5F5),
                endColor: const Color(0xFF1E88E5),
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        Text('Performance Trend',
            style: theme.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        SizedBox(
          height: 300,
          child: sortedDailyScores.isEmpty
              ? const _EmptyTrendPlaceholder()
              : sortedDailyScores.length == 1
              ? _SingleDayChart(dailyData: sortedDailyScores)
              : _MultiDayLineChart(dailyData: sortedDailyScores),
        ),
        const SizedBox(height: 22),
        Text('Progress Tracking',
            style: theme.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        ...categorySpecificHistory.entries.map((entry) {
          final testName = entry.key;
          final sessions = entry.value;
          sessions.sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
          final latestSession = sessions.first;
          final previousBestSession = sessions.length > 1 ? sessions[1] : null;

          return GestureDetector(
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => ActivityHistoryPage(
                    testName: testName,
                    sessions: sessions,
                  )));
            },
            child: _ProgressTrackingCard(
              session: latestSession,
              previousBestSession: previousBestSession,
            ),
          );
        }),
        const SizedBox(height: 22),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Personal Bests',
                style: theme.textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold)),
            if (personalBests.length > 3)
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const PersonalBestsPage()));
                },
                child: const Text('View All'),
              ),
          ],
        ),
        const SizedBox(height: 16),
        ...personalBests
            .take(3)
            .map((best) => _PersonalBestCard(best: best)),
      ],
    );
  }
}

class _PerformanceSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color startColor;
  final Color endColor;

  const _PerformanceSummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.startColor,
    required this.endColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [startColor, endColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: startColor.withValues(alpha: 0.25),
              blurRadius: 12,
              offset: const Offset(0, 6))
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white70, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Text(value,
                      style: theme.textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold)),
                ]),
          )
        ],
      ),
    );
  }
}

class _EmptyTrendPlaceholder extends StatelessWidget {
  const _EmptyTrendPlaceholder();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.show_chart,
            size: 56, color: theme.colorScheme.primary.withValues(alpha: 0.14)),
        const SizedBox(height: 12),
        Text('No trend data yet',
            style: theme.textTheme.bodyLarge
                ?.copyWith(color: theme.hintColor)),
      ]),
    );
  }
}

class _SingleDayChart extends StatelessWidget {
  final List<MapEntry<DateTime, double>> dailyData;
  const _SingleDayChart({required this.dailyData});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final date = dailyData.first.key;
    final value = dailyData.first.value;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.center,
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  barGroups: [
                    BarChartGroupData(x: 0, barRods: [
                      BarChartRodData(
                        toY: value,
                        width: 48,
                        borderRadius: BorderRadius.circular(10),
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.secondary
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        backDrawRodData: BackgroundBarChartRodData(
                            show: true,
                            toY: value * 1.1,
                            color: Colors.transparent),
                      )
                    ])
                  ],
                  maxY: (value * 1.3).clamp(50.0, double.infinity),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(DateFormat.yMMMd().format(date),
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.hintColor)),
          const SizedBox(height: 6),
          Text(value.toStringAsFixed(1),
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _MultiDayLineChart extends StatelessWidget {
  final List<MapEntry<DateTime, double>> dailyData;
  const _MultiDayLineChart({required this.dailyData});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spots = dailyData
        .map((e) => FlSpot(e.key.millisecondsSinceEpoch.toDouble(), e.value))
        .toList();

    final maxY = dailyData
        .map((e) => e.value)
        .fold<double>(0, (p, n) => n > p ? n : p) *
        1.20; // Increased buffer to 20%

    final minX = dailyData.first.key.millisecondsSinceEpoch.toDouble();
    final maxX = dailyData.last.key.millisecondsSinceEpoch.toDouble();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
                sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      if (value == meta.max || value == meta.min) return const SizedBox();
                      return Text(value.toInt().toString(),
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: theme.hintColor));
                    })),
            bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 32,
                    interval: (maxX - minX) / (dailyData.length > 1 ? dailyData.length - 1 : 1),
                    getTitlesWidget: (value, meta) {
                      if (value > maxX || value < minX) {
                        return const SizedBox.shrink();
                      }
                      final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                      return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(DateFormat('d MMM').format(date),
                              style: theme.textTheme.bodySmall
                                  ?.copyWith(color: theme.hintColor)));
                    })),
            topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false)),
          ),
          minY: 0,
          maxY: maxY.ceilToDouble(),
          minX: minX,
          maxX: maxX,
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              gradient: LinearGradient(colors: [
                theme.colorScheme.primary,
                theme.colorScheme.secondary
              ]),
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(colors: [
                  theme.colorScheme.primary.withValues(alpha: 0.18),
                  theme.colorScheme.secondary.withValues(alpha: 0.02)
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressTrackingCard extends StatelessWidget {
  final PerformanceSession session;
  final PerformanceSession? previousBestSession;

  const _ProgressTrackingCard({required this.session, this.previousBestSession});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    double? improvementPercentage;
    if (previousBestSession != null && previousBestSession!.score > 0) {
      improvementPercentage =
          ((session.score - previousBestSession!.score) /
              previousBestSession!.score) *
              100;
    }

    final bool isPositive = improvementPercentage != null && improvementPercentage >= 0;
    final bool isNegative = improvementPercentage != null && improvementPercentage < 0;


    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardColor.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                // Improvement Circle
                SizedBox(
                  width: 80,
                  child: CircularPercentIndicator(
                    radius: 36,
                    lineWidth: 8,
                    animation: true,
                    percent:
                    (improvementPercentage?.abs() ?? (session.score / 100))
                        .clamp(0.0, 1.0),
                    center: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (improvementPercentage != null)
                          Text(
                            "${improvementPercentage >= 0 ? '+' : '-'}${improvementPercentage.abs().toStringAsFixed(0)}%",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: improvementPercentage >= 0
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          )
                        else
                          Text(
                            session.score.toStringAsFixed(0),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        const SizedBox(height: 2),
                        Text(
                          improvementPercentage != null ? "Change" : "Score",
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: Colors.grey),
                        ),
                      ],
                    ),
                    circularStrokeCap: CircularStrokeCap.round,
                    linearGradient: isPositive
                        ? LinearGradient(
                      colors: [Colors.green.shade200, Colors.green.shade600],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                        : isNegative
                        ? LinearGradient(
                      colors: [Colors.red.shade200, Colors.red.shade600],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                        : LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.secondary,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    backgroundColor: Colors.grey.shade200,
                  ),
                ),
                const SizedBox(width: 16),

                // Score Comparison
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(session.testName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          )),
                      const SizedBox(height: 6),
                      Text(DateFormat.yMMMd().format(session.recordedAt),
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: Colors.grey)),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Previous Best Score
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color:
                                theme.colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  Text("Previous Best",
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(color: theme.hintColor)),
                                  const SizedBox(height: 4),
                                  Text(
                                    previousBestSession != null
                                        ? previousBestSession!.score
                                        .toStringAsFixed(1)
                                        : "-",
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          // Current Score
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    theme.colorScheme.primary,
                                    theme.colorScheme.secondary,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  Text("Current",
                                      style: theme.textTheme.bodySmall
                                          ?.copyWith(color: Colors.white70)),
                                  const SizedBox(height: 4),
                                  Text(
                                    session.score.toStringAsFixed(1),
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),

                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PersonalBestCard extends StatelessWidget {
  final Map<String, dynamic> best;

  const _PersonalBestCard({required this.best});

  IconData _getIconData(String? iconName) {
    switch (iconName) {
      case 'straighten':
        return Icons.straighten;
      case 'fitness_center':
        return Icons.fitness_center;
      case 'directions_run':
        return Icons.directions_run;
      case 'timer':
        return Icons.timer;
      case 'accessibility_new':
        return Icons.accessibility_new;
      default:
        return Icons.emoji_events; // Default icon
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 3,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.surfaceContainerHighest,
              theme.colorScheme.surface,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListTile(
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.secondary.withValues(alpha: 0.12),
            ),
            child: Icon(_getIconData(best['icon_name']),
                color: theme.colorScheme.secondary),
          ),
          title: Text(best['test_name'] ?? '',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          trailing: Text(
            'Score: ${best['best_score'].toStringAsFixed(1)} | Reps: ${best['best_reps']}',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
          ),
        ),
      ),
    );
  }
}