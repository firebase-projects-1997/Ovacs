import 'package:flutter/material.dart';

import '../../../data/models/session_model.dart';
import '../../../data/repositories/session_repository.dart';

enum SessionDetailStatus { initial, loading, loaded, error }

class SessionDetailProvider extends ChangeNotifier {
  final SessionRepository _sessionRepository;

  SessionDetailProvider(this._sessionRepository);

  SessionModel? sessionModel;
  SessionDetailStatus status = SessionDetailStatus.initial;
  String? errorMessage;

  // جلب تفاصيل الحالة
  Future<void> fetchSessionDetails(int id) async {
    status = SessionDetailStatus.loading;
    errorMessage = null;
    notifyListeners();

    final result = await _sessionRepository.getSessionDetails(id);
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

    final result = await _sessionRepository.updateSession(id, payload);
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

    final result = await _sessionRepository.deleteSession(id);
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
