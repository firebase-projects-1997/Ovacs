import 'package:flutter/material.dart';
import 'package:dartz/dartz.dart';

import '../../../core/error/failure.dart';
import '../../../data/models/session_model.dart';
import '../../../data/models/session_with_pagenation_response.dart';
import '../../../data/repositories/session_repository.dart';

class SessionsProvider extends ChangeNotifier {
  final SessionRepository sessionRepository;

  SessionsProvider(this.sessionRepository);

  List<SessionModel> _sessions = [];
  List<SessionModel> get sessions => _sessions;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  int _currentPage = 1;
  bool _hasMore = true;

  int? _caseId;
  int _totalCount = 0;
  bool get hasMoreData => _sessions.length < _totalCount;

  Future<void> fetchSessions(int caseId) async {
    _isLoading = true;
    _errorMessage = null;
    _currentPage = 1;
    _hasMore = true;
    _sessions.clear();
    _caseId = caseId;
    notifyListeners();

    final Either<Failure, SessionsWithPaginationResponse> result =
        await sessionRepository.getSessions(caseId, page: _currentPage);

    result.fold(
      (failure) {
        _errorMessage = failure.message;
      },
      (response) {
        _sessions = response.sessions;
        _hasMore = response.pagination.hasNext;
        _totalCount = response.pagination.count;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchMoreSessions() async {
    if (_isLoadingMore || !_hasMore || _caseId == null) return;

    _isLoadingMore = true;
    notifyListeners();

    _currentPage++;

    final Either<Failure, SessionsWithPaginationResponse> result =
        await sessionRepository.getSessions(_caseId!, page: _currentPage);

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _currentPage--;
      },
      (response) {
        _sessions.addAll(response.sessions);
        _hasMore = response.pagination.hasNext;
        _totalCount = response.pagination.count;
      },
    );

    _isLoadingMore = false;
    notifyListeners();
  }

  Future<void> refresh() async {
    if (_caseId != null) {
      await fetchSessions(_caseId!);
    }
  }
}
