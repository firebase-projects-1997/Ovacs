import 'package:flutter/material.dart';
import 'package:dartz/dartz.dart';

import '../../../core/error/failure.dart';
import '../../../core/mixins/optimistic_update_mixin.dart';
import '../../../data/models/session_model.dart';
import '../../../data/models/session_with_pagenation_response.dart';
import '../../../data/repositories/session_repository.dart';
import '../../../common/providers/workspace_provider.dart';

class SessionsProvider extends ChangeNotifier
    with OptimisticUpdateMixin<SessionModel> {
  final SessionRepository sessionRepository;
  final WorkspaceProvider _workspaceProvider;

  SessionsProvider(this.sessionRepository, this._workspaceProvider);

  List<SessionModel> _sessions = [];

  @override
  List<SessionModel> get items => _sessions;

  @override
  set items(List<SessionModel> value) {
    _sessions = value;
  }

  List<SessionModel> get sessions => _sessions;

  bool _isLoading = false;

  @override
  bool get isLoading => _isLoading;

  @override
  set isLoading(bool value) {
    _isLoading = value;
  }

  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

  String? _errorMessage;

  @override
  String? get errorMessage => _errorMessage;

  @override
  set errorMessage(String? value) {
    _errorMessage = value;
  }

  int _currentPage = 1;
  bool _hasMore = true;

  int? _caseId;
  Map<String, dynamic>? _filters;
  int _totalCount = 0;
  bool get hasMoreData => _sessions.length < _totalCount;

  Future<void> fetchSessions(
    int caseId, {
    Map<String, dynamic>? filters,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _currentPage = 1;
    _hasMore = true;
    _sessions.clear();
    _caseId = caseId;
    _filters = filters;
    notifyListeners();

    // Merge workspace parameters (space_id) with filters
    final filtersWithWorkspace = _workspaceProvider.mergeWithWorkspaceParams(
      filters,
    );

    final Either<Failure, SessionsWithPaginationResponse> result =
        await sessionRepository.getSessions(
          caseId,
          page: _currentPage,
          filters: filtersWithWorkspace,
        );

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

    // Merge workspace parameters (space_id) with filters
    final filtersWithWorkspace = _workspaceProvider.mergeWithWorkspaceParams(
      _filters,
    );

    final Either<Failure, SessionsWithPaginationResponse> result =
        await sessionRepository.getSessions(
          _caseId!,
          page: _currentPage,
          filters: filtersWithWorkspace,
        );

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
      // fetchSessions will automatically include workspace context
      await fetchSessions(_caseId!, filters: _filters);
    }
  }

  /// Optimistically adds a new session
  Future<bool> addSessionOptimistic({
    required int caseId,
    required String title,
    required String description,
    required String date,
    String? time,
    int? clientId,
  }) async {
    String isoDateTime = date;
    if (time != null && time.isNotEmpty) {
      isoDateTime = '${date}T$time:00Z';
    }

    // Create a temporary session with a negative ID for optimistic update
    final tempSession = SessionModel(
      id: -DateTime.now().millisecondsSinceEpoch, // Temporary negative ID
      title: title,
      description: description,
      date: DateTime.parse(isoDateTime),
      time: time,
      createdBy: 0, // Temporary created by
      isActive: true,
      caseId: caseId,
      clientId: clientId,
    );

    final payload = {
      'case_id': caseId,
      'title': title,
      'description': description,
      'date': isoDateTime,
      if (clientId != null) 'client_id': clientId,
    };

    // Get workspace query parameters (includes space_id if in connection mode)
    final queryParams = _workspaceProvider.getWorkspaceQueryParams();

    return await optimisticAdd<SessionModel>(
      item: tempSession,
      operation: () =>
          sessionRepository.createSession(payload, queryParams: queryParams),
      getId: (session) => session.id,
      mapResult: (response) =>
          response, // The response is already a SessionModel
    );
  }

  /// Optimistically updates a session
  Future<bool> updateSessionOptimistic({
    required int id,
    required String title,
    required String description,
    required String date,
    String? time,
  }) async {
    // Find the existing session to preserve other fields
    final existingSession = _sessions.firstWhere((s) => s.id == id);

    String isoDateTime = date;
    if (time != null && time.isNotEmpty) {
      isoDateTime = '${date}T$time:00Z';
    }

    final updatedSession = SessionModel(
      id: id,
      title: title,
      description: description,
      date: DateTime.parse(isoDateTime),
      time: time,
      createdBy: existingSession.createdBy,
      isActive: existingSession.isActive,
      caseTitle: existingSession.caseTitle,
      clientName: existingSession.clientName,
      clientId: existingSession.clientId,
      caseId: existingSession.caseId,
    );

    final payload = {
      'title': title,
      'description': description,
      'date': isoDateTime,
    };

    return await optimisticUpdate<SessionModel>(
      updatedItem: updatedSession,
      operation: () => sessionRepository.updateSession(id, payload),
      getId: (session) => session.id,
      mapResult: (response) =>
          response, // The response is already a SessionModel
    );
  }

  /// Optimistically deletes a session
  Future<bool> deleteSessionOptimistic(int sessionId) async {
    return await optimisticDelete<bool>(
      itemId: sessionId,
      operation: () => sessionRepository.deleteSession(sessionId),
      getId: (session) => session.id,
    );
  }
}
