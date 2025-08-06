import 'package:flutter/material.dart';
import '../../../../core/error/failure.dart';
import '../../../data/models/case_model.dart';
import '../../../data/models/pagination_model.dart';
import '../../../data/repositories/case_repository.dart';

class CasesSearchProvider extends ChangeNotifier {
  final CaseRepository _repository;

  CasesSearchProvider(this._repository);

  List<CaseModel> _cases = [];
  int _currentPage = 1;
  bool _isLoading = false;
  Failure? _error;
  PaginationModel? _pagination;

  // Filters
  String? searchText;
  String? ordering;
  String? clientName;
  String? dateAfter;
  String? dateBefore;

  List<CaseModel> get cases => _cases;
  bool get isLoading => _isLoading;
  Failure? get error => _error;
  PaginationModel? get pagination => _pagination;

  void setSearchText(String? value) {
    searchText = value;
    _currentPage = 1;
    fetchCases();
  }

  void setOrdering(String? value) {
    ordering = value;
    _currentPage = 1;
    fetchCases();
  }

  void setClientName(String? value) {
    clientName = value;
    _currentPage = 1;
    fetchCases();
  }

  void setDateAfter(String? value) {
    dateAfter = value;
    _currentPage = 1;
    fetchCases();
  }

  void setDateBefore(String? value) {
    dateBefore = value;
    _currentPage = 1;
    fetchCases();
  }

  void setPage(int page) {
    _currentPage = page;
    fetchCases();
  }

  Future<void> fetchCases() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final filters = <String, dynamic>{
      if (searchText != null && searchText!.isNotEmpty) 'search': searchText,
      if (ordering != null && ordering!.isNotEmpty) 'ordering': ordering,
      if (clientName != null && clientName!.isNotEmpty) 'client': clientName,
      if (dateAfter != null && dateAfter!.isNotEmpty) 'date_after': dateAfter,
      if (dateBefore != null && dateBefore!.isNotEmpty)
        'date_before': dateBefore,
    };

    final result = await _repository.getCases(
      page: _currentPage,
      filters: filters,
    );

    result.fold(
      (failure) {
        _error = failure;
        _cases = [];
        _pagination = null;
      },
      (data) {
        _cases = data.cases;
        _pagination = data.pagination;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  void clearFilters() {
    searchText = null;
    ordering = null;
    clientName = null;
    dateAfter = null;
    dateBefore = null;
    _currentPage = 1;
    fetchCases();
  }
}
