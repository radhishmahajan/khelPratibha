import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:khelpratibha/models/leaderboard_entry.dart';
import 'package:khelpratibha/models/sport_program.dart';
import 'package:khelpratibha/services/database_service.dart';
import 'package:khelpratibha/widgets/profile_avatar.dart';
import 'package:provider/provider.dart';

class LeaderboardTab extends StatefulWidget {
  final SportProgram program;
  const LeaderboardTab({super.key, required this.program});

  @override
  State<LeaderboardTab> createState() => _LeaderboardTabState();
}

class _LeaderboardTabState extends State<LeaderboardTab>
    with SingleTickerProviderStateMixin {
  late Future<List<LeaderboardEntry>> _leaderboardFuture;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _leaderboardFuture = context
        .read<DatabaseService>()
        .fetchLeaderboard(widget.program.id);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: FutureBuilder<List<LeaderboardEntry>>(
        future: _leaderboardFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.leaderboard_outlined,
                      size: 60, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Leaderboard is empty.'),
                  Text('Complete sessions to see rankings.'),
                ],
              ),
            );
          }

          final leaderboard = snapshot.data!;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Top Performers',
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  itemCount: leaderboard.length,
                  itemBuilder: (context, index) {
                    final entry = leaderboard[index];
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.5),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: _animationController,
                          curve: Interval(
                            (0.2 * (index / leaderboard.length)),
                            1.0,
                            curve: Curves.easeOut,
                          ),
                        ),
                      ),
                      child: FadeTransition(
                        opacity: _animationController,
                        child: LeaderboardTile(entry: entry),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class LeaderboardTile extends StatelessWidget {
  final LeaderboardEntry entry;
  const LeaderboardTile({super.key, required this.entry});

  Widget _buildRankIcon(BuildContext context) {
    switch (entry.rank) {
      case 1:
        return const Icon(Icons.emoji_events, color: Colors.amber, size: 30);
      case 2:
        return Icon(Icons.emoji_events, color: Colors.grey[400], size: 30);
      case 3:
        return Icon(Icons.emoji_events,
            color: const Color(0xFFCD7F32), size: 30);
      default:
        return Text(
          '#${entry.rank}',
          style:
          Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;

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
              _buildRankIcon(context),
              const SizedBox(width: 16),
              ProfileAvatar(imageUrl: entry.avatarUrl, radius: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  entry.fullName,
                  style: theme.textTheme.titleMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                entry.averageScore.toStringAsFixed(1),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}