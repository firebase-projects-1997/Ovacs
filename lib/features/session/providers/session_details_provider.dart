import 'package:flutter/material.dart';

import '../../../data/models/session_model.dart';
import '../../../data/repositories/session_repository.dart';
import '../../../common/providers/workspace_provider.dart';

enum SessionDetailStatus { initial, loading, loaded, error }

class SessionDetailProvider extends ChangeNotifier {
  final SessionRepository _sessionRepository;
  final WorkspaceProvider _workspaceProvider;

  SessionDetailProvider(this._sessionRepository, this._workspaceProvider);

  SessionModel? sessionModel;
  SessionDetailStatus status = SessionDetailStatus.initial;
  String? errorMessage;

  // جلب تفاصيل الحالة
  Future<void> fetchSessionDetails(int id) async {
    status = SessionDetailStatus.loading;
    errorMessage = null;
    notifyListeners();

    final queryParams = _workspaceProvider.getWorkspaceQueryParams();
    final result = await _sessionRepository.getSessionDetails(
      id,
      queryParams: queryParams,
    );
    result.fold(
      (failure) {
        status = SessionDetailStatus.error;
        errorMessage = failure.message;
        notifyListeners();
      },
      (sessionData) {
        sessionModel = sessionData;
        status = SessionDetailStatus.loaded;
        notifyListeners();
      },
    );
  }

  // تحديث الحالة
  Future<bool> updateSession(int id, Map<String, dynamic> payload) async {
    status = SessionDetailStatus.loading;
    notifyListeners();

    final queryParams = _workspaceProvider.getWorkspaceQueryParams();
    final result = await _sessionRepository.updateSession(
      id,
      payload,
      queryParams: queryParams,
    );
    return result.fold(
      (failure) {
        errorMessage = failure.message;
        status = SessionDetailStatus.error;
        notifyListeners();
        return false;
      },
      (updatedSession) {
        sessionModel = updatedSession;
        status = SessionDetailStatus.loaded;
        notifyListeners();
        return true;
      },
    );
  }

  // حذف الحالة
  Future<bool> deleteSession(int id) async {
    status = SessionDetailStatus.loading;
    notifyListeners();

    final queryParams = _workspaceProvider.getWorkspaceQueryParams();
    final result = await _sessionRepository.deleteSession(
      id,
      queryParams: queryParams,
    );
    return result.fold(
      (failure) {
        errorMessage = failure.message;
        status = SessionDetailStatus.error;
        notifyListeners();
        return false;
      },
      (success) {
        status = SessionDetailStatus.initial;
        sessionModel = null;
        notifyListeners();
        return true;
      },
    );
  }
}
