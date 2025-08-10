import '../../../core/providers/base_list_provider.dart';
import '../../../core/error/failure.dart';
import '../../../data/models/case_model.dart';
import '../../../data/repositories/case_repository.dart';
import '../../../common/providers/workspace_provider.dart';
import 'package:dartz/dartz.dart';

class CasesProvider extends BaseListProvider<CaseModel> {
  final CaseRepository _repository;
  final WorkspaceProvider _workspaceProvider;

  CasesProvider(this._repository, this._workspaceProvider);

  /// Convenience getter for cases
  List<CaseModel> get cases => items;

  @override
  Future<Either<Failure, List<CaseModel>>> performFetch({
    required int page,
    Map<String, dynamic>? params,
  }) async {
    // Merge workspace parameters with provided params
    final filters = _workspaceProvider.mergeWithWorkspaceParams(params);

    final result = await _repository.getCases(page: page, filters: filters);

    return result.fold(
      (failure) {
        // Provide user-friendly error messages
        String errorMessage;
        if (failure.message.contains("Permission") ||
            failure.message.contains("unhashable") ||
            failure.message.contains("Server permission system error")) {
          errorMessage =
              "There's a temporary issue with the permission system. Please try again later or contact support.";
        } else if (failure.message.contains("Server configuration error")) {
          errorMessage =
              "Server is experiencing technical difficulties. Please try again later.";
        } else {
          errorMessage = failure.message;
        }
        return Left(ServerFailure(errorMessage));
      },
      (response) {
        // Update pagination info
        setPaginationInfo(
          hasMore: response.pagination.hasNext,
          totalCount: response.pagination.count,
        );
        return Right(response.cases);
      },
    );
  }

  /// Fetch cases with filters (convenience method)
  Future<bool> fetchCases({Map<String, dynamic>? filters}) async {
    return await fetchData(params: filters);
  }

  /// Load more cases (convenience method)
  Future<bool> fetchMoreCases({Map<String, dynamic>? filters}) async {
    return await loadMore(params: filters);
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

    // Get workspace query parameters
    final queryParams = _workspaceProvider.getWorkspaceQueryParams();

    return await addItem(
      item: tempCase,
      operation: () =>
          _repository.createCase(payload, queryParams: queryParams),
      getId: (caseModel) => caseModel.id,
      successMessage: 'Case created successfully',
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
    final existingCase = items.firstWhere((c) => c.id == id);

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

    return await updateItem(
      updatedItem: updatedCase,
      operation: () =>
          _repository.updateCase(id, payload, queryParams: queryParams),
      getId: (caseModel) => caseModel.id,
      successMessage: 'Case updated successfully',
    );
  }

  /// Optimistically deletes a case
  Future<bool> deleteCaseOptimistic(int caseId) async {
    final queryParams = _workspaceProvider.getWorkspaceQueryParams();

    return await deleteItem(
      itemId: caseId,
      operation: () => _repository.deleteCase(caseId, queryParams: queryParams),
      getId: (caseModel) => caseModel.id,
      successMessage: 'Case deleted successfully',
    );
  }
}
