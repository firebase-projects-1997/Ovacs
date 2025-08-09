import '../enums/permission_action.dart';
import '../enums/permission_resource.dart';
import '../enums/user_role.dart';
import '../enums/document_security_level.dart';

/// Permission configuration that matches the backend specification
/// This configuration can be easily modified to adjust permissions without code changes
class PermissionConfig {
  /// Role-based permission matrix
  /// This matches the backend permission_config.py specification
  static const Map<UserRole, Map<PermissionResource, List<PermissionAction>>>
  rolePermissions = {
    UserRole.owner: {
      PermissionResource.case_: [
        PermissionAction.create,
        PermissionAction.read,
        PermissionAction.update,
        PermissionAction.delete,
        PermissionAction.list,
        PermissionAction.assign,
        PermissionAction.unassign,
        PermissionAction.manageRoles,
      ],
      PermissionResource.client: [
        PermissionAction.create,
        PermissionAction.read,
        PermissionAction.update,
        PermissionAction.delete,
        PermissionAction.list,
      ],
      PermissionResource.session: [
        PermissionAction.create,
        PermissionAction.read,
        PermissionAction.update,
        PermissionAction.delete,
        PermissionAction.list,
      ],
      PermissionResource.document: [
        PermissionAction.create,
        PermissionAction.read,
        PermissionAction.update,
        PermissionAction.delete,
        PermissionAction.list,
      ],
      PermissionResource.documentGroup: [
        PermissionAction.create,
        PermissionAction.read,
        PermissionAction.update,
        PermissionAction.delete,
        PermissionAction.list,
      ],
      PermissionResource.message: [
        PermissionAction.create,
        PermissionAction.read,
        PermissionAction.update,
        PermissionAction.delete,
        PermissionAction.list,
      ],
    },
    UserRole.admin: {
      PermissionResource.case_: [
        PermissionAction.create,
        PermissionAction.read,
        PermissionAction.update,
        PermissionAction.delete,
        PermissionAction.list,
      ],
      PermissionResource.client: [PermissionAction.read, PermissionAction.list],
      PermissionResource.session: [
        PermissionAction.create,
        PermissionAction.read,
        PermissionAction.update,
        PermissionAction.delete,
        PermissionAction.list,
      ],
      PermissionResource.document: [
        PermissionAction.create,
        PermissionAction.read,
        PermissionAction.update,
        PermissionAction.delete,
        PermissionAction.list,
      ],
      PermissionResource.documentGroup: [
        PermissionAction.create,
        PermissionAction.read,
        PermissionAction.update,
        PermissionAction.delete,
        PermissionAction.list,
      ],
      PermissionResource.message: [
        PermissionAction.create,
        PermissionAction.read,
        PermissionAction.update,
        PermissionAction.delete,
        PermissionAction.list,
      ],
    },
    UserRole.diamond: {
      PermissionResource.case_: [PermissionAction.read, PermissionAction.list],
      PermissionResource.client: [PermissionAction.read, PermissionAction.list],
      PermissionResource.session: [
        PermissionAction.create,
        PermissionAction.read,
        PermissionAction.update,
        PermissionAction.delete,
        PermissionAction.list,
      ],
      PermissionResource.document: [
        PermissionAction.create,
        PermissionAction.read,
        PermissionAction.update,
        PermissionAction.delete,
        PermissionAction.list,
      ],
      PermissionResource.documentGroup: [
        PermissionAction.create,
        PermissionAction.read,
        PermissionAction.update,
        PermissionAction.delete,
        PermissionAction.list,
      ],
      PermissionResource.message: [
        PermissionAction.create,
        PermissionAction.read,
        PermissionAction.update,
        PermissionAction.delete,
        PermissionAction.list,
      ],
    },
    UserRole.gold: {
      PermissionResource.case_: [PermissionAction.read, PermissionAction.list],
      PermissionResource.client: [PermissionAction.read, PermissionAction.list],
      PermissionResource.session: [
        PermissionAction.read,
        PermissionAction.update,
        PermissionAction.list,
      ],
      PermissionResource.document: [
        PermissionAction.read,
        PermissionAction.list,
      ],
      PermissionResource.documentGroup: [
        PermissionAction.read,
        PermissionAction.list,
      ],
      PermissionResource.message: [
        PermissionAction.create,
        PermissionAction.read,
        PermissionAction.list,
      ],
    },
    UserRole.silver: {
      PermissionResource.case_: [PermissionAction.read, PermissionAction.list],
      PermissionResource.client: [PermissionAction.read, PermissionAction.list],
      PermissionResource.session: [
        PermissionAction.read,
        PermissionAction.list,
      ],
      PermissionResource.document: [
        PermissionAction.read,
        PermissionAction.list,
      ],
      PermissionResource.documentGroup: [
        PermissionAction.read,
        PermissionAction.list,
      ],
      PermissionResource.message: [
        PermissionAction.create,
        PermissionAction.read,
        PermissionAction.list,
      ],
    },
  };

  /// Document security level access matrix
  /// Defines which roles can access which document security levels
  static const Map<DocumentSecurityLevel, List<UserRole>>
  documentSecurityAccess = {
    DocumentSecurityLevel.red: [UserRole.owner, UserRole.admin],
    DocumentSecurityLevel.yellow: [
      UserRole.owner,
      UserRole.admin,
      UserRole.diamond,
    ],
    DocumentSecurityLevel.green: [
      UserRole.owner,
      UserRole.admin,
      UserRole.diamond,
      UserRole.gold,
      UserRole.silver,
    ],
  };

  /// Get permissions for a specific role
  static Map<PermissionResource, List<PermissionAction>>? getPermissionsForRole(
    UserRole role,
  ) {
    return rolePermissions[role];
  }

  /// Check if a role has a specific permission
  static bool hasPermission(
    UserRole role,
    PermissionResource resource,
    PermissionAction action,
  ) {
    final rolePerms = rolePermissions[role];
    if (rolePerms == null) return false;

    final resourcePerms = rolePerms[resource];
    if (resourcePerms == null) return false;

    return resourcePerms.contains(action);
  }

  /// Check if a role can access a document security level
  static bool canAccessDocumentLevel(
    UserRole role,
    DocumentSecurityLevel level,
  ) {
    final allowedRoles = documentSecurityAccess[level];
    return allowedRoles?.contains(role) ?? false;
  }

  /// Get all resources a role can access
  static List<PermissionResource> getAccessibleResources(UserRole role) {
    final rolePerms = rolePermissions[role];
    if (rolePerms == null) return [];

    return rolePerms.keys.toList();
  }

  /// Get all actions a role can perform on a resource
  static List<PermissionAction> getResourceActions(
    UserRole role,
    PermissionResource resource,
  ) {
    final rolePerms = rolePermissions[role];
    if (rolePerms == null) return [];

    return rolePerms[resource] ?? [];
  }

  /// Get document security levels accessible by a role
  static List<DocumentSecurityLevel> getAccessibleDocumentLevels(
    UserRole role,
  ) {
    return documentSecurityAccess.entries
        .where((entry) => entry.value.contains(role))
        .map((entry) => entry.key)
        .toList();
  }
}
