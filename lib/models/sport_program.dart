import 'package:flutter/material.dart';

class SportProgram {
  final String id;
  final String title;
  final String description;
  final String category;
  final String subCategory;
  final String imageUrl;
  final int athleteCount;
  final int eventCount;

  const SportProgram({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.subCategory,
    required this.imageUrl,
    required this.athleteCount,
    required this.eventCount,
  });

  factory SportProgram.fromMap(Map<String, dynamic> map) {
    return SportProgram(
      id: map['id'] as String,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      subCategory: map['sub_category'] ?? '',
      imageUrl: map['image_url'] ?? '',
      athleteCount: map['athlete_count'] ?? 0,
      eventCount: map['event_count'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'sub_category': subCategory,
      'image_url': imageUrl,
      'athlete_count': athleteCount,
      'event_count': eventCount,
    };
  }
}