import 'package:flutter/material.dart';
import 'package:khelpratibha/providers/performance_provider.dart';
import 'package:provider/provider.dart';

class PersonalBestsPage extends StatelessWidget {
  const PersonalBestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final personalBests = context.watch<PerformanceProvider>().personalBests;

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Personal Bests'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: personalBests.length,
        itemBuilder: (context, index) {
          final best = personalBests[index];
          return _PersonalBestCard(best: best);
        },
      ),
    );
  }
}

class _PersonalBestCard extends StatelessWidget {
  final Map<String, dynamic> best;

  const _PersonalBestCard({required this.best});

  // Helper to get icon - you might move this to a utility class
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