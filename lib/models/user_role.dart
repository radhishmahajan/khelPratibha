// lib/models/user_role.dart

enum UserRole { player, scout, unknown }

UserRole userRoleFromString(String role) {
  switch (role.toLowerCase()) {
    case 'player':
      return UserRole.player;
    case 'scout':
      return UserRole.scout;
    default:
      return UserRole.unknown;
  }
}
