import 'dart:convert';
import 'package:flutter/material.dart';
import '../../core/constants/storage_keys.dart';
import '../../data/models/space_account_model.dart';
import '../../services/storage_service.dart';

enum WorkspaceMode { personal, connection }

class WorkspaceProvider extends ChangeNotifier {
  final StorageService _storageService;

  WorkspaceProvider(this._storageService);

  WorkspaceMode _currentMode = WorkspaceMode.personal;
  SpaceAccountModel? _activeConnectionAccount;

  WorkspaceMode get currentMode => _currentMode;
  SpaceAccountModel? get activeConnectionAccount => _activeConnectionAccount;

  bool get isPersonalMode => _currentMode == WorkspaceMode.personal;
  bool get isConnectionMode => _currentMode == WorkspaceMode.connection;

  String? get activeAccountName => _activeConnectionAccount?.name;
  int? get activeAccountId => _activeConnectionAccount?.id;

  /// Initialize workspace state from storage
  Future<void> init() async {
    // Load workspace mode
    final modeString = _storageService.getString(StorageKeys.workspaceMode);
    if (modeString != null) {
      _currentMode = modeString == 'connection'
          ? WorkspaceMode.connection
          : WorkspaceMode.personal;
    }

    // Load active connection account if in connection mode
    if (_currentMode == WorkspaceMode.connection) {
      final accountJson = _storageService.getString(
        StorageKeys.activeConnectionAccount,
      );
      if (accountJson != null) {
        try {
          final accountData = jsonDecode(accountJson);
          _activeConnectionAccount = SpaceAccountModel.fromJson(accountData);
        } catch (e) {
          // If there's an error loading the account, reset to personal mode
          _currentMode = WorkspaceMode.personal;
          await _clearWorkspaceState();
        }
      } else {
        // If no account is stored but mode is connection, reset to personal
        _currentMode = WorkspaceMode.personal;
      }
    }

    notifyListeners();
  }

  /// Switch to connection workspace mode
  Future<void> switchToConnectionWorkspace(SpaceAccountModel account) async {
    _currentMode = WorkspaceMode.connection;
    _activeConnectionAccount = account;

    // Persist state
    await _storageService.setString(StorageKeys.workspaceMode, 'connection');
    await _storageService.setString(
      StorageKeys.activeConnectionAccount,
      jsonEncode(account.toJson()),
    );

    notifyListeners();
  }

  /// Switch back to personal workspace mode
  Future<void> switchToPersonalWorkspace() async {
    _currentMode = WorkspaceMode.personal;
    _activeConnectionAccount = null;

    await _clearWorkspaceState();
    notifyListeners();
  }

  /// Clear workspace state from storage
  Future<void> _clearWorkspaceState() async {
    await _storageService.setString(StorageKeys.workspaceMode, 'personal');
    await _storageService.remove(StorageKeys.activeConnectionAccount);
  }

  /// Get query parameters for API calls based on current workspace
  Map<String, dynamic> getWorkspaceQueryParams() {
    if (isConnectionMode && _activeConnectionAccount != null) {
      return {'space_id': _activeConnectionAccount!.id};
    }
    return {};
  }

  /// Get account_id parameter for cases API when in connection mode
  int? getAccountIdForCases() {
    return isConnectionMode ? _activeConnectionAccount?.id : null;
  }

  /// Reset workspace state (useful for logout)
  Future<void> reset() async {
    _currentMode = WorkspaceMode.personal;
    _activeConnectionAccount = null;
    await _clearWorkspaceState();
    notifyListeners();
  }
}
