import 'package:flutter/material.dart';
import 'package:khelpratibha/models/fitness_test_category.dart';
import 'package:khelpratibha/providers/fitness_provider.dart';
import 'package:khelpratibha/screens/fitness_tracker/fitness_test_page.dart';
import 'package:provider/provider.dart';

class FitnessTestMenu extends StatefulWidget {
  const FitnessTestMenu({super.key});

  @override
  State<FitnessTestMenu> createState() => _FitnessTestMenuState();
}

class _FitnessTestMenuState extends State<FitnessTestMenu> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Fetch the fitness tests when the widget is first created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FitnessProvider>().fetchFitnessTests();
    });
  }

  @override
  Widget build(BuildContext context) {
    final fitnessProvider = context.watch<FitnessProvider>();
    final fitnessTests = fitnessProvider.fitnessTestCategories;
    final theme = Theme.of(context);
    const headerImage =
        'https://images.pexels.com/photos/841130/pexels-photo-841130.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2';
    const headerText = 'Fitness Tracker';

    final filteredTests = fitnessTests.where((category) {
      final categoryName = category.category.toLowerCase();
      final tests = category.tests
          .where((test) => test.name.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
      return categoryName.contains(_searchQuery.toLowerCase()) || tests.isNotEmpty;
    }).toList();

    return fitnessProvider.isLoading
        ? const Center(child: CircularProgressIndicator())
        : ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Header Section
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Image.network(
                headerImage,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              Container(
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                ),
              ),
              Text(
                headerText,
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Fitness Assessment',
          style: theme.textTheme.headlineMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Select a test to begin tracking your performance.',
          style: theme.textTheme.bodyLarge,
        ),
        const SizedBox(height: 24),

        // Search Bar
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: TextField(
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Search for a test...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),

        // Fitness Test Cards
        ...filteredTests.map((testCategory) {
          final tests = testCategory.tests
              .where((test) =>
              test.name.toLowerCase().contains(_searchQuery.toLowerCase()))
              .toList();
          if (tests.isEmpty && _searchQuery.isNotEmpty) {
            return const SizedBox.shrink(); // Hide category if no tests match search
          }
          return FitnessTestCard(
            category: testCategory.category,
            icon: testCategory.icon,
            tests: tests,
            gradient: testCategory.gradient,
          );
        }).toList(),
      ],
    );
  }
}

class FitnessTestCard extends StatelessWidget {
  final String category;
  final IconData icon;
  final List<FitnessTest> tests;
  final List<Color> gradient;

  const FitnessTestCard({
    super.key,
    required this.category,
    required this.icon,
    required this.tests,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: isLight ? Colors.white.withOpacity(0.8) : Colors.black.withOpacity(0.5),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      category,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24, color: Colors.white70),
              ...tests.map(
                    (test) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => FitnessTestPage(testName: test.name),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          color: isLight ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.play_circle_outline, color: Colors.white),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                test.name,
                                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white),
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}