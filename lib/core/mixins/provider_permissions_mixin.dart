import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../common/providers/permission_provider.dart';
import '../../common/providers/workspace_provider.dart';
import '../enums/permission_action.dart';
import '../enums/permission_resource.dart';
import '../enums/user_role.dart';
import '../services/permission_service.dart';

/// Mixin that provides permission checking functionality to providers
/// This ensures consistent permission handling across all providers
mixin ProviderPermissionsMixin on ChangeNotifier {
  PermissionProvider? _permissionProvider;
  WorkspaceProvider? _workspaceProvider;

  /// Initialize the permission providers
  void initializePermissions(BuildContext context) {
    _permissionProvider = context.read<PermissionProvider>();
    _workspaceProvider = context.read<WorkspaceProvider>();
  }

  /// Check if user has specific permission
  bool hasPermission(
    PermissionResource resource,
    PermissionAction action, {
    UserRole? fallbackRole,
  }) {
    if (_permissionProvider == null || _workspaceProvider == null) {
      // Fallback to service-level permission checking
      return PermissionService.hasPermission(
        null,
        resource,
        action,
        fallbackRole: fallbackRole,
      );
    }

    // Ensure permissions are loaded for current space context
    final spaceId = _workspaceProvider!.currentSpaceId;
    if (!_permissionProvider!.isPermissionsLoadedForContext(spaceId: spaceId)) {
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
    return _permissionProvider!.hasPermissionForContext(
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
    if (_workspaceProvider == null) {
      return hasPermission(resource, action, fallbackRole: fallbackRole);
    }

    // If in personal workspace, user owns the content and has full control
    if (_workspaceProvider!.isPersonalMode) {
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
    return hasPermission(resource, PermissionAction.create, fallbackRole: fallbackRole) ||
           hasPermission(resource, PermissionAction.update, fallbackRole: fallbackRole) ||
           hasPermission(resource, PermissionAction.delete, fallbackRole: fallbackRole);
  }

  /// Check if user can view a resource
  bool canViewResource(PermissionResource resource, {UserRole? fallbackRole}) {
    return hasPermission(resource, PermissionAction.read, fallbackRole: fallbackRole);
  }

  /// Get current user role
  UserRole get currentUserRole {
    if (_permissionProvider == null) {
      return UserRole.silver; // Default fallback role
    }
    return _permissionProvider!.currentUserRole;
  }

  /// Check if user is in a specific role
  bool hasRole(UserRole role) => currentUserRole == role;

  /// Check if user has at least the specified role level
  bool hasRoleLevel(UserRole minimumRole) {
    return currentUserRole.hasPermissionLevel(minimumRole);
  }

  /// Load permissions for current workspace context
  Future<void> loadPermissions({bool forceRefresh = false}) async {
    if (_permissionProvider == null || _workspaceProvider == null) return;
    
    final spaceId = _workspaceProvider!.currentSpaceId;
    await _permissionProvider!.fetchPermissions(
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
    if (_permissionProvider == null) return;
    
    await _permissionProvider!.fetchPermissions(
      spaceId: spaceId,
      caseId: caseId,
      forceRefresh: forceRefresh,
    );
  }

  /// Check if permissions are loaded for current context
  bool get arePermissionsLoaded {
    if (_permissionProvider == null || _workspaceProvider == null) return false;
    
    final spaceId = _workspaceProvider!.currentSpaceId;
    return _permissionProvider!.isPermissionsLoadedForContext(spaceId: spaceId);
  }

  /// Get workspace display name
  String get workspaceDisplayName {
    if (_workspaceProvider == null) return 'Personal';
    return _workspaceProvider!.workspaceDisplayName;
  }

  /// Check if in personal workspace
  bool get isPersonalWorkspace {
    if (_workspaceProvider == null) return true;
    return _workspaceProvider!.isPersonalMode;
  }

  /// Check if in connection workspace
  bool get isConnectionWorkspace {
    if (_workspaceProvider == null) return false;
    return _workspaceProvider!.isConnectionMode;
  }

  /// Execute operation only if user has permission
  Future<T?> executeWithPermission<T>({
    required PermissionResource resource,
    required PermissionAction action,
    required Future<T> Function() operation,
    UserRole? fallbackRole,
    String? deniedMessage,
  }) async {
    if (hasPermission(resource, action, fallbackRole: fallbackRole)) {
      return await operation();
    } else {
      // Log permission denied for debugging
      debugPrint(
        'Permission denied: ${action.name} on ${resource.name} '
        'for role ${currentUserRole.name}',
      );
      return null;
    }
  }

  /// Execute operation with permission check, ensuring permissions are loaded
  Future<T?> executeWithPermissionInContext<T>({
    required PermissionResource resource,
    required PermissionAction action,
    required Future<T> Function() operation,
    UserRole? fallbackRole,
    String? deniedMessage,
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
      return await operation();
    } else {
      // Log permission denied for debugging
      debugPrint(
        'Permission denied in context: ${action.name} on ${resource.name} '
        'for role ${currentUserRole.name} in workspace $workspaceDisplayName',
      );
      return null;
    }
  }

  /// Get permission-aware error message
  String getPermissionDeniedMessage(
    PermissionResource resource,
    PermissionAction action,
  ) {
    final resourceName = resource.toString().split('.').last;
    final actionName = action.toString().split('.').last;
    return "You don't have permission to $actionName ${resourceName.replaceAll('_', '')} in this workspace.";
  }
}
