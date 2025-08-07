import 'package:flutter/material.dart';
import '../../../core/error/failure.dart';
import '../../../data/models/document_model.dart';
import '../../../data/repositories/document_repository.dart';

enum DocumentDetailStatus {
  initial,
  loading,
  loaded,
  error,
}

class DocumentDetailProvider extends ChangeNotifier {
  final DocumentRepository repository;

  DocumentDetailProvider(this.repository);

  DocumentDetailStatus _status = DocumentDetailStatus.initial;
  DocumentDetailStatus get status => _status;

  DocumentModel? _document;
  DocumentModel? get document => _document;

  Failure? _failure;
  Failure? get failure => _failure;

  String? get errorMessage => _failure?.message;

  /// Fetch document details by ID
  Future<void> fetchDocumentDetail(int documentId) async {
    _status = DocumentDetailStatus.loading;
    _failure = null;
    notifyListeners();

    final result = await repository.getDocumentDetail(documentId);

    result.fold(
      (failure) {
        _failure = failure;
        _status = DocumentDetailStatus.error;
      },
      (document) {
        _document = document;
        _status = DocumentDetailStatus.loaded;
      },
    );

    notifyListeners();
  }

  /// Update document details
  Future<bool> updateDocument(int documentId, Map<String, dynamic> updatedFields) async {
    if (_document == null) return false;

    _status = DocumentDetailStatus.loading;
    notifyListeners();

    final result = await repository.updateDocument(documentId, updatedFields);

    return result.fold(
      (failure) {
        _failure = failure;
        _status = DocumentDetailStatus.error;
        notifyListeners();
        return false;
      },
      (updatedDocument) {
        _document = updatedDocument;
        _status = DocumentDetailStatus.loaded;
        notifyListeners();
        return true;
      },
    );
  }

  /// Delete document
  Future<bool> deleteDocument(int documentId) async {
    _status = DocumentDetailStatus.loading;
    notifyListeners();

    final result = await repository.deleteDocument(documentId);

    return result.fold(
      (failure) {
        _failure = failure;
        _status = DocumentDetailStatus.error;
        notifyListeners();
        return false;
      },
      (_) {
        // Document deleted successfully
        _status = DocumentDetailStatus.loaded;
        notifyListeners();
        return true;
      },
    );
  }

  /// Reset provider state
  void reset() {
    _status = DocumentDetailStatus.initial;
    _document = null;
    _failure = null;
    notifyListeners();
  }
}
