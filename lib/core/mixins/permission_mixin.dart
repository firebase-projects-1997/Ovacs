import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../common/providers/permission_provider.dart';
import '../../common/providers/workspace_provider.dart';
import '../enums/permission_action.dart';
import '../enums/permission_resource.dart';
import '../enums/user_role.dart';
import '../services/permission_service.dart';

/// Mixin that provides permission checking functionality to widgets
mixin PermissionMixin<T extends StatefulWidget> on State<T> {
  /// Get the permission provider
  PermissionProvider get permissionProvider =>
      context.read<PermissionProvider>();

  /// Get the workspace provider
  WorkspaceProvider get workspaceProvider => context.read<WorkspaceProvider>();

  /// Check if user has specific permission
  /// This method ensures permissions are loaded for current space context
  bool hasPermission(
    PermissionResource resource,
    PermissionAction action, {
    UserRole? fallbackRole,
  }) {
    // Ensure permissions are loaded for current space context
    final spaceId = workspaceProvider.currentSpaceId;
    if (!permissionProvider.isPermissionsLoadedForContext(spaceId: spaceId)) {
      // If permissions not loaded for current context, use fallback
      if (fallbackRole != null) {
        return PermissionService.hasPermission(
          null,
          resource,
          action,
          fallbackRole: fallbackRole,
        );
      }
      return false;
    }

    // Use context-aware permission checking
    return permissionProvider.hasPermissionForContext(
      resource,
      action,
      spaceId: spaceId,
      fallbackRole: fallbackRole,
    );
  }

  /// Check if user has permission considering ownership context
  /// When in personal mode (viewing own content), user has full control
  /// When in connection mode (viewing others' content), use role-based permissions
  bool hasPermissionWithOwnership(
    PermissionResource resource,
    PermissionAction action, {
    UserRole? fallbackRole,
  }) {
    // If in personal workspace, user owns the content and has full control
    if (workspaceProvider.isPersonalMode) {
      return true;
    }

    // If in connection workspace, use role-based permissions from API
    return hasPermission(resource, action, fallbackRole: fallbackRole);
  }

  /// Check if user can manage (create/update/delete) a resource
  bool canManageResource(
    PermissionResource resource, {
    UserRole? fallbackRole,
  }) {
    return permissionProvider.canManageResource(
      resource,
      fallbackRole: fallbackRole,
    );
  }

  /// Check if user can view a resource
  bool canViewResource(PermissionResource resource, {UserRole? fallbackRole}) {
    return permissionProvider.canViewResource(
      resource,
      fallbackRole: fallbackRole,
    );
  }

  /// Get current user role
  UserRole get currentUserRole => permissionProvider.currentUserRole;

  /// Check if user is in a specific role
  bool hasRole(UserRole role) => currentUserRole == role;

  /// Check if user has at least the specified role level
  bool hasRoleLevel(UserRole minimumRole) {
    return currentUserRole.hasPermissionLevel(minimumRole);
  }

  /// Show permission denied dialog
  void showPermissionDeniedDialog({String? title, String? message}) {
    showDialog(
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

  /// Show permission denied snackbar
  void showPermissionDeniedSnackbar({String? message}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message ?? 'You do not have permission to perform this action.',
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  /// Execute action only if user has permission, otherwise show error
  void executeWithPermission(
    PermissionResource resource,
    PermissionAction action,
    VoidCallback callback, {
    UserRole? fallbackRole,
    String? deniedMessage,
    bool showDialog = false,
  }) {
    if (hasPermission(resource, action, fallbackRole: fallbackRole)) {
      callback();
    } else {
      if (showDialog) {
        showPermissionDeniedDialog(message: deniedMessage);
      } else {
        showPermissionDeniedSnackbar(message: deniedMessage);
      }
    }
  }

  /// Execute action with permission check, ensuring permissions are loaded for current space context
  /// This is especially useful for popup menu actions in switched spaces
  Future<void> executeWithPermissionInSpaceContext(
    PermissionResource resource,
    PermissionAction action,
    Future<void> Function() callback, {
    UserRole? fallbackRole,
    String? deniedMessage,
    bool showDialog = false,
    bool forceRefresh = false,
  }) async {
    // Ensure permissions are loaded for current space context
    await loadPermissions(forceRefresh: forceRefresh);

    final hasPermissionResult = hasPermission(
      resource,
      action,
      fallbackRole: fallbackRole,
    );

    if (hasPermissionResult) {
      await callback();
    } else {
      // Show user-friendly permission denied message
      final resourceName = resource.toString().split('.').last;
      final actionName = action.toString().split('.').last;
      final message =
          deniedMessage ??
          "You don't have permission to $actionName ${resourceName.replaceAll('_', '')} in this workspace.";

      showPermissionDeniedSnackbar(message: message);
    }
  }

  /// Load permissions for current workspace context
  Future<void> loadPermissions({bool forceRefresh = false}) async {
    final spaceId = workspaceProvider.currentSpaceId;
    await permissionProvider.fetchPermissions(
      spaceId: spaceId,
      forceRefresh: forceRefresh,
    );
  }

  /// Load permissions for specific context
  Future<void> loadPermissionsForContext({
    int? spaceId,
    int? caseId,
    bool forceRefresh = false,
  }) async {
    await permissionProvider.fetchPermissions(
      spaceId: spaceId,
      caseId: caseId,
      forceRefresh: forceRefresh,
    );
  }

  /// Check if permissions are loaded for current context
  bool get arePermissionsLoaded {
    final spaceId = workspaceProvider.currentSpaceId;
    return permissionProvider.isPermissionsLoadedForContext(spaceId: spaceId);
  }

  /// Get workspace display name
  String get workspaceDisplayName => workspaceProvider.workspaceDisplayName;

  /// Check if in personal workspace
  bool get isPersonalWorkspace => workspaceProvider.isPersonalMode;

  /// Check if in connection workspace
  bool get isConnectionWorkspace => workspaceProvider.isConnectionMode;
}
