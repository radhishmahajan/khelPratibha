import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:khelpratibha/models/performance_session.dart';

class ActivityHistoryPage extends StatelessWidget {
  final String testName;
  final List<PerformanceSession> sessions;

  const ActivityHistoryPage(
      {super.key, required this.testName, required this.sessions});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(testName),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
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
            colors: [Color(0xFF0f0c29), Color(0xFF302b63), Color(0xFF24243e)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: sessions.length,
            itemBuilder: (context, index) {
              final session = sessions[index];
              final previousSession =
              (index + 1 < sessions.length) ? sessions[index + 1] : null;

              return _HistoryCard(
                session: session,
                previousSession: previousSession,
              );
            },
          ),
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final PerformanceSession session;
  final PerformanceSession? previousSession;

  const _HistoryCard({required this.session, this.previousSession});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    double? improvementPercentage;

    if (previousSession != null && previousSession!.score > 0) {
      improvementPercentage =
          ((session.score - previousSession!.score) / previousSession!.score) * 100;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: isLight
                ? Colors.white.withValues(alpha: 0.5)
                : Colors.black.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isLight
                  ? Colors.white.withValues(alpha: 0.7)
                  : Colors.grey.shade800,
            ),
          ),
          child: Row(
            children: [
              // Date Column
              Column(
                children: [
                  Text(
                    DateFormat('d').format(session.recordedAt),
                    style: theme.textTheme.headlineSmall,
                  ),
                  Text(
                    DateFormat('MMM').format(session.recordedAt).toUpperCase(),
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(width: 16),
              const VerticalDivider(width: 1),
              const SizedBox(width: 16),
              // Details Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Score: ${session.score.toStringAsFixed(1)}',
                      style: theme.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Reps: ${session.reps ?? 'N/A'}',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              // Improvement Indicator
              if (improvementPercentage != null)
                Column(
                  children: [
                    Icon(
                      improvementPercentage >= 0
                          ? Icons.arrow_upward_rounded
                          : Icons.arrow_downward_rounded,
                      color:
                      improvementPercentage >= 0 ? Colors.green : Colors.red,
                    ),
                    Text(
                      '${improvementPercentage.toStringAsFixed(0)}%',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: improvementPercentage >= 0
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}