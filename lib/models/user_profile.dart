import 'package:khelpratibha/models/sport_category.dart';
import 'package:khelpratibha/models/user_role.dart';

class UserProfile {
  final String id;
  final String email;
  final UserRole role;
  final String? fullName;
  final String? avatarUrl;
  final DateTime? dateOfBirth;
  final String? sport;
  final SportCategory? selectedCategory;
  final double? heightCm;
  final double? weightKg;
  final Map<String, dynamic>? personalBests;

  UserProfile({
    required this.id,
    required this.email,
    required this.role,
    this.fullName,
    this.avatarUrl,
    this.dateOfBirth,
    this.sport,
    this.selectedCategory,
    this.heightCm,
    this.weightKg,
    this.personalBests,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'],
      email: map['email'],
      role: userRoleFromString(map['role'] ?? 'Unknown'),
      fullName: map['full_name'],
      avatarUrl: map['avatar_url'],
      dateOfBirth: map['date_of_birth'] != null
          ? DateTime.tryParse(map['date_of_birth'])
          : null,
      sport: map['sport'],
      selectedCategory: sportCategoryFromString(map['selected_category']),
      heightCm: (map['height_cm'] as num?)?.toDouble(),
      weightKg: (map['weight_kg'] as num?)?.toDouble(),
      personalBests: map['personal_bests'] != null
          ? Map<String, dynamic>.from(map['personal_bests'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'role': role.name,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'sport': sport,
      'selected_category': selectedCategory?.name,
      'updated_at': DateTime.now().toIso8601String(),
      'height_cm': heightCm,
      'weight_kg': weightKg,
      'personal_bests': personalBests,
    };
  }

  UserProfile copyWith({
    String? id,
    String? email,
    UserRole? role,
    String? fullName,
    String? avatarUrl,
    DateTime? dateOfBirth,
    String? sport,
    SportCategory? selectedCategory,
    double? heightCm,
    double? weightKg,
    Map<String, dynamic>? personalBests,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      role: role ?? this.role,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      sport: sport ?? this.sport,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      personalBests: personalBests ?? this.personalBests,
    );
  }
}