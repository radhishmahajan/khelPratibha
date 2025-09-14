import 'package:flutter/material.dart';
import 'package:khelpratibha/models/sport_program.dart';

class SportProgramCard extends StatelessWidget {
  final SportProgram program;
  final VoidCallback onTap;
  final bool isJoined;

  const SportProgramCard({
    super.key,
    required this.program,
    required this.onTap,
    required this.isJoined,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 5,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- IMAGE SECTION with Gradient ---
            Stack(
              children: [
                Image.network(
                  program.imageUrl,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 150,
                    color: Colors.grey.shade800,
                    child: const Center(child: Icon(Icons.sports, size: 40)),
                  ),
                ),
                // Add a gradient overlay for better text readability
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.black.withValues(alpha: 0.6), Colors.transparent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  left: 12,
                  child: Chip(
                    label: Text(program.category),
                    backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.9),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    labelStyle: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    side: BorderSide.none,
                  ),
                ),
              ],
            ),

            // --- CONTENT SECTION (Flexible Layout) ---
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      program.title,
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    // Using Flexible allows the description to take available space
                    // without causing an overflow, which is more robust than Expanded.
                    Flexible(
                      child: Text(
                        program.description,
                        style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade400),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 3,
                      ),
                    ),
                    const Spacer(), // Pushes the stats to the bottom
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStat(context, Icons.people_alt_outlined, '${program.athleteCount} athletes'),
                        _buildStat(context, Icons.emoji_events_outlined, '${program.eventCount} events'),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // --- BUTTON SECTION ---
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(isJoined ? 'Join Program' : 'View Program'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper widget for consistent stat display
  Widget _buildStat(BuildContext context, IconData icon, String text) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.secondary),
        const SizedBox(width: 6),
        Text(text, style: theme.textTheme.bodySmall),
      ],
    );
  }
}

