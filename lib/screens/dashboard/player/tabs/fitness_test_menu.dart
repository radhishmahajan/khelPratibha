import 'package:flutter/material.dart';
import 'package:khelpratibha/screens/fitness_tracker/fitness_test_page.dart';

class FitnessTestMenu extends StatefulWidget {
  const FitnessTestMenu({super.key});

  @override
  State<FitnessTestMenu> createState() => _FitnessTestMenuState();
}

class _FitnessTestMenuState extends State<FitnessTestMenu> {
  String _searchQuery = '';

  final List<Map<String, dynamic>> fitnessTests = [
    {
      'category': 'Anthropometric Tests (Basic Measurements)',
      'icon': Icons.straighten,
      'tests': [
        'Height & Weight',
      ],
      'gradient': [const Color(0xFF43A047), const Color(0xFF66BB6A)],
    },
    {
      'category': 'Strength & Power Tests',
      'icon': Icons.fitness_center,
      'tests': [
        'Vertical Jump Test (measures leg explosive power)',
        'Standing Broad Jump (distance covered in one jump)',
        'Push-ups Test (upper body strength, reps in 1 min)',
        'Sit-ups / Crunch Test (core strength, reps in 1 min)',
      ],
      'gradient': [const Color(0xFFD84315), const Color(0xFFFF7043)],
    },
    {
      'category': 'Speed & Agility Tests',
      'icon': Icons.directions_run,
      'tests': [
        'Shuttle Run (20m / 40m) (tests speed + agility, back-and-forth sprint)',
        '30m Sprint (straight-line speed test)',
      ],
      'gradient': [const Color(0xFF00ACC1), const Color(0xFF26C6DA)],
    },
    {
      'category': 'Endurance Tests',
      'icon': Icons.timer,
      'tests': [
        '1.6 km (1 mile) Run/Walk Test (cardio endurance)',
        'Beep Test (Yo-Yo Test) (progressive endurance run, AI can detect laps & timing)',
      ],
      'gradient': [const Color(0xFFD81B60), const Color(0xFFF06292)],
    },
    {
      'category': 'Flexibility Tests',
      'icon': Icons.accessibility_new,
      'tests': [
        'Sit-and-Reach Test (lower back & hamstring flexibility)',
      ],
      'gradient': [const Color(0xFF5E35B1), const Color(0xFF7E57C2)],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const headerImage =
        'https://images.pexels.com/photos/841130/pexels-photo-841130.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2';
    const headerText = 'Fitness Tracker';

    final filteredTests = fitnessTests.where((category) {
      final categoryName = category['category'].toString().toLowerCase();
      final tests = (category['tests'] as List<String>)
          .where((test) => test.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
      return categoryName.contains(_searchQuery.toLowerCase()) || tests.isNotEmpty;
    }).toList();

    return ListView(
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
                  color: Colors.black.withValues(alpha: 0.4),
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
          final tests = (testCategory['tests'] as List<String>)
              .where((test) =>
              test.toLowerCase().contains(_searchQuery.toLowerCase()))
              .toList();
          if (tests.isEmpty && _searchQuery.isNotEmpty) {
            return const SizedBox.shrink(); // Hide category if no tests match search
          }
          return FitnessTestCard(
            category: testCategory['category'],
            icon: testCategory['icon'],
            tests: tests,
            gradient: testCategory['gradient'],
          );
        }).toList(),
      ],
    );
  }
}

class FitnessTestCard extends StatelessWidget {
  final String category;
  final IconData icon;
  final List<String> tests;
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
                            builder: (context) => FitnessTestPage(testName: test),
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
                                test,
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