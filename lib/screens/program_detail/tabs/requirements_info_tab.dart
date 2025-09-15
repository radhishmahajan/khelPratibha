import 'dart:ui';
import 'package:flutter/material.dart';

class RequirementsInfoTab extends StatelessWidget {
  const RequirementsInfoTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Program Requirements & Information',
            style:
            theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Important details about the Sprinting program.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),
          const InfoCard(
            title: 'Equipment Requirements',
            icon: Icons.fitness_center,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                    child: InfoColumn(title: 'Essential Equipment', items: [
                      'Running spikes',
                      'Starting blocks',
                      'Performance tracking devices'
                    ])),
                SizedBox(width: 16),
                Expanded(
                    child: InfoColumn(title: 'Personal Items', items: [
                      'Athletic wear and shoes',
                      'Water bottle',
                      'Towel'
                    ])),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const InfoCard(
            title: 'Training Schedule',
            icon: Icons.calendar_today,
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ScheduleCard(
                      level: 'Beginner',
                      sessions: '3 sessions/week',
                      hours: '1.5 hours each'),
                  SizedBox(width: 16),
                  ScheduleCard(
                      level: 'Intermediate',
                      sessions: '4 sessions/week',
                      hours: '2 hours each'),
                  SizedBox(width: 16),
                  ScheduleCard(
                      level: 'Advanced',
                      sessions: '5-6 sessions/week',
                      hours: '2 hours each'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  const InfoCard(
      {super.key,
        required this.title,
        required this.icon,
        required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Icon(icon, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Text(title, style: theme.textTheme.titleLarge),
              ]),
              const Divider(height: 24),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class InfoColumn extends StatelessWidget {
  final String title;
  final List<String> items;
  const InfoColumn({super.key, required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 4.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('• ', style: TextStyle(fontSize: 16)),
              Expanded(child: Text(item, style: theme.textTheme.bodyMedium)),
            ],
          ),
        )),
      ],
    );
  }
}

class ScheduleCard extends StatelessWidget {
  final String level, sessions, hours;
  const ScheduleCard(
      {super.key,
        required this.level,
        required this.sessions,
        required this.hours});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;

    return Expanded(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            padding: const EdgeInsets.all(12),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  level,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(sessions,
                          style: theme.textTheme.bodySmall,
                          textAlign: TextAlign.center),
                      Text(hours,
                          style: theme.textTheme.bodySmall,
                          textAlign: TextAlign.center),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}