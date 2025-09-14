import 'package:flutter/material.dart';
import 'package:khelpratibha/models/goal.dart';
import 'package:khelpratibha/services/database_service.dart';
import 'package:provider/provider.dart';

class GoalsTab extends StatelessWidget {
  const GoalsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: FutureBuilder<List<Goal>>(
        future: context.read<DatabaseService>().fetchGoals(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No goals set yet.'));
          }
          final goals = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Your Goals',
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              ...goals.map((goal) => GoalCard(goal: goal)),
            ],
          );
        },
      ),
    );
  }
}

class GoalCard extends StatelessWidget {
  final Goal goal;
  const GoalCard({super.key, required this.goal});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Icon(
          goal.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
          color: goal.isCompleted ? Colors.green : Colors.grey,
        ),
        title: Text(
          goal.description,
          style: TextStyle(
            decoration: goal.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
      ),
    );
  }
}