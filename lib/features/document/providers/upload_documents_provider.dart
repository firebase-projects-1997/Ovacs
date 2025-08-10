import 'package:flutter/material.dart';

import '../../../common/providers/workspace_provider.dart';
import '../../../data/models/document_model.dart';
import '../../../data/repositories/document_repository.dart';

enum UploadDocumentsStatus { initial, loading, success, failure }

class UploadDocumentsProvider extends ChangeNotifier {
  final DocumentRepository _documentRepository;
  final WorkspaceProvider _workspaceProvider;

  UploadDocumentsProvider(this._documentRepository, this._workspaceProvider);

  UploadDocumentsStatus _status = UploadDocumentsStatus.initial;
  UploadDocumentsStatus get status => _status;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<DocumentModel> _uploadedDocuments = [];
  List<DocumentModel> get uploadedDocuments => _uploadedDocuments;

  Future<void> uploadDocuments({
    required List<String> filePaths,
    required String securityLevel,
    required int sessionId,
    required bool storeAsGroup,
    int? groupId,
    String? groupName,
    String? groupDescription,
  }) async {
    _status = UploadDocumentsStatus.loading;
    _errorMessage = null;
    _uploadedDocuments = [];
    notifyListeners();

    // Get workspace query parameters (includes space_id if in connection mode)
    final queryParams = _workspaceProvider.getWorkspaceQueryParams();

    final result = await _documentRepository.uploadDocuments(
      filePaths: filePaths,
      securityLevel: securityLevel,
      sessionId: sessionId,
      storeAsGroup: storeAsGroup,
      groupId: groupId,
      groupName: groupName,
      groupDescription: groupDescription,
      queryParams: queryParams,
    );

    result.fold(
      (failure) {
        _status = UploadDocumentsStatus.failure;
        _errorMessage = failure.message;
      },
      (documents) {
        _status = UploadDocumentsStatus.success;
        _uploadedDocuments = documents;
      },
    );

    notifyListeners();
  }

  void reset() {
    _status = UploadDocumentsStatus.initial;
    _errorMessage = null;
    _uploadedDocuments = [];
    notifyListeners();
  }
}
