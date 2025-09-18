import 'package:flutter/material.dart';
import 'package:khelpratibha/models/fitness_test.dart';
import 'package:khelpratibha/models/fitness_test_category.dart';
import 'package:khelpratibha/providers/fitness_provider.dart';
import 'package:khelpratibha/screens/fitness_tests/test_detail_page.dart';
import 'package:khelpratibha/utils/navigation_helper.dart';
import 'package:provider/provider.dart';

class FitnessTestMenu extends StatefulWidget {
  const FitnessTestMenu({super.key});

  @override
  State<FitnessTestMenu> createState() => _FitnessTestMenuState();
}

class _FitnessTestMenuState extends State<FitnessTestMenu> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FitnessProvider>().fetchFitnessTests();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = Theme.of(context).brightness == Brightness.light;
    final fitnessProvider = context.watch<FitnessProvider>();
    final fitnessTestCategories = fitnessProvider.fitnessTestCategories;

    return fitnessProvider.isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
      padding:
      const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Fitness\nAssessment\nTests",
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isLight ? Colors.black : Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Complete all standardized fitness tests to get your comprehensive athletic profile",
              style: theme.textTheme.bodyLarge?.copyWith(
                color:
                (isLight ? Colors.black : Colors.white).withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 32),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 8.0),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "Available Tests",
                  style: theme.textTheme.labelLarge?.copyWith(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ...fitnessTestCategories.map((category) => Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: FitnessCategoryCard(
                category: category,
                isLight: isLight,
              ),
            )),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class FitnessCategoryCard extends StatelessWidget {
  final FitnessTestCategory category;
  final bool isLight;

  const FitnessCategoryCard({
    super.key,
    required this.category,
    required this.isLight,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color:
        isLight ? Colors.white : theme.colorScheme.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: isLight ? Colors.grey.shade200 : Colors.grey.shade800),
        boxShadow: [
          BoxShadow(
            color: isLight
                ? Colors.grey.withOpacity(0.1)
                : Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(category.icon,
                  color: isLight ? Colors.deepPurple : Colors.cyanAccent),
              const SizedBox(width: 12),
              Text(
                category.category,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isLight ? Colors.black : Colors.white,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          ...category.tests.map(
                (test) => Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: FitnessTestTile(
                test: test,
                isLight: isLight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FitnessTestTile extends StatelessWidget {
  final FitnessTest test;
  final bool isLight;

  const FitnessTestTile({
    super.key,
    required this.test,
    required this.isLight,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () {
        NavigationHelper.navigateToPage(context, TestDetailPage(test: test));
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withOpacity(isLight ? 0.5 : 0.2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Section: Icon and Title
            Row(
              children: [
                Icon(test.icon, color: theme.colorScheme.primary, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    test.name,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Middle Section: Description
            Text(
              test.description,
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
            ),
            const SizedBox(height: 16),

            // Bottom Section: Tags and Button
            Row(
              children: [
                _buildTag(test.duration, Colors.blueGrey, isLight),
                const SizedBox(width: 8),
                _buildTag(test.difficulty, Colors.deepOrange, isLight),
                const Spacer(),
                const Icon(Icons.play_circle_fill_rounded, color: Colors.green),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String text, Color color, bool isLight) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}