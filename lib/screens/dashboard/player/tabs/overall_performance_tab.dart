import 'dart:math';
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

enum TimeFrame { day, week, month }

class OverallPerformanceTab extends StatefulWidget {
  const OverallPerformanceTab({super.key});

  @override
  State<OverallPerformanceTab> createState() => _OverallPerformanceTabState();
}

class _OverallPerformanceTabState extends State<OverallPerformanceTab> {
  String? _selectedCategory;
  TimeFrame _selectedTimeFrame = TimeFrame.week;

  @override
  Widget build(BuildContext context) {
    final performanceProvider = context.watch<PerformanceProvider>();
    final performanceHistory = performanceProvider.performanceHistory;
    final personalBests = performanceProvider.personalBests;
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;

    final Map<String, List<PerformanceSession>> categorySpecificHistory = {};
    for (var session in performanceHistory) {
      if (!categorySpecificHistory.containsKey(session.testName)) {
        categorySpecificHistory[session.testName] = [];
      }
      categorySpecificHistory[session.testName]!.add(session);
    }

    final categories = categorySpecificHistory.keys.toSet().toList();
    if (_selectedCategory == null && categories.isNotEmpty) {
      _selectedCategory = categories.first;
    } else if (_selectedCategory != null &&
        !categories.contains(_selectedCategory)) {
      _selectedCategory = categories.isNotEmpty ? categories.first : null;
    }

    final selectedHistory = _selectedCategory != null
        ? categorySpecificHistory[_selectedCategory!] ?? []
        : performanceHistory;

    final Map<DateTime, double> aggregatedScores =
    _aggregateScores(selectedHistory);

    final List<MapEntry<DateTime, double>> chartData =
    _prepareChartData(aggregatedScores, _selectedTimeFrame);

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
        _buildDropdown(theme, isLight, categories),
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
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: isLight ? Colors.white : theme.colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Performance Trend',
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildTimeFrameSelector(theme),
              const SizedBox(height: 16),

              // Chart Title (e.g., "September 2025")
              Center(
                child: Text(
                  _getChartTitle(),
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),

              SizedBox(
                height: 300,
                child: chartData.isEmpty
                    ? const _EmptyTrendPlaceholder()
                    : _MultiDayLineChart(
                  dailyData: chartData,
                  timeFrame: _selectedTimeFrame,
                ),
              ),
            ],
          ),
        ),
        Text('Progress Tracking',
            style: theme.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        ...categorySpecificHistory.entries.map((entry) {
          final testName = entry.key;
          final sessions = entry.value;
          sessions.sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
          final latestSession = sessions.first;
          final previousBestSession =
          sessions.length > 1 ? sessions[1] : null;

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

  String _getChartTitle() {
    final now = DateTime.now();
    switch (_selectedTimeFrame) {
      case TimeFrame.day:
        return 'This Week';
      case TimeFrame.week:
        return DateFormat.yMMMM().format(now); // "September 2025"
      case TimeFrame.month:
        return DateFormat.y().format(now); // "2025"
    }
  }

  Map<DateTime, double> _aggregateScores(List<PerformanceSession> sessions) {
    final Map<DateTime, double> dailyScores = {};
    for (var session in sessions) {
      final day = DateTime(
          session.recordedAt.year, session.recordedAt.month, session.recordedAt.day);
      dailyScores[day] = (dailyScores[day] ?? 0) + session.score;
    }
    return dailyScores;
  }

  List<MapEntry<DateTime, double>> _prepareChartData(
      Map<DateTime, double> aggregatedScores, TimeFrame timeFrame) {
    final now = DateTime.now();
    final Map<DateTime, double> filledData = {};

    switch (timeFrame) {
      case TimeFrame.day:
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        for (int i = 0; i < 7; i++) {
          final day = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day + i);
          filledData[day] = aggregatedScores[day] ?? 0;
        }
        break;
      case TimeFrame.week:
        final firstDayOfMonth = DateTime(now.year, now.month, 1);
        for (int i = 0; i < 4; i++) {
          final weekStart = firstDayOfMonth.add(Duration(days: i * 7));
          if (weekStart.month != now.month) continue;

          final weekEnd = weekStart.add(const Duration(days: 6));
          double weekTotal = 0;

          aggregatedScores.forEach((day, score) {
            if (!day.isBefore(weekStart) && !day.isAfter(weekEnd)) {
              weekTotal += score;
            }
          });
          filledData[weekStart] = weekTotal;
        }
        break;
      case TimeFrame.month:
        for (int i = 1; i <= 12; i++) {
          final month = DateTime(now.year, i, 1);
          double monthTotal = 0;
          aggregatedScores.forEach((day, score) {
            if (day.year == month.year && day.month == month.month) {
              monthTotal += score;
            }
          });
          filledData[month] = monthTotal;
        }
        break;
    }
    return filledData.entries.toList();
  }

  Widget _buildTimeFrameSelector(ThemeData theme) {
    return Center(
      child: ToggleButtons(
        isSelected: [
          _selectedTimeFrame == TimeFrame.day,
          _selectedTimeFrame == TimeFrame.week,
          _selectedTimeFrame == TimeFrame.month,
        ],
        onPressed: (index) {
          setState(() {
            _selectedTimeFrame = TimeFrame.values[index];
          });
        },
        borderRadius: BorderRadius.circular(12),
        selectedColor: Colors.white,
        fillColor: theme.colorScheme.primary,
        children: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('Day'),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('Week'),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text('Month'),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(ThemeData theme, bool isLight, List<String> categories) {
    return ClipRRect(
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
            icon: Icon(Icons.arrow_drop_down_rounded,
                color: theme.colorScheme.primary),
            dropdownColor: isLight
                ? Colors.white.withValues(alpha: 0.8)
                : Colors.black.withValues(alpha: 0.7),
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
    );
  }
}

class _MultiDayLineChart extends StatelessWidget {
  final List<MapEntry<DateTime, double>> dailyData;
  final TimeFrame timeFrame;

  const _MultiDayLineChart({required this.dailyData, required this.timeFrame});

  double _getRoundedMaxY(double maxScore) {
    if (maxScore <= 10) return 10;
    final paddedMax = maxScore * 1.15;
    final numDigits = paddedMax.floor().toString().length;
    final roundingFactor = pow(10, numDigits - (numDigits > 2 ? 2 : 1));
    return ((paddedMax / roundingFactor).ceil() * roundingFactor).toDouble();
  }

  LineTouchData _buildLineTouchData(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;

    return LineTouchData(
      handleBuiltInTouches: true,
      touchTooltipData: LineTouchTooltipData(
        getTooltipItems: (List<LineBarSpot> touchedSpots) {
          return touchedSpots.map((spot) {
            final index = spot.spotIndex;
            if (index < 0 || index >= dailyData.length) return null;

            final date = dailyData[index].key;
            final score = dailyData[index].value;

            final dayText = DateFormat('E').format(date);
            final scoreText = 'Score: ${score.toStringAsFixed(0)}';

            return LineTooltipItem(
              '$dayText\n$scoreText',
              TextStyle(
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            );
          }).toList();
        },
      ),
      getTouchedSpotIndicator: (LineChartBarData barData,
          List<int> spotIndexes) {
        return spotIndexes.map((spotIndex) {
          return TouchedSpotIndicatorData(
            FlLine(
              color: isLight
                  ? Colors.blueAccent.withValues(alpha: 0.5)
                  : Colors.tealAccent.withValues(alpha: 0.6),
              strokeWidth: 2,
            ),
            FlDotData(
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 6.0,
                  color: isLight ? Colors.blueAccent : Colors.tealAccent,
                  strokeWidth: 2,
                  strokeColor: isLight ? Colors.white : Colors.black,
                );
              },
            ),
          );
        }).toList();
      },
    );
  }

    @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spots = dailyData
        .asMap()
        .entries
        .map((entry) => FlSpot(entry.key.toDouble(), entry.value.value))
        .toList();

    final double maxScore =
    dailyData.map((e) => e.value).fold(0.0, (p, n) => n > p ? n : p);
    final double maxY = _getRoundedMaxY(maxScore);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8),
      child: LineChart(
        LineChartData(
          lineTouchData: _buildLineTouchData(context),
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                interval: maxY > 0 ? maxY / 4 : 2.5,
                getTitlesWidget: (value, meta) {
                  if (value == meta.max) {
                    return const SizedBox.shrink();
                  }
                  return Text(
                    value.toInt().toString(),
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.hintColor),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= dailyData.length) {
                    return const SizedBox.shrink();
                  }
                  final date = dailyData[index].key;
                  String text;
                  switch (timeFrame) {
                    case TimeFrame.day:
                      text = DateFormat('E').format(date);
                      break;
                    case TimeFrame.week:
                      final weekOfMonth = (date.day / 7).ceil();
                      text = 'W$weekOfMonth';
                      break;
                    case TimeFrame.month:
                      text = DateFormat('MMM').format(date);
                      break;
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      text,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: theme.hintColor),
                    ),
                  );
                },
              ),
            ),
            topTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          minY: 0,
          maxY: maxY,
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              preventCurveOverShooting: true,
              gradient: LinearGradient(
                  colors: [theme.colorScheme.primary, theme.colorScheme.secondary]),
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(colors: [
                  theme.colorScheme.primary.withOpacity(0.18),
                  theme.colorScheme.secondary.withOpacity(0.02)
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// --- The following widgets remain unchanged ---

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
        return Icons.emoji_events;
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