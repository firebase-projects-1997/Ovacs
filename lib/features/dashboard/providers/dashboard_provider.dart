import 'package:flutter/material.dart';

import '../../../data/models/dashboard_summary_model.dart';
import '../../../data/models/session_model.dart';
import '../../../data/repositories/dashboard_repository.dart';

class DashboardProvider extends ChangeNotifier {
  final DashboardRepository repository;

  DashboardProvider(this.repository);

  bool isLoading = false;
  String? errorMessage;

  DashboardSummaryModel summary = DashboardSummaryModel(
    totalClients: 0,
    totalCases: 0,
    totalDocuments: 0,
    spaceUsedPercentage: 0.0,
  );
  // List<String> sessionDates = [];
  List<SessionModel> sessions = [];
  int currentPage = 1;
  int totalPages = 1;
  bool isFetchingMore = false;

  Future<void> fetchAllDashboardData() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final summaryResult = await repository.getDashboardSummery();
    // final dateResult = await repository.getSessionsDate();
    final sessionsResult = await repository.getUpcomingSessions(page: 1);

    summaryResult.fold((l) => errorMessage = l.message, (r) => summary = r);

    // dateResult.fold((l) => errorMessage ??= l.message, (r) => sessionDates = r);

    sessionsResult.fold((l) => errorMessage ??= l.message, (r) {
      sessions = r.sessions;
      currentPage = r.pagination.currentPage;
      totalPages = r.pagination.totalPages;
    });

    isLoading = false;
    notifyListeners();
  }

  Future<void> loadMoreSessions() async {
    if (isFetchingMore || currentPage >= totalPages) return;

    isFetchingMore = true;
    notifyListeners();

    final nextPage = currentPage + 1;
    final result = await repository.getUpcomingSessions(page: nextPage);

    result.fold((l) => null, (r) {
      sessions.addAll(r.sessions);
      currentPage = r.pagination.currentPage;
      totalPages = r.pagination.totalPages;
    });

    isFetchingMore = false;
    notifyListeners();
  }
}
