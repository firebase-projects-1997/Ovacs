import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../error/failure.dart';

class DioClient {
  static final DioClient _singleton = DioClient._internal();
  late Dio _dio;

  factory DioClient() => _singleton;

  DioClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'https://ovacs.com/backend/api',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        responseType: ResponseType.json,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
  }

  Dio get dio => _dio;

  Future<Either<Failure, Response>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return Right(response);
    } on DioException catch (e) {
      return Left(_mapDioErrorToFailure(e));
    } catch (e) {
      return Left(const ServerFailure("An unexpected error occurred."));
    }
  }

  Future<Either<Failure, Response>> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return Right(response);
    } on DioException catch (e) {
      return Left(_mapDioErrorToFailure(e));
    } catch (e) {
      return Left(const ServerFailure("An unexpected error occurred."));
    }
  }

  Future<Either<Failure, Response>> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return Right(response);
    } on DioException catch (e) {
      return Left(_mapDioErrorToFailure(e));
    } catch (e) {
      return Left(const ServerFailure("An unexpected error occurred."));
    }
  }

  Future<Either<Failure, Response>> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return Right(response);
    } on DioException catch (e) {
      return Left(_mapDioErrorToFailure(e));
    } catch (e) {
      return Left(const ServerFailure("An unexpected error occurred."));
    }
  }

  Future<Either<Failure, Response>> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return Right(response);
    } on DioException catch (e) {
      return Left(_mapDioErrorToFailure(e));
    } catch (e) {
      return Left(const ServerFailure("An unexpected error occurred."));
    }
  }

  Failure _mapDioErrorToFailure(DioException error) {
    // Safely extract message
    String extractMessage() {
      try {
        final responseData = error.response?.data;

        // Handle HTML error responses (like Django debug pages)
        if (responseData is String) {
          // Check if it's an HTML error page
          if (responseData.contains('<html>') ||
              responseData.contains('<!DOCTYPE')) {
            // Extract error type from HTML if possible
            if (responseData.contains('TypeError')) {
              return "Server configuration error. Please contact support.";
            } else if (responseData.contains('500')) {
              return "Internal server error. Please try again later.";
            } else if (responseData.contains('Permission')) {
              return "Permission system error. Please contact support.";
            }
            return "Server error occurred. Please try again later.";
          }
          return responseData;
        }

        if (responseData is Map<String, dynamic>) {
          // Handle field-specific validation errors from data field
          if (responseData.containsKey('data')) {
            final innerData = responseData['data'];
            if (innerData is Map<String, dynamic>) {
              // Check for non_field_errors first
              if (innerData['non_field_errors'] is List) {
                return (innerData['non_field_errors'] as List).join(', ');
              }

              // Extract field-specific errors (like email, password, etc.)
              final fieldErrors = <String>[];
              innerData.forEach((key, value) {
                if (value is List && value.isNotEmpty) {
                  fieldErrors.addAll(value.map((e) => e.toString()));
                }
              });

              if (fieldErrors.isNotEmpty) {
                return fieldErrors.join(', ');
              }
            }
          }

          // Try top-level non_field_errors
          if (responseData['non_field_errors'] is List) {
            return (responseData['non_field_errors'] as List).join(', ');
          }

          // Try top-level message
          if (responseData.containsKey('message')) {
            return responseData['message'].toString();
          }

          // Try detail field (common in DRF)
          if (responseData.containsKey('detail')) {
            return responseData['detail'].toString();
          }

          // Try error field
          if (responseData.containsKey('error')) {
            return responseData['error'].toString();
          }

          // Handle backend RBAC error structure
          if (responseData.containsKey('type') &&
              responseData['type'] == 'error') {
            return responseData['message']?.toString() ?? 'Permission denied';
          }
        }
        return "Something went wrong.";
      } catch (_) {
        return "Something went wrong.";
      }
    }

    final message = extractMessage();

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkFailure("Connection timed out. Please try again.");
      case DioExceptionType.connectionError:
        return const NetworkFailure("No internet connection.");
      case DioExceptionType.badCertificate:
        return const ServerFailure("Invalid certificate.");
      case DioExceptionType.cancel:
        return const ServerFailure("Request was cancelled.");
      case DioExceptionType.unknown:
        return const ServerFailure("An unknown error occurred.");
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;

        switch (statusCode) {
          case 400:
            return BadRequestFailure(message);
          case 401:
            return UnauthorizedFailure(message);
          case 403:
            return ForbiddenFailure(message);
          case 404:
            return NotFoundFailure(message);
          case 500:
            // Provide more specific error message for 500 errors
            if (message.contains("Permission") ||
                message.contains("unhashable")) {
              return ServerFailure(
                "Server permission system error. Please contact support.",
              );
            } else if (message.contains("TypeError")) {
              return ServerFailure(
                "Server configuration error. Please contact support.",
              );
            }
            return ServerFailure(
              "Internal server error. Please try again later.",
            );
          case 502:
            return ServerFailure(
              "Bad gateway. Server is temporarily unavailable.",
            );
          case 503:
            return ServerFailure(
              "Service unavailable. Please try again later.",
            );
          default:
            return ServerFailure(message);
        }
    }
  }
}
