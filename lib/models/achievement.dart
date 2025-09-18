import 'package:flutter/material.dart';

class Achievement {
  final String id;
  final String key;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  Achievement({
    required this.id,
    required this.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  // Helper function to get an IconData from a string name
  static IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'fitness_center':
        return Icons.fitness_center;
      default:
        return Icons.emoji_events;
    }
  }

  // Helper function to parse a hex color string
  static Color _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    }
    return Color(int.parse(hexColor, radix: 16));
  }

  factory Achievement.fromMap(Map<String, dynamic> map) {
    return Achievement(
      id: map['id'],
      key: map['key'],
      title: map['title'],
      description: map['description'],
      icon: _getIconData(map['icon_name']),
      color: _getColorFromHex(map['color_hex']),
      isUnlocked: map['user_id'] != null,
      unlockedAt: map['unlocked_at'] != null
          ? DateTime.parse(map['unlocked_at'])
          : null,
    );
  }
}