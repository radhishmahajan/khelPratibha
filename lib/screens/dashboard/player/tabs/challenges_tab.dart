import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:khelpratibha/models/challenge.dart';
import 'package:khelpratibha/providers/challenge_provider.dart';
import 'package:khelpratibha/screens/challenges/challenge_detail_page.dart';
import 'package:provider/provider.dart';

class ChallengesTab extends StatefulWidget {
  const ChallengesTab({super.key});

  @override
  State<ChallengesTab> createState() => _ChallengesTabState();
}

class _ChallengesTabState extends State<ChallengesTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChallengeProvider>().fetchChallenges();
    });
  }

  @override
  Widget build(BuildContext context) {
    final challengeProvider = context.watch<ChallengeProvider>();
    final availableChallenges = challengeProvider.availableChallenges;
    final joinedChallenges = challengeProvider.joinedChallenges;
    final theme = Theme.of(context);

    if (challengeProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Joined Challenges Section
          Text(
            'Joined Challenges',
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (joinedChallenges.isEmpty)
            const Text('You have not joined any challenges yet.')
          else
            ...joinedChallenges.map((challenge) => _ChallengeCard(challenge: challenge, isJoined: true)),
          const SizedBox(height: 32),
          // Available Challenges Section
          Text(
            'Available Challenges',
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (availableChallenges.isEmpty)
            const Text('No new challenges available at the moment.')
          else
            ...availableChallenges.map((challenge) => _ChallengeCard(challenge: challenge)),
        ],
      ),
    );
  }
}

class _ChallengeCard extends StatelessWidget {
  final Challenge challenge;
  final bool isJoined;

  const _ChallengeCard({required this.challenge, this.isJoined = false});

  Color _getColorForType(String type) {
    switch (type.toLowerCase()) {
      case 'strength':
        return Colors.redAccent;
      case 'endurance':
        return Colors.green;
      case 'agility':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    final typeColor = _getColorForType(challenge.type);

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ChallengeDetailPage(challenge: challenge),
          ),
        );
      },
      borderRadius: BorderRadius.circular(24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: isLight ? Colors.white.withValues(alpha: 0.5) : Colors.black.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isLight ? Colors.white.withValues(alpha: 0.7) : Colors.grey.shade800,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: typeColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              challenge.type.toUpperCase(),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: typeColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Icon(Icons.emoji_events, color: typeColor),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        challenge.title,
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        challenge.description,
                        style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'Goal: ${challenge.goal.toStringAsFixed(0)} reps',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
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