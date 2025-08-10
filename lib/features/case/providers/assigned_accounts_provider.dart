import '../../../core/providers/base_list_provider.dart';
import '../../../core/mixins/provider_permissions_mixin.dart';
import '../../../core/enums/permission_resource.dart';
import '../../../core/enums/permission_action.dart';
import '../../../core/error/failure.dart';
import '../../../data/models/assigned_model.dart';
import '../../../data/repositories/case_repository.dart';
import 'package:dartz/dartz.dart';

enum AssignedAccountAction { assign, updateRole, deassign }

class AssignedAccountsProvider extends BaseListProvider<AssignedAccountModel>
    with ProviderPermissionsMixin {
  final CaseRepository _repository;

  AssignedAccountsProvider(this._repository);

  int? _currentCaseId;

  // Action-specific loading states
  bool _isAssigning = false;
  bool _isUpdatingRole = false;
  bool _isDeassigning = false;
  int? _actionTargetAccountId;

  /// Convenience getter for assigned accounts
  List<AssignedAccountModel> get assignedAccounts => items;

  int? get currentCaseId => _currentCaseId;

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

  @override
  Future<Either<Failure, List<AssignedAccountModel>>> performFetch({
    required int page,
    Map<String, dynamic>? params,
  }) async {
    if (_currentCaseId == null) {
      return Left(BadRequestFailure('No case ID set'));
    }

    // Check read permission
    if (!hasPermissionWithOwnership(
      PermissionResource.case_,
      PermissionAction.read,
    )) {
      return Left(
        ForbiddenFailure(
          getPermissionDeniedMessage(
            PermissionResource.case_,
            PermissionAction.read,
          ),
        ),
      );
    }

    final result = await _repository.getAssignedAccounts(_currentCaseId!);

    return result.fold((failure) => Left(failure), (accounts) {
      // For assigned accounts, we typically don't have pagination
      setPaginationInfo(hasMore: false, totalCount: accounts.length);
      return Right(accounts);
    });
  }

  /// Fetches assigned accounts for a specific case
  Future<bool> fetchAssignedAccounts(int caseId) async {
    _currentCaseId = caseId;
    return await fetchData();
  }

  /// Assigns an account to the current case
  Future<bool> assignAccountToCase({
    required int accountId,
    required String role,
  }) async {
    if (_currentCaseId == null) {
      setError('No case selected');
      return false;
    }

    // Check assign permission (typically requires higher privileges)
    if (!hasPermissionWithOwnership(
      PermissionResource.case_,
      PermissionAction.update,
    )) {
      setError(
        getPermissionDeniedMessage(
          PermissionResource.case_,
          PermissionAction.update,
        ),
      );
      return false;
    }

    _isAssigning = true;
    _actionTargetAccountId = accountId;
    notifyListeners();

    try {
      final result = await _repository.assignAccountToCase(
        caseId: _currentCaseId!,
        accountId: accountId,
        role: role,
      );

      return result.fold(
        (failure) {
          setError(failure.message);
          return false;
        },
        (success) {
          if (success) {
            // Refresh the list to get the updated data
            fetchData();
            setSuccess('Account assigned successfully');
            return true;
          } else {
            setError('Failed to assign account');
            return false;
          }
        },
      );
    } finally {
      _isAssigning = false;
      _actionTargetAccountId = null;
      notifyListeners();
    }
  }

  /// Updates the role of an assigned account
  Future<bool> updateAccountRole({
    required int accountId,
    required String newRole,
  }) async {
    if (_currentCaseId == null) {
      setError('No case selected');
      return false;
    }

    // Check update permission
    if (!hasPermissionWithOwnership(
      PermissionResource.case_,
      PermissionAction.update,
    )) {
      setError(
        getPermissionDeniedMessage(
          PermissionResource.case_,
          PermissionAction.update,
        ),
      );
      return false;
    }

    _isUpdatingRole = true;
    _actionTargetAccountId = accountId;
    notifyListeners();

    try {
      final result = await _repository.updateAccountRole(
        caseId: _currentCaseId!,
        accountId: accountId,
        role: newRole,
      );

      return result.fold(
        (failure) {
          setError(failure.message);
          return false;
        },
        (success) {
          if (success) {
            // Refresh the list to get the updated data
            fetchData();
            setSuccess('Account role updated successfully');
            return true;
          } else {
            setError('Failed to update account role');
            return false;
          }
        },
      );
    } finally {
      _isUpdatingRole = false;
      _actionTargetAccountId = null;
      notifyListeners();
    }
  }

  /// Deassigns an account from the current case
  Future<bool> deassignAccount(int accountId) async {
    if (_currentCaseId == null) {
      setError('No case selected');
      return false;
    }

    // Check delete/update permission
    if (!hasPermissionWithOwnership(
      PermissionResource.case_,
      PermissionAction.update,
    )) {
      setError(
        getPermissionDeniedMessage(
          PermissionResource.case_,
          PermissionAction.update,
        ),
      );
      return false;
    }

    _isDeassigning = true;
    _actionTargetAccountId = accountId;
    notifyListeners();

    try {
      final result = await _repository.deassignAccount(
        caseId: _currentCaseId!,
        accountId: accountId,
      );

      return result.fold(
        (failure) {
          setError(failure.message);
          return false;
        },
        (_) {
          // Remove the account from the list
          final updatedItems = items
              .where((account) => account.account.id != accountId)
              .toList();
          items = updatedItems;
          setSuccess('Account deassigned successfully');
          return true;
        },
      );
    } finally {
      _isDeassigning = false;
      _actionTargetAccountId = null;
      notifyListeners();
    }
  }

  /// Checks if an account is already assigned
  bool isAccountAssigned(int accountId) {
    return items.any((account) => account.account.id == accountId);
  }

  /// Gets the role of an assigned account
  String? getAccountRole(int accountId) {
    try {
      final account = items.firstWhere(
        (account) => account.account.id == accountId,
      );
      return account.role;
    } catch (e) {
      return null;
    }
  }

  /// Clears all data and resets the provider
  void resetProvider() {
    clearItems();
    _currentCaseId = null;
    _isAssigning = false;
    _isUpdatingRole = false;
    _isDeassigning = false;
    _actionTargetAccountId = null;
  }

  /// Refreshes the current case's assigned accounts
  Future<bool> refreshAssignedAccounts() async {
    if (_currentCaseId != null) {
      return await refresh();
    }
    return false;
  }

  /// Available roles for assignment (capitalized for UI display)
  /// Note: These will be converted to lowercase when sent to backend
  /// Owner role is excluded as it's a system role that cannot be manually assigned
  List<String> get availableRoles => ['Admin', 'Diamond', 'Gold', 'Silver'];
}
