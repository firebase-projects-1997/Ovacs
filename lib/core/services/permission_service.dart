import '../../core/enums/permission_action.dart';
import '../../core/enums/permission_resource.dart';
import '../../core/enums/user_role.dart';
import '../../core/enums/document_security_level.dart';
import '../../core/config/permission_config.dart';
import '../../data/models/permission_model.dart';

class PermissionService {
  /// Use the centralized permission configuration
  static Map<UserRole, Map<PermissionResource, List<PermissionAction>>>
  get _defaultPermissions => PermissionConfig.rolePermissions;

  /// Check if a user has permission for a specific action on a resource
  static bool hasPermission(
    UserPermissionsModel? userPermissions,
    PermissionResource resource,
    PermissionAction action, {
    UserRole? fallbackRole,
  }) {
    // If we have actual permissions from the server, use those
    if (userPermissions != null) {
      return userPermissions.hasPermission(resource, action);
    }

    // Fallback to default permissions based on role
    if (fallbackRole != null) {
      final rolePermissions = _defaultPermissions[fallbackRole];
      final resourcePermissions = rolePermissions?[resource];
      return resourcePermissions?.contains(action) ?? false;
    }

    // No permissions available, deny access
    return false;
  }

  /// Get all permissions for a specific role (fallback when server permissions are not available)
  static List<PermissionModel> getDefaultPermissionsForRole(UserRole role) {
    final rolePermissions = _defaultPermissions[role] ?? {};
    return rolePermissions.entries
        .map(
          (entry) => PermissionModel(resource: entry.key, actions: entry.value),
        )
        .toList();
  }

  /// Check if user can perform any CRUD operations on a resource
  static bool canManageResource(
    UserPermissionsModel? userPermissions,
    PermissionResource resource, {
    UserRole? fallbackRole,
  }) {
    return hasPermission(
          userPermissions,
          resource,
          PermissionAction.create,
          fallbackRole: fallbackRole,
        ) ||
        hasPermission(
          userPermissions,
          resource,
          PermissionAction.update,
          fallbackRole: fallbackRole,
        ) ||
        hasPermission(
          userPermissions,
          resource,
          PermissionAction.delete,
          fallbackRole: fallbackRole,
        );
  }

  /// Check if user can view a resource
  static bool canViewResource(
    UserPermissionsModel? userPermissions,
    PermissionResource resource, {
    UserRole? fallbackRole,
  }) {
    return hasPermission(
          userPermissions,
          resource,
          PermissionAction.read,
          fallbackRole: fallbackRole,
        ) ||
        hasPermission(
          userPermissions,
          resource,
          PermissionAction.list,
          fallbackRole: fallbackRole,
        );
  }

  /// Check if user can access document based on security level and role
  static bool canAccessDocument(
    UserPermissionsModel? userPermissions,
    DocumentSecurityLevel securityLevel, {
    UserRole? fallbackRole,
  }) {
    final userRole =
        userPermissions?.userRole ?? fallbackRole ?? UserRole.silver;

    // Use the centralized configuration for document security access
    return PermissionConfig.canAccessDocumentLevel(userRole, securityLevel);
  }

  /// Check if user can access document with both permission and security level checks
  static bool canAccessDocumentWithPermission(
    UserPermissionsModel? userPermissions,
    PermissionAction action,
    DocumentSecurityLevel securityLevel, {
    UserRole? fallbackRole,
  }) {
    // First check if user has the required permission for documents
    final hasPermission = PermissionService.hasPermission(
      userPermissions,
      PermissionResource.document,
      action,
      fallbackRole: fallbackRole,
    );

    // Then check if user can access this security level
    final canAccessLevel = canAccessDocument(
      userPermissions,
      securityLevel,
      fallbackRole: fallbackRole,
    );

    return hasPermission && canAccessLevel;
  }
}
