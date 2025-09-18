import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:khelpratibha/config/theme_notifier.dart';
import 'package:khelpratibha/models/challenge.dart';
import 'package:khelpratibha/providers/challenge_provider.dart';
import 'package:khelpratibha/models/challenge_leaderboard_entry.dart';
import 'package:khelpratibha/screens/challenges/complete_challenge_page.dart';
import 'package:khelpratibha/widgets/profile_avatar.dart';
import 'package:provider/provider.dart';
import 'dart:math';


class ChallengeDetailPage extends StatefulWidget {
  final Challenge challenge;

  const ChallengeDetailPage({super.key, required this.challenge});

  @override
  State<ChallengeDetailPage> createState() => _ChallengeDetailPageState();
}

class _ChallengeDetailPageState extends State<ChallengeDetailPage> {
  Future<List<ChallengeLeaderboardEntry>>? _leaderboardFuture;
  late Timer _timer;
  late DateTime _endTime;

  @override
  void initState() {
    super.initState();
    _leaderboardFuture = context.read<ChallengeProvider>().fetchChallengeLeaderboard(widget.challenge.id);
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    _endTime = DateTime.now().add(Duration(minutes: 5 + Random().nextInt(10)));
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (DateTime.now().isAfter(_endTime)) {
        timer.cancel();
        // Here you can add logic to reset the challenge or notify the user
        // For now, we'll just restart the timer.
        setState(() {
          _startTimer();
        });
      }
      setState(() {});
    });
  }

  String _formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return [if (duration.inHours > 0) hours, minutes, seconds].join(':');
  }

  void _onJoinChallenge() async {
    await context.read<ChallengeProvider>().joinChallenge(widget.challenge.id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You have joined the challenge!'),
          backgroundColor: Colors.green,
        ),
      );
      // Refresh the page or navigate back
      Navigator.of(context).pop();
    }
  }

  void _onStartTest() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CompleteChallengePage(challenge: widget.challenge),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = Provider.of<ThemeNotifier>(context).themeMode == ThemeMode.light;
    final remainingTime = _endTime.difference(DateTime.now());

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(widget.challenge.title),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildChallengeDetailsCard(theme, isLight, remainingTime),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: widget.challenge.isJoined
                    ? _buildStartTestButton(theme)
                    : _buildJoinButton(theme),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Leaderboard',
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: FutureBuilder<List<ChallengeLeaderboardEntry>>(
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
                        child: Text('No one has participated in this challenge yet.'),
                      );
                    }

                    final leaderboard = snapshot.data!;
                    return ListView.builder(
                      itemCount: leaderboard.length,
                      itemBuilder: (context, index) {
                        final entry = leaderboard[index];
                        return _ChallengeLeaderboardCard(entry: entry, index: index);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChallengeDetailsCard(ThemeData theme, bool isLight, Duration remainingTime) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: isLight ? Colors.white.withValues(alpha: 0.5) : Colors.black.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isLight ? Colors.white.withValues(alpha: 0.7) : Colors.grey.shade800,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.challenge.title,
                style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                widget.challenge.description,
                style: theme.textTheme.bodyLarge?.copyWith(color: theme.hintColor),
              ),
              const SizedBox(height: 16),
              if (widget.challenge.isJoined)
                Row(
                  children: [
                    const Icon(Icons.timer, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(
                      'Time remaining: ${_formatTime(remainingTime)}',
                      style: theme.textTheme.titleMedium,
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    const Icon(Icons.star_outline, color: Colors.amber),
                    const SizedBox(width: 8),
                    Text(
                      'Goal: ${widget.challenge.goal.toStringAsFixed(0)} reps',
                      style: theme.textTheme.titleMedium,
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJoinButton(ThemeData theme) {
    return InkWell(
      onTap: _onJoinChallenge,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_task_outlined, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              'Join Challenge',
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartTestButton(ThemeData theme) {
    return InkWell(
      onTap: _onStartTest,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFEA3B81), Color(0xFF6B47EE)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.play_arrow, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              'Start Challenge Test',
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChallengeLeaderboardCard extends StatelessWidget {
  final ChallengeLeaderboardEntry entry;
  final int index;

  const _ChallengeLeaderboardCard({required this.entry, required this.index});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    Color rankColor = Colors.grey.shade600;

    if (index == 0) {
      rankColor = Colors.amber;
    } else if (index == 1) {
      rankColor = Colors.grey.shade400;
    } else if (index == 2) {
      rankColor = Colors.brown.shade400;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: isLight ? Colors.white.withValues(alpha: 0.5) : Colors.black.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isLight ? Colors.white.withValues(alpha: 0.7) : Colors.grey.shade800,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: rankColor.withValues(alpha: 0.2),
                  border: Border.all(color: rankColor, width: 2),
                ),
                child: Center(
                  child: Text(
                    (index + 1).toString(),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: rankColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              ProfileAvatar(
                imageUrl: entry.avatarUrl,
                radius: 20,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.fullName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Progress',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.hintColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Text(
                entry.progress.toStringAsFixed(1),
                style: theme.textTheme.headlineSmall?.copyWith(
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