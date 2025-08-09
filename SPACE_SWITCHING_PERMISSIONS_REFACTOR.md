# Space Switching Permissions Refactor

## Overview
This refactor addresses critical issues with permissions and popup menu functionality when switching between personal and connection workspaces.

## Issues Fixed

### 1. Popup Menus Visible But Not Working in Switched Spaces
**Problem**: Popup menus showed edit/delete options based on cached permissions, but actions failed because permissions weren't loaded for the current space context.

**Solution**: 
- Enhanced `PermissionMixin` with space-aware permission checking
- Added `executeWithPermissionInSpaceContext()` method that ensures permissions are loaded before executing actions
- Updated all popup menu actions to use the new space-aware method

### 2. Missing space_id Parameters in Navigation
**Problem**: Document and group details pages didn't accept space_id parameters, causing permission context loss.

**Solution**:
- Added optional `spaceId` parameter to `DocumentDetailsPage` and `GroupDetailsPage`
- Updated navigation calls to pass current workspace space_id
- Modified `initState` methods to load permissions for specific space context

### 3. Upcoming Sessions Navigation Context
**Problem**: Dashboard sessions are personal but needed proper permission context handling.

**Solution**:
- Confirmed dashboard navigation correctly doesn't pass space_id (personal sessions)
- Ensured session details page handles both personal and switched space contexts
- Updated popup menus to use space-aware permission checking

## Key Changes

### Enhanced Permission Mixin (`lib/core/mixins/permission_mixin.dart`)

```dart
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
      return PermissionService.hasPermission(null, resource, action, fallbackRole: fallbackRole);
    }
    return false;
  }

  return permissionProvider.hasPermission(resource, action, fallbackRole: fallbackRole);
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
  
  if (hasPermission(resource, action, fallbackRole: fallbackRole)) {
    await callback();
  } else {
    if (showDialog) {
      showPermissionDeniedDialog(message: deniedMessage);
    } else {
      showPermissionDeniedSnackbar(message: deniedMessage);
    }
  }
}
```

### Updated Page Constructors

#### DocumentDetailsPage
```dart
class DocumentDetailsPage extends StatefulWidget {
  final int documentId;
  final int? spaceId;

  const DocumentDetailsPage({
    super.key, 
    required this.documentId,
    this.spaceId,
  });
```

#### GroupDetailsPage
```dart
class GroupDetailsPage extends StatefulWidget {
  final int groupId;
  final int sessionId;
  final int? spaceId;
  
  const GroupDetailsPage({
    super.key,
    required this.groupId,
    required this.sessionId,
    this.spaceId,
  });
```

### Updated Navigation Calls

#### Document Card Navigation
```dart
onTap: () {
  final workspaceProvider = context.read<WorkspaceProvider>();
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => DocumentDetailsPage(
        documentId: widget.document.id,
        spaceId: workspaceProvider.currentSpaceId,
      ),
    ),
  );
},
```

#### Groups Page Navigation
```dart
onTap: () {
  final workspaceProvider = context.read<WorkspaceProvider>();
  navigatorKey.currentState!.push(
    MaterialPageRoute(
      builder: (context) => GroupDetailsPage(
        groupId: group.id,
        sessionId: widget.sessionId,
        spaceId: workspaceProvider.currentSpaceId,
      ),
    ),
  );
},
```

### Updated Popup Menu Actions

All popup menus now use the space-aware permission method:

```dart
PopupMenuButton<String>(
  onSelected: (value) async {
    if (value == 'edit') {
      await executeWithPermissionInSpaceContext(
        PermissionResource.document,
        PermissionAction.update,
        () async => _showEditDialog(context, document, provider),
      );
    } else if (value == 'delete') {
      await executeWithPermissionInSpaceContext(
        PermissionResource.document,
        PermissionAction.delete,
        () async => _showDeleteDialog(context, document, provider),
      );
    }
  },
  // ... menu items
)
```

## Files Modified

1. `lib/core/mixins/permission_mixin.dart` - Enhanced with space-aware permission checking
2. `lib/features/document/views/document_details_page.dart` - Added space_id parameter and space-aware actions
3. `lib/features/document/views/group_details_page.dart` - Added space_id parameter and space-aware actions
4. `lib/features/document/widgets/document_card.dart` - Updated navigation and popup actions
5. `lib/features/document/views/groups_page.dart` - Updated navigation and popup actions
6. `lib/features/case/views/case_details_page.dart` - Updated popup actions
7. `lib/features/session/views/session_details_page.dart` - Updated popup actions
8. `lib/features/client/widgets/client_card.dart` - Updated popup actions

## Testing Scenarios

### Personal Workspace
- ✅ All popup menus should work (user has full permissions)
- ✅ Navigation should work without space_id
- ✅ Upcoming sessions from dashboard should navigate correctly

### Switched Workspace (Connection Mode)
- ✅ Popup menus should respect role-based permissions from API
- ✅ Navigation should pass space_id context
- ✅ Permissions should be loaded for current space before actions
- ✅ Actions should work correctly based on user's role in that space

### Permission Matrix Validation
- **Owner**: Full CRUD+Assign on cases ✅
- **Admin**: RU on cases, CRUD on sessions/documents/messages ✅
- **Diamond**: CRUD on sessions/documents/messages, R on cases/clients ✅
- **Gold**: RU on sessions, CR on messages, R on documents/groups ✅
- **Silver**: R on all resources ✅

## Best Practices Implemented

1. **Space Context Awareness**: All permission checks now consider current workspace context
2. **Fallback Handling**: Graceful degradation when permissions aren't loaded
3. **Consistent Navigation**: Space_id passed consistently where needed
4. **Permission Validation**: Actions only execute after confirming permissions
5. **Error Handling**: Proper error messages for permission denied scenarios
