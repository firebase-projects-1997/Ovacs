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
        if (error.response?.data is Map<String, dynamic>) {
          final data = error.response!.data as Map<String, dynamic>;
          if (data.containsKey('message')) return data['message'].toString();
          if (data.containsKey('non_field_errors') &&
              data['non_field_errors'] is List) {
            return (data['non_field_errors'] as List).join(', ');
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
          case 502:
          case 503:
            return ServerFailure(message);
          default:
            return ServerFailure(message);
        }
    }
  }
}
