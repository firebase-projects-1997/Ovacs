import 'package:flutter/material.dart';

import '../../../data/models/case_model.dart';
import '../../../data/repositories/case_repository.dart';

class CasesProvider extends ChangeNotifier {
  final CaseRepository _repository;
  CasesProvider(this._repository);

  List<CaseModel> _cases = [];
  List<CaseModel> get cases => _cases;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

  int _currentPage = 1;
  bool _hasMore = true;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Map<String, dynamic>? _filters;

  Future<void> fetchCases({Map<String, dynamic>? filters}) async {
    _isLoading = true;
    _errorMessage = null;
    _currentPage = 1;
    _hasMore = true;
    _filters = filters;
    notifyListeners();

    final result = await _repository.getCases(
      page: _currentPage,
      filters: _filters,
    );

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _cases = [];
      },
      (response) {
        _cases = response.cases;
        _hasMore = response.pagination.hasNext;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchMoreCases() async {
    if (_isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    notifyListeners();

    _currentPage++;
    final result = await _repository.getCases(
      page: _currentPage,
      filters: _filters,
    );

    result.fold(
      (failure) {
        _errorMessage = failure.message;
      },
      (response) {
        _cases.addAll(response.cases);
        _hasMore = response.pagination.hasNext;
      },
    );

    _isLoadingMore = false;
    notifyListeners();
  }
}
