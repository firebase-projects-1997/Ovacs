# Space Switching & Role-Based Permissions Implementation

## Overview
This document outlines the complete implementation of space switching and role-based access control (RBAC) system for the OVACS Flutter application, fully integrated with the backend RBAC system.

## 🔄 Backend Integration
The Flutter implementation is now fully aligned with the backend RBAC system:
- Uses `space_id` parameter consistently across all endpoints
- Integrates with `/api/check-permissions/` endpoint
- Handles backend error response structure
- Supports the backend's permission matrix

## 🎯 Features Implemented

### 1. Permission Management System
- **User Roles**: Owner, Admin, Diamond, Gold, Silver
- **Resources**: Cases, Clients, Sessions, Documents, Document Groups, Messages
- **Actions**: Create, Read, Update, Delete, List, Assign, Unassign, Manage Roles
- **Permission Models**: `UserRole`, `PermissionResource`, `PermissionAction`, `PermissionModel`, `UserPermissionsModel`

### 2. Space Switching Infrastructure
- **Enhanced WorkspaceProvider**: Automatic space_id parameter injection
- **Updated Repositories**: All repositories now support space_id query parameters
- **Permission Integration**: Permissions loaded based on workspace context

### 3. UI Permission Guards
- **PermissionGuard**: Conditionally show/hide widgets based on permissions
- **PermissionAwareButton**: Buttons that are enabled/disabled based on permissions
- **PermissionAwareAppBar**: App bars with permission-filtered actions
- **RoleBasedWidget**: Different content based on user role

### 4. Provider Updates
- **CasesProvider**: Integrated with WorkspaceProvider for automatic space switching
- **CaseDetailProvider**: Supports space_id parameters
- **AddCaseProvider**: Creates cases in correct workspace context
- **PermissionProvider**: Manages permission state and caching

## 🔧 Key Components

### Permission Enums
```dart
// User roles with hierarchy
enum UserRole { owner, admin, diamond, gold, silver }

// Resources that can be accessed
enum PermissionResource { case_, client, session, document, documentGroup, message }

// Actions that can be performed
enum PermissionAction { create, read, update, delete, list, assign, unassign, manageRoles }

// Document security levels
enum DocumentSecurityLevel { red, yellow, green }
```

### Permission Configuration
```dart
// Centralized permission matrix in PermissionConfig
static const Map<UserRole, Map<PermissionResource, List<PermissionAction>>> rolePermissions = {
  UserRole.owner: {
    PermissionResource.case_: [PermissionAction.create, PermissionAction.read, ...],
    // ... other resources
  },
  // ... other roles
};

// Document security access matrix
static const Map<DocumentSecurityLevel, List<UserRole>> documentSecurityAccess = {
  DocumentSecurityLevel.red: [UserRole.owner, UserRole.admin],
  DocumentSecurityLevel.yellow: [UserRole.owner, UserRole.admin, UserRole.diamond],
  DocumentSecurityLevel.green: [UserRole.owner, UserRole.admin, UserRole.diamond, UserRole.gold, UserRole.silver],
};
```

### Permission Service
```dart
// Check permissions with fallback to default role permissions
bool hasPermission = PermissionService.hasPermission(
  userPermissions,
  PermissionResource.case_,
  PermissionAction.create,
  fallbackRole: UserRole.silver,
);
```

### Workspace Integration
```dart
// Automatic space_id injection in providers
final queryParams = _workspaceProvider.getWorkspaceQueryParams();
final result = await _repository.getCaseDetail(id, queryParams: queryParams);

// Backend API calls with space_id
GET /api/cases/?space_id=123          // List cases
GET /api/cases/456/?space_id=123      // Get case detail
PUT /api/cases/456/?space_id=123      // Update case
DELETE /api/cases/456/?space_id=123   // Delete case
```

### Permission Checking
```dart
// Check permissions using backend endpoint
final permissionProvider = context.read<PermissionProvider>();
await permissionProvider.fetchPermissions(spaceId: currentSpaceId);

// Backend response structure:
{
  "type": "success",
  "data": {
    "user_role": "gold",
    "permissions": {
      "case": ["read", "list"],
      "session": ["read", "update", "list"],
      "document": ["read", "list"],
      "client": ["read", "list"]
    }
  }
}
```

## 🎨 UI Components Usage

### Permission Guards
```dart
// Basic permission guard
PermissionGuard(
  resource: PermissionResource.case_,
  action: PermissionAction.create,
  child: FloatingActionButton(
    onPressed: () => _createCase(),
    child: Icon(Icons.add),
  ),
)

// Document security-aware guard
DocumentSecurityGuard(
  action: PermissionAction.read,
  securityLevel: DocumentSecurityLevel.red,
  child: DocumentViewer(document: redDocument),
  fallback: Text('Access denied - insufficient security clearance'),
)
```

### Permission-Aware Buttons
```dart
PermissionAwareButton(
  resource: PermissionResource.case_,
  action: PermissionAction.update,
  onPressed: () => _editCase(),
  child: Text('Edit Case'),
  disabledTooltip: 'You cannot edit cases',
)
```

### Permission Mixin
```dart
class _MyPageState extends State<MyPage> with PermissionMixin {
  void _handleAction() {
    executeWithPermission(
      PermissionResource.case_,
      PermissionAction.delete,
      () => _deleteCase(),
      deniedMessage: 'You cannot delete cases',
    );
  }
}
```

## 🔄 Space Switching Flow

1. **User switches workspace** → `WorkspaceProvider.switchToConnectionWorkspace()`
2. **Permissions loaded** → `PermissionProvider.fetchPermissions(spaceId: spaceId)`
3. **API calls include space_id** → Automatic injection via `WorkspaceProvider.getWorkspaceQueryParams()`
4. **UI updates** → Permission guards show/hide elements based on new permissions

## 🛡️ Security Features

### Multi-Layer Access Control
1. **Connection Verification**: Must be following the target account
2. **Case Assignment**: Must be assigned to specific cases in the target account
3. **Role-Based Permissions**: Actions filtered based on assigned role
4. **Document Security Levels**: Red/yellow/green classification enforced

### Permission Caching
- Permissions cached per workspace context
- Automatic cache invalidation on workspace switch
- Force refresh capability for real-time updates

## 📱 Updated Pages

### Case Details Page
- Permission-aware app bar actions (edit/delete)
- Automatic permission loading on init
- Space switching support

### Cases List Page
- Permission-guarded create button
- Automatic workspace parameter handling
- Permission-aware search and filters

## 🔧 API Integration

### Backend Endpoints
- `GET /api/check-permissions/?space_id=123&case_id=456`
- All CRUD endpoints support `space_id` parameter
- Consistent error handling for permission denied

### Query Parameter Injection
```dart
// Automatic in all providers
final queryParams = _workspaceProvider.getWorkspaceQueryParams();
// Results in: {'space_id': 123} when in connection mode
```

## 🧪 Testing Scenarios

### 1. Permission Verification
- [ ] Owner can perform all actions
- [ ] Admin cannot create/delete cases but can manage sessions/documents
- [ ] Diamond has read-only cases, full session/document access
- [ ] Gold has read-only cases/documents, can update sessions
- [ ] Silver has read-only access to everything

### 2. Space Switching
- [ ] Switch between personal and connection workspaces
- [ ] Permissions update correctly on workspace change
- [ ] API calls include correct space_id parameter
- [ ] UI elements show/hide based on new permissions

### 3. Error Handling
- [ ] Permission denied messages are user-friendly
- [ ] Invalid space_id handled gracefully
- [ ] Network errors don't break permission system

### 4. UI Consistency
- [ ] Items visible in lists are accessible in detail views
- [ ] Action buttons are enabled/disabled consistently
- [ ] Permission tooltips provide helpful information

## 🚀 Usage Examples

### Loading Permissions
```dart
// In initState or when workspace changes
await loadPermissions();
```

### Checking Permissions
```dart
if (hasPermission(PermissionResource.case_, PermissionAction.create)) {
  // Show create button
}
```

### Permission-Aware Navigation
```dart
PermissionAwareListTile(
  resource: PermissionResource.case_,
  action: PermissionAction.read,
  title: Text('Case Details'),
  onTap: () => Navigator.push(...),
)
```

### Role Badge Display
```dart
// Display user role with appropriate styling
RoleBadge(role: UserRole.gold, showIcon: true)

// Compact version for lists
RoleBadge(role: UserRole.diamond, compact: true)

// Role hierarchy indicator
RoleHierarchyIndicator(
  currentRole: UserRole.gold,
  requiredRole: UserRole.diamond,
)
```

### Backend Error Handling
```dart
// The app now handles backend RBAC errors:
{
  "type": "error",
  "code": 403,
  "message": "Insufficient permissions to update case"
}

{
  "type": "error",
  "code": 403,
  "message": "User not connected to this space"
}

{
  "type": "error",
  "code": 403,
  "message": "User not assigned to this case"
}
```

## 📋 Configuration

### Role Permissions Configuration
Permissions are centrally managed in `lib/core/config/permission_config.dart`:

```dart
// Easy to modify permission matrix
static const Map<UserRole, Map<PermissionResource, List<PermissionAction>>> rolePermissions = {
  UserRole.gold: {
    PermissionResource.document: [PermissionAction.create, PermissionAction.read, PermissionAction.update], // Enhanced Gold permissions
    PermissionResource.session: [PermissionAction.read, PermissionAction.update, PermissionAction.delete], // Added delete permission
  }
};
```

### Document Security Configuration
```dart
// Document security level access matrix
static const Map<DocumentSecurityLevel, List<UserRole>> documentSecurityAccess = {
  DocumentSecurityLevel.red: [UserRole.owner, UserRole.admin], // Only top-level access
  DocumentSecurityLevel.yellow: [UserRole.owner, UserRole.admin, UserRole.diamond],
  DocumentSecurityLevel.green: [UserRole.owner, UserRole.admin, UserRole.diamond, UserRole.gold, UserRole.silver],
};
```

### Permission Caching
- Cache key format: `space_{spaceId}_case_{caseId}`
- Automatic cleanup on workspace switch
- Manual refresh available via `forceRefresh: true`

### Debug Tools
```dart
// Debug permission matrix
PermissionDebug.printAllRolePermissions();

// Test document security access
PermissionDebug.testDocumentSecurityAccess();

// Validate permission consistency
PermissionDebug.validatePermissionConsistency();
```

## 🔄 Migration Notes

### Existing Code Updates
1. Add `WorkspaceProvider` dependency to providers that need space switching
2. Update repository method calls to include `queryParams`
3. Replace manual permission checks with `PermissionGuard` widgets
4. Add permission loading in page `initState` methods

### Backward Compatibility
- `account_id` parameter still supported for cases API
- Existing UI continues to work without permission guards
- Gradual migration possible - permission system is additive

## 🎯 Next Steps

1. **Complete Provider Updates**: Update remaining providers (Sessions, Documents, Clients)
2. **UI Polish**: Add permission guards to all action buttons and menu items
3. **Error Handling**: Implement comprehensive error handling for permission failures
4. **Testing**: Thorough testing of all permission combinations
5. **Documentation**: Update API documentation with permission requirements

This implementation provides a robust, scalable, and user-friendly permission system that seamlessly integrates with the existing OVACS application architecture.
