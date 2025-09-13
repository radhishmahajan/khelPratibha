// lib/models/user_role.dart

enum UserRole { player, coach, scout, unknown }

UserRole userRoleFromString(String role) {
  switch (role.toLowerCase()) {
    case 'player':
      return UserRole.player;
    case 'coach':
      return UserRole.coach;
    case 'scout':
      return UserRole.scout;
    default:
      return UserRole.unknown;
  }
}
