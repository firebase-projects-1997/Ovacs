import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../common/providers/permission_provider.dart';
import '../../common/providers/workspace_provider.dart';
import '../enums/permission_action.dart';
import '../enums/permission_resource.dart';
import '../enums/user_role.dart';

/// Utility class for handling permission-based actions
class PermissionUtils {
  /// Execute an action only if user has permission
  static Future<T?> executeWithPermission<T>(
    BuildContext context, {
    required PermissionResource resource,
    required PermissionAction action,
    required Future<T> Function() operation,
    UserRole? fallbackRole,
    String? deniedTitle,
    String? deniedMessage,
    bool showDialog = true,
  }) async {
    final permissionProvider = context.read<PermissionProvider>();

    final hasPermission = permissionProvider.hasPermission(
      resource,
      action,
      fallbackRole: fallbackRole,
    );

    if (!hasPermission) {
      if (showDialog) {
        await _showPermissionDeniedDialog(
          context,
          title: deniedTitle,
          message: deniedMessage,
        );
      } else {
        _showPermissionDeniedSnackbar(context, message: deniedMessage);
      }
      return null;
    }

    return await operation();
  }

  /// Check permission and show appropriate error if denied
  static bool checkPermissionWithFeedback(
    BuildContext context, {
    required PermissionResource resource,
    required PermissionAction action,
    UserRole? fallbackRole,
    String? deniedTitle,
    String? deniedMessage,
    bool showDialog = true,
  }) {
    final permissionProvider = context.read<PermissionProvider>();

    final hasPermission = permissionProvider.hasPermission(
      resource,
      action,
      fallbackRole: fallbackRole,
    );

    if (!hasPermission) {
      if (showDialog) {
        _showPermissionDeniedDialog(
          context,
          title: deniedTitle,
          message: deniedMessage,
        );
      } else {
        _showPermissionDeniedSnackbar(context, message: deniedMessage);
      }
    }

    return hasPermission;
  }

  /// Get user-friendly permission error message
  static String getPermissionErrorMessage(
    PermissionResource resource,
    PermissionAction action,
  ) {
    final resourceName = resource.displayName.toLowerCase();

    switch (action) {
      case PermissionAction.create:
        return 'Access denied: Insufficient permissions to create $resourceName';
      case PermissionAction.read:
        return 'Access denied: Insufficient permissions to view $resourceName';
      case PermissionAction.update:
        return 'Access denied: Insufficient permissions to update $resourceName';
      case PermissionAction.delete:
        return 'Access denied: Insufficient permissions to delete $resourceName';
      case PermissionAction.list:
        return 'Access denied: Insufficient permissions to list $resourceName';
      case PermissionAction.assign:
        return 'Access denied: Insufficient permissions to assign $resourceName';
      case PermissionAction.unassign:
        return 'Access denied: Insufficient permissions to unassign $resourceName';
      case PermissionAction.manageRoles:
        return 'Access denied: Insufficient permissions to manage roles for $resourceName';
    }
  }

  /// Load permissions for current workspace context
  static Future<void> loadPermissionsForCurrentWorkspace(
    BuildContext context, {
    bool forceRefresh = false,
  }) async {
    final workspaceProvider = context.read<WorkspaceProvider>();
    final permissionProvider = context.read<PermissionProvider>();

    final spaceId = workspaceProvider.currentSpaceId;
    await permissionProvider.fetchPermissions(
      spaceId: spaceId,
      forceRefresh: forceRefresh,
    );
  }

  /// Load permissions for specific context
  static Future<void> loadPermissionsForContext(
    BuildContext context, {
    int? spaceId,
    int? caseId,
    bool forceRefresh = false,
  }) async {
    final permissionProvider = context.read<PermissionProvider>();

    await permissionProvider.fetchPermissions(
      spaceId: spaceId,
      caseId: caseId,
      forceRefresh: forceRefresh,
    );
  }

  /// Check if user can perform any management actions on a resource
  static bool canManageResource(
    BuildContext context,
    PermissionResource resource, {
    UserRole? fallbackRole,
  }) {
    final permissionProvider = context.read<PermissionProvider>();
    return permissionProvider.canManageResource(
      resource,
      fallbackRole: fallbackRole,
    );
  }

  /// Check if user can view a resource
  static bool canViewResource(
    BuildContext context,
    PermissionResource resource, {
    UserRole? fallbackRole,
  }) {
    final permissionProvider = context.read<PermissionProvider>();
    return permissionProvider.canViewResource(
      resource,
      fallbackRole: fallbackRole,
    );
  }

  /// Get current user role
  static UserRole getCurrentUserRole(BuildContext context) {
    final permissionProvider = context.read<PermissionProvider>();
    return permissionProvider.currentUserRole;
  }

  /// Check if user has at least the specified role level
  static bool hasRoleLevel(BuildContext context, UserRole minimumRole) {
    final currentRole = getCurrentUserRole(context);
    return currentRole.hasPermissionLevel(minimumRole);
  }

  static Future<void> _showPermissionDeniedDialog(
    BuildContext context, {
    String? title,
    String? message,
  }) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title ?? 'Permission Denied'),
        content: Text(
          message ?? 'You do not have permission to perform this action.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  static void _showPermissionDeniedSnackbar(
    BuildContext context, {
    String? message,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message ?? 'You do not have permission to perform this action.',
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }
}
