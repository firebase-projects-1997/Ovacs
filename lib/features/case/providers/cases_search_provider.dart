import '../../../core/providers/base_list_provider.dart';
import '../../../core/mixins/provider_permissions_mixin.dart';
import '../../../core/enums/permission_resource.dart';
import '../../../core/enums/permission_action.dart';
import '../../../core/error/failure.dart';
import '../../../data/models/case_model.dart';
import '../../../data/repositories/case_repository.dart';
import '../../../common/providers/workspace_provider.dart';
import 'package:dartz/dartz.dart';

class CasesSearchProvider extends BaseListProvider<CaseModel>
    with ProviderPermissionsMixin {
  final CaseRepository _repository;
  final WorkspaceProvider _workspaceProvider;

  CasesSearchProvider(this._repository, this._workspaceProvider);

  // Search filters
  String? searchText;
  String? ordering;
  String? clientName;
  String? dateAfter;
  String? dateBefore;

  /// Convenience getter for cases
  List<CaseModel> get cases => items;

  @override
  Future<Either<Failure, List<CaseModel>>> performFetch({
    required int page,
    Map<String, dynamic>? params,
  }) async {
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

    // Build filters from current search parameters
    final filters = <String, dynamic>{
      if (searchText != null && searchText!.isNotEmpty) 'search': searchText,
      if (ordering != null && ordering!.isNotEmpty) 'ordering': ordering,
      if (clientName != null && clientName!.isNotEmpty)
        'client_name': clientName,
      if (dateAfter != null && dateAfter!.isNotEmpty) 'date_after': dateAfter,
      if (dateBefore != null && dateBefore!.isNotEmpty)
        'date_before': dateBefore,
      ...?params,
    };

    // Merge with workspace parameters
    final mergedFilters = _workspaceProvider.mergeWithWorkspaceParams(filters);

    final result = await _repository.getCases(
      page: page,
      filters: mergedFilters,
    );

    return result.fold((failure) => Left(failure), (response) {
      // Update pagination info
      setPaginationInfo(
        hasMore: response.pagination.hasNext,
        totalCount: response.pagination.count,
      );
      return Right(response.cases);
    });
  }

  void setSearchText(String? value) {
    searchText = value;
    fetchData();
  }

  void setOrdering(String? value) {
    ordering = value;
    fetchData();
  }

  void setClientName(String? value) {
    clientName = value;
    fetchData();
  }

  void setDateAfter(String? value) {
    dateAfter = value;
    fetchData();
  }

  void setDateBefore(String? value) {
    dateBefore = value;
    fetchData();
  }

  /// Clear all search filters and refresh data
  void clearFilters() {
    searchText = null;
    ordering = null;
    clientName = null;
    dateAfter = null;
    dateBefore = null;
    fetchData();
  }

  /// Search cases with current filters (convenience method)
  Future<bool> searchCases() async {
    return await fetchData();
  }
}
