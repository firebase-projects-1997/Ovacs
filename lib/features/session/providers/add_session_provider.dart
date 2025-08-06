import 'package:flutter/material.dart';
import '../../../data/repositories/session_repository.dart';

enum AddSessionStatus { initial, loading, success, error }

class AddSessionProvider extends ChangeNotifier {
  final SessionRepository sessionRepository;

  AddSessionProvider(this.sessionRepository);

  AddSessionStatus _status = AddSessionStatus.initial;
  AddSessionStatus get status => _status;

  String? errorMessage;

  Future<bool> addSession({
    required int caseId,
    required String title,
    required String description,
    required String date, // expected in 'yyyy-MM-dd' or ISO format
    String? time, // optional, e.g. 'HH:mm'
    int? clientId, // optional if needed
  }) async {
    _status = AddSessionStatus.loading;
    errorMessage = null;
    notifyListeners();

    String isoDateTime = date;
    if (time != null && time.isNotEmpty) {
      isoDateTime = '${date}T$time:00Z';
    }

    final payload = {
      'case_id': caseId,
      'title': title,
      'description': description,
      'date': isoDateTime,
      if (clientId != null) 'client_id': clientId,
    };

    final result = await sessionRepository.createSession(payload);

    return result.fold(
      (failure) {
        _status = AddSessionStatus.error;
        errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (session) {
        _status = AddSessionStatus.success;
        notifyListeners();
        return true;
      },
    );
  }

  void reset() {
    _status = AddSessionStatus.initial;
    errorMessage = null;
    notifyListeners();
  }
}
