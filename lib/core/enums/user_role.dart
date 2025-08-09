enum UserRole {
  owner('owner'),
  admin('admin'),
  diamond('diamond'),
  gold('gold'),
  silver('silver');

  const UserRole(this.value);
  final String value;

  static UserRole fromString(String? role) {
    switch (role?.toLowerCase()) {
      case 'owner':
        return UserRole.owner;
      case 'admin':
        return UserRole.admin;
      case 'diamond':
        return UserRole.diamond;
      case 'gold':
        return UserRole.gold;
      case 'silver':
        return UserRole.silver;
      default:
        return UserRole.silver; // Default to lowest permission level
    }
  }

  String get displayName {
    switch (this) {
      case UserRole.owner:
        return 'Owner';
      case UserRole.admin:
        return 'Admin';
      case UserRole.diamond:
        return 'Diamond';
      case UserRole.gold:
        return 'Gold';
      case UserRole.silver:
        return 'Silver';
    }
  }

  /// Returns true if this role has higher or equal permissions than the other role
  bool hasPermissionLevel(UserRole other) {
    const roleHierarchy = {
      UserRole.owner: 5,
      UserRole.admin: 4,
      UserRole.diamond: 3,
      UserRole.gold: 2,
      UserRole.silver: 1,
    };
    
    return (roleHierarchy[this] ?? 0) >= (roleHierarchy[other] ?? 0);
  }
}
