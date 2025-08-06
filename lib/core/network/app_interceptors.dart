import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../features/auth/providers/auth_provider.dart';

class AppInterceptors extends Interceptor {
  final AuthProvider _authProvider;

  AppInterceptors(this._authProvider);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = _authProvider.accessToken;

    if (token != null) {
      debugPrint('\n$token\n');
      options.headers['Authorization'] = 'Bearer $token';
    }

    if (options.contentType?.contains('multipart/form-data') == true) {
      options.headers.remove('Content-Type');
    }

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    debugPrint('[Error] ${err.response?.statusCode} ${err.response?.data}');
    if (err.response?.statusCode == 401 &&
        !_isRefreshEndpoint(err.requestOptions.path)) {
      final success = await _authProvider.refreshAuthToken();

      if (success) {
        final newToken = _authProvider.accessToken;

        if (newToken != null) {
          final retryRequest = err.requestOptions;
          retryRequest.headers['Authorization'] = 'Bearer $newToken';

          try {
            final response = await GetIt.I<Dio>().fetch(retryRequest);
            return handler.resolve(response);
          } catch (e) {
            return handler.reject(err);
          }
        }
      }
    }

    return handler.next(err);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint(
      '[RESPONSE] ${response.statusCode} ${response.requestOptions.path}',
    );
    debugPrint('[DATA] ${response.data}');

    return handler.next(response);
  }

  bool _isRefreshEndpoint(String path) {
    return path.contains('refresh') || path.contains('token');
  }
}
