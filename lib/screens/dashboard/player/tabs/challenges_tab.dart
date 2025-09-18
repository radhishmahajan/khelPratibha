import 'package:flutter/material.dart';
import 'package:khelpratibha/providers/challenge_provider.dart';
import 'package:khelpratibha/screens/challenges/challenge_detail_page.dart';
import 'package:provider/provider.dart';

class ChallengesTab extends StatelessWidget {
  const ChallengesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final challengeProvider = context.watch<ChallengeProvider>();
    final challenges = challengeProvider.challenges;
    final theme = Theme.of(context);

    return challengeProvider.isLoading
        ? const Center(child: CircularProgressIndicator())
        : challenges.isEmpty
        ? const Center(
      child: Text('No challenges available yet.'),
    )
        : ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: challenges.length,
      itemBuilder: (context, index) {
        final challenge = challenges[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            title: Text(challenge.title),
            subtitle: Text(challenge.description),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ChallengeDetailPage(challenge: challenge),
                ),
              );
            },
          ),
        );
      },
    );
  }
}