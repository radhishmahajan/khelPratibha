import 'package:flutter/material.dart';

class FitnessTest {
  final String name;

  FitnessTest({required this.name});

  factory FitnessTest.fromMap(Map<String, dynamic> map) {
    return FitnessTest(
      name: map['name'] ?? '',
    );
  }
}

class FitnessTestCategory {
  final String category;
  final IconData icon;
  final List<FitnessTest> tests;
  final List<Color> gradient;

  FitnessTestCategory({
    required this.category,
    required this.icon,
    required this.tests,
    required this.gradient,
  });

  factory FitnessTestCategory.fromMap(Map<String, dynamic> map) {
    final tests = (map['fitness_tests'] as List)
        .map((test) => FitnessTest.fromMap(test))
        .toList();
    debugPrint(map.toString());
    return FitnessTestCategory(
      category: map['name'] ?? 'Unnamed Category',
      // CORRECTED: Now using the 'icon_name' from your Supabase table
      icon: _getIconData(map['icon_name']),
      tests: tests,
      gradient: _getGradient(map['gradient_colors']),
    );
  }

  static IconData _getIconData(String? iconName) {
    debugPrint(iconName);
    switch (iconName) {
      case 'straighten':
        return Icons.straighten;
      case 'fitness_center':
        return Icons.fitness_center;
      case 'directions_run':
        return Icons.directions_run;
      case 'timer':
        return Icons.timer;
      case 'accessibility_new':
        return Icons.accessibility_new;
      default:
        return Icons.help_outline; // Default icon if no match is found
    }
  }

  static List<Color> _getGradient(List<dynamic>? colors) {
    if (colors == null || colors.length < 2) {
      return [const Color(0xFF42A5F5), const Color(0xFF1E88E5)]; // Default gradient
    }
    return [
      Color(int.parse(colors[0].replaceAll('#', '0xFF'))),
      Color(int.parse(colors[1].replaceAll('#', '0xFF'))),
    ];
  }
}