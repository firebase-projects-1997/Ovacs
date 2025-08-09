import 'package:flutter/material.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failure.dart';
import '../../../data/models/case_model.dart';
import '../../../data/repositories/case_repository.dart';
import '../../../common/providers/workspace_provider.dart';

class AddCaseProvider extends ChangeNotifier {
  final CaseRepository _caseRepository;
  final WorkspaceProvider _workspaceProvider;

  AddCaseProvider(this._caseRepository, this._workspaceProvider);

  bool _isLoading = false;
  String? _errorMessage;
  CaseModel? _createdCase;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  CaseModel? get createdCase => _createdCase;

  Future<bool> addCase({
    required int clientId,
    required String title,
    required String description,
    required String date,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final payload = {
      'client_id_input': clientId,
      'title': title,
      'description': description,
      'date': date,
    };

    final queryParams = _workspaceProvider.getWorkspaceQueryParams();
    final Either<Failure, CaseModel> result = await _caseRepository.createCase(
      payload,
      queryParams: queryParams,
    );

    return result.fold(
      (failure) {
        _errorMessage = failure.message;
        _isLoading = false;
        notifyListeners();
        return false;
      },
      (caseModel) {
        _createdCase = caseModel;
        _isLoading = false;
        notifyListeners();
        return true;
      },
    );
  }

  void clear() {
    _isLoading = false;
    _errorMessage = null;
    _createdCase = null;
    notifyListeners();
  }
}
