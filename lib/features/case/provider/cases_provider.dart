import 'package:flutter/material.dart';

import '../../../core/mixins/optimistic_update_mixin.dart';
import '../../../data/models/case_model.dart';
import '../../../data/repositories/case_repository.dart';
import '../../../common/providers/workspace_provider.dart';

class CasesProvider extends ChangeNotifier
    with OptimisticUpdateMixin<CaseModel> {
  final CaseRepository _repository;
  final WorkspaceProvider _workspaceProvider;

  CasesProvider(this._repository, this._workspaceProvider);

  List<CaseModel> _cases = [];

  @override
  List<CaseModel> get items => _cases;

  @override
  set items(List<CaseModel> value) {
    _cases = value;
  }

  List<CaseModel> get cases => _cases;

  bool _isLoading = false;

  @override
  bool get isLoading => _isLoading;

  @override
  set isLoading(bool value) {
    _isLoading = value;
  }

  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

  int _currentPage = 1;
  bool _hasMore = true;

  String? _errorMessage;

  @override
  String? get errorMessage => _errorMessage;

  @override
  set errorMessage(String? value) {
    _errorMessage = value;
  }

  Map<String, dynamic>? _filters;

  Future<void> fetchCases({Map<String, dynamic>? filters}) async {
    _isLoading = true;
    _errorMessage = null;
    _currentPage = 1;
    _hasMore = true;
    _filters = _workspaceProvider.mergeWithWorkspaceParams(filters);
    notifyListeners();

    final result = await _repository.getCases(
      page: _currentPage,
      filters: _filters,
    );

    result.fold(
      (failure) {
        // Provide user-friendly error messages
        if (failure.message.contains("Permission") ||
            failure.message.contains("unhashable") ||
            failure.message.contains("Server permission system error")) {
          _errorMessage =
              "There's a temporary issue with the permission system. Please try again later or contact support.";
        } else if (failure.message.contains("Server configuration error")) {
          _errorMessage =
              "Server is experiencing technical difficulties. Please try again later.";
        } else {
          _errorMessage = failure.message;
        }
        _cases = [];
      },
      (response) {
        _cases = response.cases;
        _hasMore = response.pagination.hasNext;
        _errorMessage = null; // Clear any previous errors
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchMoreCases() async {
    if (_isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    notifyListeners();

    _currentPage++;
    final result = await _repository.getCases(
      page: _currentPage,
      filters: _filters,
    );

    result.fold(
      (failure) {
        _errorMessage = failure.message;
      },
      (response) {
        _cases.addAll(response.cases);
        _hasMore = response.pagination.hasNext;
      },
    );

    _isLoadingMore = false;
    notifyListeners();
  }

  /// Optimistically adds a new case
  Future<bool> addCaseOptimistic({
    required int clientId,
    required String clientName,
    required String title,
    required String description,
    required String date,
  }) async {
    // Create a temporary case with a negative ID for optimistic update
    final tempCase = CaseModel(
      id: -DateTime.now().millisecondsSinceEpoch, // Temporary negative ID
      account: 0, // Temporary account ID
      clientId: clientId,
      clientName: clientName,
      title: title,
      description: description,
      date: DateTime.parse(date),
      createdAt: DateTime.now(),
      isActive: true,
    );

    final payload = {
      'client_id_input': clientId,
      'title': title,
      'description': description,
      'date': date,
    };

    return await optimisticAdd<CaseModel>(
      item: tempCase,
      operation: () => _repository.createCase(payload),
      getId: (caseModel) => caseModel.id,
      mapResult: (response) => response, // The response is already a CaseModel
    );
  }

  /// Optimistically updates a case
  Future<bool> updateCaseOptimistic({
    required int id,
    required String title,
    required String description,
    required String date,
  }) async {
    // Find the existing case to preserve other fields
    final existingCase = _cases.firstWhere((c) => c.id == id);

    final updatedCase = CaseModel(
      id: id,
      account: existingCase.account,
      clientId: existingCase.clientId,
      clientName: existingCase.clientName,
      title: title,
      description: description,
      date: DateTime.parse(date),
      createdAt: existingCase.createdAt,
      isActive: existingCase.isActive,
      assignedAccountNames: existingCase.assignedAccountNames,
    );

    final payload = {'title': title, 'description': description, 'date': date};
    final queryParams = _workspaceProvider.getWorkspaceQueryParams();

    return await optimisticUpdate<CaseModel>(
      updatedItem: updatedCase,
      operation: () =>
          _repository.updateCase(id, payload, queryParams: queryParams),
      getId: (caseModel) => caseModel.id,
      mapResult: (response) => response, // The response is already a CaseModel
    );
  }

  /// Optimistically deletes a case
  Future<bool> deleteCaseOptimistic(int caseId) async {
    final queryParams = _workspaceProvider.getWorkspaceQueryParams();

    return await optimisticDelete<bool>(
      itemId: caseId,
      operation: () => _repository.deleteCase(caseId, queryParams: queryParams),
      getId: (caseModel) => caseModel.id,
    );
  }
}
