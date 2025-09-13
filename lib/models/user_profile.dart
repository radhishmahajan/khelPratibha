import 'package:khelpratibha/models/user_role.dart';

class UserProfile {
  final String id;
  final String email;
  final UserRole role;
  final String? fullName;
  final String? avatarUrl;
  final DateTime? dateOfBirth;
  final String? sport;

  UserProfile({
    required this.id,
    required this.email,
    required this.role,
    this.fullName,
    this.avatarUrl,
    this.dateOfBirth,
    this.sport,
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
    };
  }

  // CORRECTED: Added copyWith method for easier profile updates
  UserProfile copyWith({
    String? id,
    String? email,
    UserRole? role,
    String? fullName,
    String? avatarUrl,
    DateTime? dateOfBirth,
    String? sport,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      role: role ?? this.role,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      sport: sport ?? this.sport,
    );
  }
}

