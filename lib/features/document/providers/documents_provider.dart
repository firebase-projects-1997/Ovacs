import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../data/models/document_model.dart';
import '../../../data/repositories/document_repository.dart';

class DocumentsProvider extends ChangeNotifier {
  final DocumentRepository _repository;

  DocumentsProvider(this._repository);

  List<DocumentModel> _documents = [];
  List<DocumentModel> get documents => _documents;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

  int _currentPage = 1;
  bool _hasMore = true;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isDownloading = false;
  String? _downloadViewErrorMessage;

  bool get isDownloading => _isDownloading;
  String? get downloadViewErrorMessage => _downloadViewErrorMessage;

  String? _editErrorMessage;
  String? get editErrorMessage => _editErrorMessage;

  String? _deleteErrorMessage;
  String? get deleteErrorMessage => _deleteErrorMessage;

  int? _sessionId;

  Future<void> fetchDocumentsBySession({
    Map<String, dynamic>? extraParams,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _currentPage = 1;
    _hasMore = true;

    notifyListeners();

    final result = await _repository.listDocuments(
      params: {'page': _currentPage, if (extraParams != null) ...extraParams},
    );

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _documents = [];
      },
      (response) {
        _documents = response.documents;
        _hasMore = response.pagination.hasNext;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchMoreDocuments() async {
    if (_isLoadingMore || !_hasMore || _sessionId == null) return;

    _isLoadingMore = true;
    notifyListeners();

    _currentPage++;
    final result = await _repository.listDocuments(
      params: {'session_id': _sessionId, 'page': _currentPage},
    );

    result.fold(
      (failure) {
        _errorMessage = failure.message;
      },
      (response) {
        _documents.addAll(response.documents);
        _hasMore = response.pagination.hasNext;
      },
    );

    _isLoadingMore = false;
    notifyListeners();
  }

  final Set<int> _downloadingDocumentIds = {};

  bool isDocumentDownloading(int id) => _downloadingDocumentIds.contains(id);

  Future<bool> downloadFile(
    String signedUrl,
    String fileName,
    int documentId,
  ) async {
    _downloadingDocumentIds.add(documentId);
    notifyListeners();

    try {
      final status = await Permission.storage.request();
      final status2 = await Permission.videos.request();
      final status3 = await Permission.photos.request();
      final status4 = await Permission.audio.request();

      if (status.isGranted ||
          status2.isGranted ||
          status3.isGranted ||
          status4.isGranted) {
        final result = await _repository.getFileBySignedUrl(signedUrl);

        return await result.fold(
          (failure) {
            _downloadViewErrorMessage = failure.message;
            _downloadingDocumentIds.remove(documentId);
            notifyListeners();
            return Future.value(false);
          },
          (response) async {
            Directory? downloadsDir;

            if (Platform.isAndroid) {
              downloadsDir = Directory('/storage/emulated/0/Download/Ovacs');
            } else {
              downloadsDir = await getDownloadsDirectory();
              downloadsDir = Directory(path.join(downloadsDir!.path, 'Ovacs'));
            }

            if (!(await downloadsDir.exists())) {
              await downloadsDir.create(recursive: true);
            }

            final filePath = path.join(downloadsDir.path, fileName);
            final file = File(filePath);
            await file.writeAsBytes(response.data as Uint8List);

            _downloadingDocumentIds.remove(documentId);
            notifyListeners();

            return true;
          },
        );
      } else {
        _downloadViewErrorMessage = "Storage permission denied";
        _downloadingDocumentIds.remove(documentId);
        notifyListeners();
        return false;
      }
    } catch (e) {
      _downloadViewErrorMessage = e.toString();
      _downloadingDocumentIds.remove(documentId);
      notifyListeners();
      return false;
    }
  }

  /// Download and open file using platform default app
  Future<void> viewFile(String signedUrl, String fileName) async {
    final filePath = await viewingFile(signedUrl, fileName);
    if (filePath != null) {
      await OpenFilex.open(filePath);
    }
  }

  Future<String?> viewingFile(String signedUrl, String fileName) async {
    final result = await _repository.getFileBySignedUrl(signedUrl);

    return await result.fold(
      (failure) {
        _downloadViewErrorMessage = failure.message;
        notifyListeners();
        return Future.value(null);
      },
      (response) async {
        final directory = await getTemporaryDirectory();
        final filePath = path.join(directory.path, fileName);

        final file = File(filePath);
        await file.writeAsBytes(response.data as Uint8List);
        return filePath;
      },
    );
  }

  Future<void> deleteDocument(int id) async {
    _isLoading = true;
    _deleteErrorMessage = null;
    notifyListeners();

    final result = await _repository.deleteDocument(id);
    result.fold(
      (failure) => _deleteErrorMessage = failure.message,
      (_) => _documents.removeWhere((doc) => doc.id == id),
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateDocument(
    int id,
    Map<String, dynamic> updatedFields,
  ) async {
    _isLoading = true;
    _editErrorMessage = null;
    notifyListeners();

    final result = await _repository.updateDocument(id, updatedFields);
    result.fold((failure) => _editErrorMessage = failure.message, (_) async {
      final detailResult = await _repository.getDocumentDetail(id);
      detailResult.fold((_) => null, (updatedDoc) {
        final index = _documents.indexWhere((doc) => doc.id == id);
        if (index != -1) {
          _documents[index] = updatedDoc;
        }
      });
    });

    _isLoading = false;
    notifyListeners();
  }
}
