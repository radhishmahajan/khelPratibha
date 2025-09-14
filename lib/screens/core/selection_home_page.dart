import 'package:flutter/material.dart';
import 'package:khelpratibha/models/sport_category.dart';
import 'package:khelpratibha/models/user_role.dart';
import 'package:khelpratibha/providers/user_provider.dart';
import 'package:khelpratibha/utils/navigation_helper.dart';
import 'package:provider/provider.dart';

class SelectionHomePage extends StatelessWidget {
  const SelectionHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userProvider = context.read<UserProvider>();
    final userProfile = userProvider.userProfile;


    void onCategorySelected(SportCategory category) async {
      if (userProfile?.role == UserRole.player) {
        final updatedProfile = userProfile!.copyWith(selectedCategory: category);
        await userProvider.saveUserProfile(updatedProfile);
      }
      if(context.mounted) {
        NavigationHelper.navigateToDashboard(
            context, userProfile!.role, category);
      }
    }

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Text(
                'Choose Your Arena',
                textAlign: TextAlign.center,
                style: theme.textTheme.displayMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
            SportCategoryCard(
              title: 'Olympics',
              description: 'Explore traditional Olympic sports including athletics, gymnastics, and more. Join the legacy of excellence.',
              imageUrl: 'https://images.pexels.com/photos/262524/pexels-photo-262524.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',
              tags: const ['Shooting', 'Archery', 'Gymnastics', 'Football', 'Karate'],
              buttonText: 'Explore Olympics',
              buttonColor: Colors.blue.shade700,
              label: 'Traditional Sports',
              onTap: () => onCategorySelected(SportCategory.olympics),
            ),
            const SizedBox(height: 24),
            SportCategoryCard(
              title: 'Paralympics',
              description: 'Discover sports that showcase incredible determination and skill. Redefine what\'s possible.',
              imageUrl: 'https://images.pexels.com/photos/8040663/pexels-photo-8040663.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2',
              tags: const ['Wheelchair Racing', 'Para Swimming', 'Blind Football'],
              buttonText: 'Explore Paralympics',
              buttonColor: Colors.red.shade700,
              label: 'Adaptive Sports',
              onTap: () => onCategorySelected(SportCategory.paralympics),
            ),
          ],
        ),
      ),
    );
  }
}

// Reusable card widget from the previous step
class SportCategoryCard extends StatelessWidget {
  final String title;
  final String description;
  final String imageUrl;
  final List<String> tags;
  final String buttonText;
  final Color buttonColor;
  final String label;
  final VoidCallback onTap;

  const SportCategoryCard({
    super.key,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.tags,
    required this.buttonText,
    required this.buttonColor,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(
            imageUrl,
            height: 180,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              height: 180,
              color: Colors.grey.shade800,
              child: const Icon(Icons.sports, size: 50, color: Colors.white),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: buttonColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(label, style: TextStyle(color: buttonColor, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(description, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: tags.map((tag) => Chip(
                    label: Text(tag),
                    backgroundColor: theme.colorScheme.secondary.withValues(alpha: 0.1),
                    side: BorderSide.none,
                  )).toList(),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(buttonText),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

