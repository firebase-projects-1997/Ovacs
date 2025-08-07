import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:new_ovacs/services/storage_service.dart';

import '../../../common/providers/workspace_provider.dart';
import '../../../core/constants/storage_keys.dart';
import '../../../data/models/login_response.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final StorageService _storageService;
  final AuthRepository _authRepository;
  AuthProvider(this._storageService, this._authRepository);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  UserModel? _user;
  UserModel? get user => _user;

  String? _accessToken;
  String? get accessToken => _accessToken;

  String? _refreshToken;
  String? get refreshToken => _refreshToken;

  void _startLoading() {
    _isLoading = true;
    _error = null;
    notifyListeners();
  }

  void _stopLoading() {
    _isLoading = false;
    notifyListeners();
  }

  Future<void> init() async {
    final saved = _storageService.getString(StorageKeys.loginResponse);
    if (saved != null) {
      try {
        final decoded = jsonDecode(saved);
        final loginResponse = LoginResponse.fromJson(decoded);
        _user = loginResponse.user;
        _accessToken = loginResponse.accessToken;
        _refreshToken = loginResponse.refreshToken;
        notifyListeners();
      } catch (e) {
        await _storageService.remove(StorageKeys.loginResponse);
      }
    }
  }

  Future<bool> login({required String email, required String password}) async {
    _startLoading();
    final result = await _authRepository.login(
      email: email,
      password: password,
    );
    _stopLoading();
    return result.fold(
      (failure) {
        _error = failure.message;
        return false;
      },
      (data) async {
        _user = data.user;
        _accessToken = data.accessToken;
        _refreshToken = data.refreshToken;
        await _storageService.setString(
          StorageKeys.loginResponse,
          jsonEncode(data.toJson()),
        );
        notifyListeners();
        return true;
      },
    );
  }

  Future<bool> register({
    required String name,
    required String email,
    required String mobile,
    required String password,
    required int countryId,
  }) async {
    _startLoading();
    final result = await _authRepository.register(
      name: name,
      email: email,
      mobile: mobile,
      password: password,
      countryId: countryId,
    );
    _stopLoading();
    return result.fold((failure) {
      _error = failure.message;
      return false;
    }, (_) => true);
  }

  Future<bool> confirmAccount({
    required String email,
    required String confirmationCode,
  }) async {
    _startLoading();
    final result = await _authRepository.confirmAccount(
      email: email,
      confirmationCode: confirmationCode,
    );
    _stopLoading();
    return result.fold((failure) {
      _error = failure.message;
      return false;
    }, (_) => true);
  }

  Future<bool> resendConfirmationCode(String email) async {
    _startLoading();
    final result = await _authRepository.resendConfirmationCode(email);
    _stopLoading();
    return result.fold((failure) {
      _error = failure.message;
      return false;
    }, (_) => true);
  }

  Future<bool> requestPasswordReset(String email) async {
    _startLoading();
    final result = await _authRepository.passwordResetRequest(email);
    _stopLoading();
    return result.fold((failure) {
      _error = failure.message;
      return false;
    }, (_) => true);
  }

  Future<bool> confirmPasswordReset({
    required String email,
    required String token,
    required String newPassword,
  }) async {
    _startLoading();
    final result = await _authRepository.passwordResetConfirm(
      email: email,
      token: token,
      newPassword: newPassword,
    );
    _stopLoading();
    return result.fold((failure) {
      _error = failure.message;
      return false;
    }, (_) => true);
  }

  Future<bool> refreshAuthToken() async {
    if (_refreshToken == null) return false;
    _startLoading();
    final result = await _authRepository.refreshToken(_refreshToken!);
    _stopLoading();
    return result.fold(
      (failure) {
        _error = failure.message;
        return false;
      },
      (res) async {
        _accessToken = res['access_token'];
        _refreshToken = res['refresh_token'];

        final saved = _storageService.getString(StorageKeys.loginResponse);
        if (saved != null) {
          try {
            final decoded = jsonDecode(saved);
            final oldLogin = LoginResponse.fromJson(decoded);
            final updatedLogin = oldLogin.copyWith(
              accessToken: _accessToken,
              refreshToken: _refreshToken,
            );
            await _storageService.setString(
              StorageKeys.loginResponse,
              jsonEncode(updatedLogin.toJson()),
            );
          } catch (_) {
            await _storageService.remove(StorageKeys.loginResponse);
          }
        }

        notifyListeners();
        return true;
      },
    );
  }

  Future<bool> fetchAndUpdateUserInfo() async {
    _startLoading();
    final result = await _authRepository.getAccountInfo();
    _stopLoading();

    return result.fold(
      (failure) {
        _error = failure.message;
        return false;
      },
      (data) async {
        _user = data;

        final saved = _storageService.getString(StorageKeys.loginResponse);
        if (saved != null) {
          try {
            final decoded = jsonDecode(saved);
            final oldLogin = LoginResponse.fromJson(decoded);
            final updatedLogin = oldLogin.copyWith(user: _user);
            await _storageService.setString(
              StorageKeys.loginResponse,
              jsonEncode(updatedLogin.toJson()),
            );
          } catch (_) {
            await _storageService.remove(StorageKeys.loginResponse);
          }
        }

        notifyListeners();
        return true;
      },
    );
  }

  void logout() async {
    _user = null;
    _accessToken = null;
    _refreshToken = null;
    await _storageService.remove(StorageKeys.loginResponse);

    // Reset workspace state on logout
    try {
      final workspaceProvider = GetIt.instance<WorkspaceProvider>();
      await workspaceProvider.reset();
    } catch (e) {
      // Workspace provider might not be available during app shutdown
    }

    notifyListeners();
  }
}
