import 'package:flutter/material.dart';
import 'package:dartz/dartz.dart';
import 'package:new_ovacs/data/repositories/auth_repository.dart';

import '../../../data/models/country_model.dart';
import '../../core/error/failure.dart';

class CountryProvider extends ChangeNotifier {
  final AuthRepository _authRepository;

  CountryProvider(this._authRepository);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isFetched = false;
  bool get isFetched => _isFetched;

  List<CountryModel> _countries = [];
  List<CountryModel> get countries => _countries;

  String? _error;
  String? get error => _error;

  Future<void> fetchCountries() async {
    if (_isFetched) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    final Either<Failure, List<CountryModel>> result = await _authRepository
        .getCountries();

    result.fold(
      (failure) {
        _error = failure.message;
        _countries = [];
      },
      (data) {
        _countries = data;
        _isFetched = true;
      },
    );

    _isLoading = false;
    notifyListeners();
  }
}
