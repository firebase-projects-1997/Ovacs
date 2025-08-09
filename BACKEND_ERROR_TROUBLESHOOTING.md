# Backend Error Troubleshooting Guide

## Current Issue: TypeError: unhashable type: 'Permission'

### Problem Description
The backend is throwing a `TypeError: unhashable type: 'Permission'` error when trying to fetch cases. This occurs in the permission system when attempting to add `Permission` objects to a Python set.

### Error Location
```
File "/home/ghaith/OVACS2/api/permission_config.py", line 85, in convert_config_to_permissions
    permissions.add(Permission(resource, action))
```

### Root Cause
The `Permission` class in the backend is not hashable, which means it cannot be added to a Python set. This is likely because the `Permission` class doesn't implement the `__hash__` and `__eq__` methods properly.

## 🔧 Backend Fix Required

### Option 1: Make Permission Class Hashable
Add the following methods to your `Permission` class in the backend:

```python
class Permission:
    def __init__(self, resource, action):
        self.resource = resource
        self.action = action
    
    def __hash__(self):
        return hash((self.resource, self.action))
    
    def __eq__(self, other):
        if not isinstance(other, Permission):
            return False
        return self.resource == other.resource and self.action == other.action
    
    def __repr__(self):
        return f"Permission({self.resource}, {self.action})"
```

### Option 2: Use Tuples Instead of Permission Objects
In `permission_config.py`, line 85, change:
```python
# Instead of:
permissions.add(Permission(resource, action))

# Use:
permissions.add((resource, action))
```

### Option 3: Use a List Instead of Set
If you don't need the uniqueness guarantee of a set, use a list:
```python
# Instead of:
permissions = set()
permissions.add(Permission(resource, action))

# Use:
permissions = []
permissions.append(Permission(resource, action))
```

## 🛡️ Flutter Error Handling (Already Implemented)

I've enhanced the Flutter app to handle this error gracefully:

### 1. Enhanced DioClient Error Handling
- Detects HTML error responses (Django debug pages)
- Provides user-friendly error messages for permission system errors
- Specific handling for TypeError and server configuration errors

### 2. Improved CasesProvider Error Messages
- Converts technical error messages to user-friendly ones
- Provides specific guidance for permission system issues
- Suggests contacting support for server errors

### 3. ServerErrorWidget
- Professional error display with helpful information
- Contact support functionality
- Retry mechanism
- Different styles for different error types

## 🚀 Immediate Workaround

While waiting for the backend fix, users will see:
- Clear error message: "There's a temporary issue with the permission system. Please try again later or contact support."
- Retry button to attempt the operation again
- Contact support option with guidance
- Professional error display instead of technical stack traces

## 📱 Flutter Implementation Details

### Error Detection
The Flutter app now detects permission system errors by checking for:
- "Permission" in error message
- "unhashable" in error message
- "TypeError" in error message
- "Server permission system error" in error message

### User Experience
- **Before**: Technical error message with stack trace
- **After**: User-friendly message with actionable options

### Error Widget Features
- 🔄 Retry functionality
- 📞 Contact support dialog
- ℹ️ Helpful information about the issue
- 🎨 Professional UI design

## 🔍 Testing the Fix

### Backend Testing
After implementing the backend fix:
1. Restart the Django server
2. Test the `/api/cases/` endpoint
3. Verify no more "unhashable type" errors
4. Test permission checking functionality

### Flutter Testing
The Flutter error handling can be tested by:
1. Temporarily breaking the backend permission system
2. Observing the user-friendly error messages
3. Testing the retry functionality
4. Verifying the contact support dialog

## 📋 Prevention

To prevent similar issues in the future:

### Backend Best Practices
1. Always implement `__hash__` and `__eq__` for classes used in sets
2. Use dataclasses with `frozen=True` for immutable objects
3. Add unit tests for permission system components
4. Use type hints to catch issues early

### Example with Dataclass
```python
from dataclasses import dataclass

@dataclass(frozen=True)
class Permission:
    resource: str
    action: str
```

## 🎯 Next Steps

1. **Immediate**: Apply one of the backend fixes above
2. **Short-term**: Add unit tests for the permission system
3. **Long-term**: Consider using Django's built-in permission system
4. **Monitoring**: Add logging to track permission system usage

## 📞 Support Information

If you need assistance with the backend fix:
- The error is in `/home/ghaith/OVACS2/api/permission_config.py` line 85
- The `Permission` class needs to be made hashable
- The Flutter app is already handling the error gracefully
- Users can continue using the app once the backend is fixed

The Flutter implementation provides a professional user experience even when backend errors occur, ensuring users aren't exposed to technical details while providing clear guidance on next steps.
