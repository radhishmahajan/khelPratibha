import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:khelpratibha/models/performance_session.dart';
import 'package:khelpratibha/providers/session_provider.dart';
import 'package:provider/provider.dart';

class ProgressTab extends StatelessWidget {
  const ProgressTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SessionProvider>(
      builder: (context, sessionProvider, child) {
        if (sessionProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final sessions = sessionProvider.sessions;

        if (sessions.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 60, color: Colors.grey),
                SizedBox(height: 16),
                Text('No session history yet.'),
                Text('Complete a media analysis to see your progress.'),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: sessions.length,
          itemBuilder: (context, index) {
            final session = sessions[index];
            return SessionHistoryCard(session: session);
          },
        );
      },
    );
  }
}

class SessionHistoryCard extends StatelessWidget {
  final PerformanceSession session;

  const SessionHistoryCard({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formattedDate = DateFormat('MMM d, yyyy').format(session.createdAt);

    return SafeArea(
      child: Card(
        margin: const EdgeInsets.only(bottom: 10.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Session on $formattedDate',
                    style: theme.textTheme.titleMedium,
                  ),
                  Text(
                    'Score: ${session.score.toStringAsFixed(1)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              Text(
                'Feedback Received:',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              Text(
                session.feedback,
                style: theme.textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}