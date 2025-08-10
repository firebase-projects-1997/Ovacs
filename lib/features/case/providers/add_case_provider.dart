import '../../../core/providers/base_form_provider.dart';
import '../../../data/models/case_model.dart';
import '../../../data/repositories/case_repository.dart';
import '../../../common/providers/workspace_provider.dart';

class AddCaseProvider extends BaseFormProvider<CaseModel> {
  final CaseRepository _caseRepository;
  final WorkspaceProvider _workspaceProvider;

  AddCaseProvider(this._caseRepository, this._workspaceProvider);

  /// Convenience getter for created case
  CaseModel? get createdCase => data;

  @override
  void performValidation() {
    // Add validation logic here if needed
    // For now, we'll assume validation is handled by the UI
  }

  Future<bool> addCase({
    required int clientId,
    required String title,
    required String description,
    required String date,
  }) async {
    final payload = {
      'client_id_input': clientId,
      'title': title,
      'description': description,
      'date': date,
    };

    final queryParams = _workspaceProvider.getWorkspaceQueryParams();

    return await submitForm(
      operation: () =>
          _caseRepository.createCase(payload, queryParams: queryParams),
      successMessage: 'Case created successfully',
    );
  }
}
