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
  final SportCategory? selectedCategory; // <-- ADDED THIS FIELD

  UserProfile({
    required this.id,
    required this.email,
    required this.role,
    this.fullName,
    this.avatarUrl,
    this.dateOfBirth,
    this.sport,
    this.selectedCategory, // <-- ADDED TO CONSTRUCTOR
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
      // Read the new field from the map
      selectedCategory: sportCategoryFromString(map['selected_category']),
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
      // Write the new field to the map
      'selected_category': selectedCategory?.name,
      'updated_at': DateTime.now().toIso8601String(),
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
    SportCategory? selectedCategory, // <-- ADDED TO COPYWITH
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
    );
  }
}