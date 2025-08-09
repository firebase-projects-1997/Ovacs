import 'package:flutter/material.dart';
import '../../core/enums/permission_action.dart';
import '../../core/enums/permission_resource.dart';
import '../../core/enums/user_role.dart';
import '../../core/services/permission_service.dart';
import '../../data/models/permission_model.dart';
import '../../data/repositories/permission_repository.dart';

enum PermissionStatus { initial, loading, loaded, error }

class PermissionProvider extends ChangeNotifier {
  final PermissionRepository _permissionRepository;

  PermissionProvider(this._permissionRepository);

  PermissionStatus _status = PermissionStatus.initial;
  UserPermissionsModel? _userPermissions;
  String? _errorMessage;

  // Cache permissions for different contexts
  final Map<String, UserPermissionsModel> _permissionsCache = {};

  PermissionStatus get status => _status;
  UserPermissionsModel? get userPermissions => _userPermissions;
  String? get errorMessage => _errorMessage;

  /// Get current user role
  UserRole get currentUserRole => _userPermissions?.userRole ?? UserRole.silver;

  /// Fetch permissions for current context
  Future<void> fetchPermissions({
    int? spaceId,
    int? caseId,
    bool forceRefresh = false,
  }) async {
    final cacheKey = _getCacheKey(spaceId, caseId);

    // Return cached permissions if available and not forcing refresh
    if (!forceRefresh && _permissionsCache.containsKey(cacheKey)) {
      _userPermissions = _permissionsCache[cacheKey];
      _status = PermissionStatus.loaded;
      notifyListeners();
      return;
    }

    _status = PermissionStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _permissionRepository.checkPermissions(
      spaceId: spaceId,
      caseId: caseId,
    );

    result.fold(
      (failure) {
        _status = PermissionStatus.error;
        _errorMessage = failure.message;
        _userPermissions = null;
      },
      (permissions) {
        _status = PermissionStatus.loaded;
        _userPermissions = permissions;
        _permissionsCache[cacheKey] = permissions;
        _errorMessage = null;
      },
    );

    notifyListeners();
  }

  /// Check if user has specific permission
  bool hasPermission(
    PermissionResource resource,
    PermissionAction action, {
    UserRole? fallbackRole,
  }) {
    return PermissionService.hasPermission(
      _userPermissions,
      resource,
      action,
      fallbackRole: fallbackRole ?? currentUserRole,
    );
  }

  /// Check if user has specific permission for a specific context
  bool hasPermissionForContext(
    PermissionResource resource,
    PermissionAction action, {
    int? spaceId,
    int? caseId,
    UserRole? fallbackRole,
  }) {
    final contextPermissions = getCachedPermissions(
      spaceId: spaceId,
      caseId: caseId,
    );
    return PermissionService.hasPermission(
      contextPermissions,
      resource,
      action,
      fallbackRole: fallbackRole ?? currentUserRole,
    );
  }

  /// Check if user can manage (create/update/delete) a resource
  bool canManageResource(
    PermissionResource resource, {
    UserRole? fallbackRole,
  }) {
    return PermissionService.canManageResource(
      _userPermissions,
      resource,
      fallbackRole: fallbackRole ?? currentUserRole,
    );
  }

  /// Check if user can view a resource
  bool canViewResource(PermissionResource resource, {UserRole? fallbackRole}) {
    return PermissionService.canViewResource(
      _userPermissions,
      resource,
      fallbackRole: fallbackRole ?? currentUserRole,
    );
  }

  /// Get permissions for a specific resource
  PermissionModel? getPermissionForResource(PermissionResource resource) {
    return _userPermissions?.getPermissionForResource(resource);
  }

  /// Clear permissions cache
  void clearCache() {
    _permissionsCache.clear();
    _userPermissions = null;
    _status = PermissionStatus.initial;
    notifyListeners();
  }

  /// Clear permissions for specific context
  void clearCacheForContext({int? spaceId, int? caseId}) {
    final cacheKey = _getCacheKey(spaceId, caseId);
    _permissionsCache.remove(cacheKey);

    // If this was the current context, reset current permissions
    if (_userPermissions?.spaceId == spaceId &&
        _userPermissions?.caseId == caseId) {
      _userPermissions = null;
      _status = PermissionStatus.initial;
      notifyListeners();
    }
  }

  /// Generate cache key for permissions context
  String _getCacheKey(int? spaceId, int? caseId) {
    return 'space_${spaceId ?? 'null'}_case_${caseId ?? 'null'}';
  }

  /// Check if permissions are loaded for current context
  bool isPermissionsLoadedForContext({int? spaceId, int? caseId}) {
    final cacheKey = _getCacheKey(spaceId, caseId);
    return _permissionsCache.containsKey(cacheKey);
  }

  /// Get cached permissions for specific context
  UserPermissionsModel? getCachedPermissions({int? spaceId, int? caseId}) {
    final cacheKey = _getCacheKey(spaceId, caseId);
    return _permissionsCache[cacheKey];
  }
}
