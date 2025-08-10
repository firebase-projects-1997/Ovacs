import 'package:flutter/material.dart';
import 'package:new_ovacs/core/mixins/optimistic_update_mixin.dart';
import 'package:new_ovacs/data/models/assigned_model.dart';
import 'package:new_ovacs/data/repositories/case_repository.dart';

enum AssignedAccountsStatus { idle, loading, success, error }

enum AssignedAccountAction { assign, updateRole, deassign }

class AssignedAccountsProvider extends ChangeNotifier
    with OptimisticUpdateMixin<AssignedAccountModel> {
  final CaseRepository _repository;

  AssignedAccountsProvider(this._repository);

  List<AssignedAccountModel> _assignedAccounts = [];
  AssignedAccountsStatus _status = AssignedAccountsStatus.idle;
  String? _errorMessage;
  int? _currentCaseId;

  // Action-specific loading states
  bool _isAssigning = false;
  bool _isUpdatingRole = false;
  bool _isDeassigning = false;
  int? _actionTargetAccountId;

  @override
  List<AssignedAccountModel> get items => _assignedAccounts;

  @override
  set items(List<AssignedAccountModel> value) {
    _assignedAccounts = value;
  }

  List<AssignedAccountModel> get assignedAccounts => _assignedAccounts;
  AssignedAccountsStatus get status => _status;

  @override
  String? get errorMessage => _errorMessage;

  int? get currentCaseId => _currentCaseId;

  @override
  bool get isLoading => _status == AssignedAccountsStatus.loading;

  @override
  set isLoading(bool value) {
    _status = value
        ? AssignedAccountsStatus.loading
        : AssignedAccountsStatus.idle;
  }

  @override
  set errorMessage(String? value) {
    _errorMessage = value;
  }

  // Action-specific loading getters
  bool get isAssigning => _isAssigning;
  bool get isUpdatingRole => _isUpdatingRole;
  bool get isDeassigning => _isDeassigning;
  int? get actionTargetAccountId => _actionTargetAccountId;

  /// Checks if a specific account is being acted upon
  bool isAccountLoading(int accountId, AssignedAccountAction action) {
    if (_actionTargetAccountId != accountId) return false;

    switch (action) {
      case AssignedAccountAction.assign:
        return _isAssigning;
      case AssignedAccountAction.updateRole:
        return _isUpdatingRole;
      case AssignedAccountAction.deassign:
        return _isDeassigning;
    }
  }

  /// Fetches assigned accounts for a specific case
  Future<void> fetchAssignedAccounts(int caseId) async {
    _currentCaseId = caseId;
    _status = AssignedAccountsStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.getAssignedAccounts(caseId);

      result.fold(
        (failure) {
          _status = AssignedAccountsStatus.error;
          _errorMessage = failure.message;
        },
        (accounts) {
          _status = AssignedAccountsStatus.success;
          _assignedAccounts = accounts;
          _errorMessage = null;
        },
      );
    } catch (e) {
      _status = AssignedAccountsStatus.error;
      _errorMessage = 'Failed to fetch assigned accounts: $e';
    }

    notifyListeners();
  }

  /// Assigns an account to the current case
  Future<bool> assignAccountToCase({
    required int accountId,
    required String role,
  }) async {
    if (_currentCaseId == null) {
      _errorMessage = 'No case selected';
      notifyListeners();
      return false;
    }

    _isAssigning = true;
    _actionTargetAccountId = accountId;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _repository.assignAccountToCase(
        caseId: _currentCaseId!,
        accountId: accountId,
        role: role,
      );

      return result.fold(
        (failure) {
          _errorMessage = failure.message;
          _isAssigning = false;
          _actionTargetAccountId = null;
          notifyListeners();
          return false;
        },
        (success) {
          _isAssigning = false;
          _actionTargetAccountId = null;
          _errorMessage = null;

          // Refresh the assigned accounts list
          fetchAssignedAccounts(_currentCaseId!);
          return true;
        },
      );
    } catch (e) {
      _errorMessage = 'Failed to assign account: $e';
      _isAssigning = false;
      _actionTargetAccountId = null;
      notifyListeners();
      return false;
    }
  }

  /// Updates the role of an assigned account
  Future<bool> updateAccountRole({
    required int accountId,
    required String newRole,
  }) async {
    if (_currentCaseId == null) {
      _errorMessage = 'No case selected';
      notifyListeners();
      return false;
    }

    _isUpdatingRole = true;
    _actionTargetAccountId = accountId;
    _errorMessage = null;
    notifyListeners();

    // Optimistic update
    final originalAccounts = List<AssignedAccountModel>.from(_assignedAccounts);
    final accountIndex = _assignedAccounts.indexWhere(
      (account) => account.account.id == accountId,
    );

    if (accountIndex != -1) {
      final updatedAccount = AssignedAccountModel(
        account: _assignedAccounts[accountIndex].account,
        role: newRole,
        assignedAt: _assignedAccounts[accountIndex].assignedAt,
      );
      _assignedAccounts[accountIndex] = updatedAccount;
      notifyListeners();
    }

    try {
      final result = await _repository.updateAccountRole(
        caseId: _currentCaseId!,
        accountId: accountId,
        role: newRole,
      );

      return result.fold(
        (failure) {
          // Rollback optimistic update
          _assignedAccounts = originalAccounts;
          _errorMessage = failure.message;
          _isUpdatingRole = false;
          _actionTargetAccountId = null;
          notifyListeners();
          return false;
        },
        (success) {
          _isUpdatingRole = false;
          _actionTargetAccountId = null;
          _errorMessage = null;
          notifyListeners();
          return true;
        },
      );
    } catch (e) {
      // Rollback optimistic update
      _assignedAccounts = originalAccounts;
      _errorMessage = 'Failed to update account role: $e';
      _isUpdatingRole = false;
      _actionTargetAccountId = null;
      notifyListeners();
      return false;
    }
  }

  /// Deassigns an account from the current case
  Future<bool> deassignAccount(int accountId) async {
    if (_currentCaseId == null) {
      _errorMessage = 'No case selected';
      notifyListeners();
      return false;
    }

    _isDeassigning = true;
    _actionTargetAccountId = accountId;
    _errorMessage = null;
    notifyListeners();

    // Optimistic update - remove the account
    final originalAccounts = List<AssignedAccountModel>.from(_assignedAccounts);
    _assignedAccounts.removeWhere((account) => account.account.id == accountId);
    notifyListeners();

    try {
      final result = await _repository.deassignAccount(
        caseId: _currentCaseId!,
        accountId: accountId,
      );

      return result.fold(
        (failure) {
          // Rollback optimistic update
          _assignedAccounts = originalAccounts;
          _errorMessage = failure.message;
          _isDeassigning = false;
          _actionTargetAccountId = null;
          notifyListeners();
          return false;
        },
        (success) {
          _isDeassigning = false;
          _actionTargetAccountId = null;
          _errorMessage = null;
          notifyListeners();
          return true;
        },
      );
    } catch (e) {
      // Rollback optimistic update
      _assignedAccounts = originalAccounts;
      _errorMessage = 'Failed to deassign account: $e';
      _isDeassigning = false;
      _actionTargetAccountId = null;
      notifyListeners();
      return false;
    }
  }

  /// Gets available roles for assignment
  List<String> get availableRoles => ['admin', 'diamond', 'gold', 'silver'];

  /// Checks if an account is already assigned
  bool isAccountAssigned(int accountId) {
    return _assignedAccounts.any((account) => account.account.id == accountId);
  }

  /// Gets the role of a specific assigned account
  String? getAccountRole(int accountId) {
    final account = _assignedAccounts.firstWhere(
      (account) => account.account.id == accountId,
      orElse: () => throw StateError('Account not found'),
    );
    return account.role;
  }

  /// Clears all data and resets the provider
  void reset() {
    _assignedAccounts.clear();
    _status = AssignedAccountsStatus.idle;
    _errorMessage = null;
    _currentCaseId = null;
    _isAssigning = false;
    _isUpdatingRole = false;
    _isDeassigning = false;
    _actionTargetAccountId = null;
    notifyListeners();
  }

  /// Refreshes the current case's assigned accounts
  Future<void> refresh() async {
    if (_currentCaseId != null) {
      await fetchAssignedAccounts(_currentCaseId!);
    }
  }
}
