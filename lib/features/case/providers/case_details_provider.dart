import '../../../core/providers/base_form_provider.dart';
import '../../../core/mixins/provider_permissions_mixin.dart';
import '../../../core/enums/permission_resource.dart';
import '../../../core/enums/permission_action.dart';
import '../../../data/models/case_model.dart';
import '../../../data/repositories/case_repository.dart';
import '../../../common/providers/workspace_provider.dart';

class CaseDetailProvider extends BaseFormProvider<CaseModel>
    with ProviderPermissionsMixin {
  final CaseRepository caseRepository;
  final WorkspaceProvider _workspaceProvider;

  CaseDetailProvider(this.caseRepository, this._workspaceProvider);

  /// Convenience getter for case model
  CaseModel? get caseModel => data;

  @override
  void performValidation() {
    // Add validation logic if needed for case updates
  }

  /// Fetch case details by ID
  Future<bool> fetchCaseDetail(int id) async {
    // Clear any existing error state before starting
    reset();

    // Check read permission
    if (!hasPermissionWithOwnership(
      PermissionResource.case_,
      PermissionAction.read,
    )) {
      setError(
        getPermissionDeniedMessage(
          PermissionResource.case_,
          PermissionAction.read,
        ),
      );
      return false;
    }

    final queryParams = _workspaceProvider.getWorkspaceQueryParams();

    return await loadData(
      operation: () =>
          caseRepository.getCaseDetail(id, queryParams: queryParams),
      successMessage: null, // Don't show success message for fetching
    );
  }

  /// Update case
  Future<bool> updateCase(int id, Map<String, dynamic> payload) async {
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

    final queryParams = _workspaceProvider.getWorkspaceQueryParams();

    return await updateData(
      operation: () =>
          caseRepository.updateCase(id, payload, queryParams: queryParams),
      successMessage: 'Case updated successfully',
    );
  }

  /// Delete case
  Future<bool> deleteCase(int id) async {
    // Check delete permission
    if (!hasPermissionWithOwnership(
      PermissionResource.case_,
      PermissionAction.delete,
    )) {
      setError(
        getPermissionDeniedMessage(
          PermissionResource.case_,
          PermissionAction.delete,
        ),
      );
      return false;
    }

    final queryParams = _workspaceProvider.getWorkspaceQueryParams();

    return await deleteData(
      operation: () => caseRepository.deleteCase(id, queryParams: queryParams),
      successMessage: 'Case deleted successfully',
    );
  }
}
