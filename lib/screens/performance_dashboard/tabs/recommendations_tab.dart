import 'package:flutter/material.dart';
import 'package:khelpratibha/models/recommendation.dart';
import 'package:khelpratibha/services/database_service.dart';
import 'package:provider/provider.dart';

class RecommendationsTab extends StatelessWidget {
  const RecommendationsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: FutureBuilder<List<Recommendation>>(
        future: context.read<DatabaseService>().fetchRecommendations(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No recommendations available yet.'));
          }
          final recommendations = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Training Recommendations',
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              ...recommendations.map((rec) => RecommendationCard(recommendation: rec)),
            ],
          );
        },
      ),
    );
  }
}

class RecommendationCard extends StatelessWidget {
  final Recommendation recommendation;
  const RecommendationCard({super.key, required this.recommendation});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: const Icon(Icons.lightbulb_outline, color: Colors.amber),
        title: Text(recommendation.text),
      ),
    );
  }
}