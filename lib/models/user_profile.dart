// lib/models/user_profile.dart
import 'package:khelpratibha/models/user_role.dart';

class UserProfile {
  final String id;
  final String email;
  final UserRole role;
  final String? fullName;
  final String? avatarUrl;
  final DateTime? dateOfBirth;
  final String? sport;
  final double? heightCm;
  final double? weightKg;

  UserProfile({
    required this.id,
    required this.email,
    required this.role,
    this.fullName,
    this.avatarUrl,
    this.dateOfBirth,
    this.sport,
    this.heightCm,
    this.weightKg,
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
      heightCm: (map['height_cm'] as num?)?.toDouble(),
      weightKg: (map['weight_kg'] as num?)?.toDouble(),
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
      'updated_at': DateTime.now().toIso8601String(),
      'height_cm': heightCm,
      'weight_kg': weightKg,
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
    double? heightCm,
    double? weightKg,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      role: role ?? this.role,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      sport: sport ?? this.sport,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
    );
  }
}