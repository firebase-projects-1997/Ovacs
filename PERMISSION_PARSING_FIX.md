# Permission Parsing Fix

## Issue Identified
The API was returning `space_id` as a string `"53"`, but the `UserPermissionsModel.fromJson` was trying to parse it directly as an `int?`, causing:
```
Error parsing permissions: type 'String' is not a subtype of type 'int?'
```

## Root Cause
In `lib/data/models/permission_model.dart`, the parsing was:
```dart
spaceId: json['space_id'],  // ❌ Direct assignment - fails if API returns string
caseId: json['case_id'],    // ❌ Direct assignment - fails if API returns string
```

## Fix Applied
Updated the parsing to handle both string and integer values:
```dart
spaceId: json['space_id'] != null ? int.tryParse(json['space_id'].toString()) : null,
caseId: json['case_id'] != null ? int.tryParse(json['case_id'].toString()) : null,
```

## Expected Result
Now when the API returns:
```json
{
  "user_id": 7,
  "user_email": "firebase.projects.1997@gmail.com",
  "space_id": "53",  // ✅ String will be parsed correctly
  "case_id": null,
  "user_role": "admin",
  "permissions": {
    "case": ["assign", "update", "read", "unassign", "manage_roles", "list"],
    "session": ["delete", "read", "list", "create", "update"],
    // ... other permissions
  }
}
```

The parsing should succeed and you should see:
- ✅ `fetchPermissions: Success - role=admin, spaceId=53`
- ✅ `executeWithPermissionInSpaceContext: hasPermission=true`
- ✅ Admin can edit cases in switched spaces
- ✅ Popup menus work correctly

## Testing
Try the popup menu again. You should now see:
1. No parsing errors
2. Permissions loaded successfully for space 53
3. Admin can edit cases (has `update` permission)
4. Admin cannot delete cases (no `delete` permission in the response)
