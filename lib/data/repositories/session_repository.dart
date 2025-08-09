import 'package:dartz/dartz.dart';
import 'package:new_ovacs/core/constants/app_urls.dart';
import 'package:new_ovacs/core/error/failure.dart';
import 'package:new_ovacs/core/network/dio_client.dart';

import '../models/pagination_model.dart';
import '../models/session_model.dart';
import '../models/session_with_pagenation_response.dart';

class SessionRepository {
  final DioClient _dio;

  SessionRepository(this._dio);

  Future<Either<Failure, SessionsWithPaginationResponse>> getSessions(
    int caseId, {
    int page = 1,
    int pageSize = 10,
    Map<String, dynamic>? filters,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'page_size': pageSize,
      'case': caseId,
      if (filters != null) ...filters,
    };

    final response = await _dio.get(
      AppUrls.sessions,
      queryParameters: queryParams,
    );

    return response.fold((failure) => Left(failure), (res) {
      try {
        final data = res.data['data'] as Map<String, dynamic>;
        final List<dynamic> sessionsJson = data['data'] ?? [];
        final sessions = sessionsJson
            .map((e) => SessionModel.fromJson(e))
            .toList();

        final pagination = PaginationModel.fromJson(data['pagination']);
        return Right(
          SessionsWithPaginationResponse(
            sessions: sessions,
            pagination: pagination,
          ),
        );
      } catch (e) {
        return Left(ServerFailure('Error parsing sessions list'));
      }
    });
  }

  /// جلب تفاصيل جلسة واحدة
  Future<Either<Failure, SessionModel>> getSessionDetails(
    int id, {
    Map<String, dynamic>? queryParams,
  }) async {
    final response = await _dio.get(
      '${AppUrls.sessions}$id/',
      queryParameters: queryParams,
    );

    return response.fold((failure) => Left(failure), (res) {
      try {
        final data = res.data['data'];
        return Right(SessionModel.fromJson(data));
      } catch (e) {
        return Left(ServerFailure('Error parsing session detail'));
      }
    });
  }

  /// إنشاء جلسة جديدة
  Future<Either<Failure, SessionModel>> createSession(
    Map<String, dynamic> payload, {
    Map<String, dynamic>? queryParams,
  }) async {
    final response = await _dio.post(
      AppUrls.sessions,
      data: payload,
      queryParameters: queryParams,
    );

    return response.fold((failure) => Left(failure), (res) {
      try {
        final data = res.data['data'];
        return Right(SessionModel.fromJson(data));
      } catch (e) {
        return Left(ServerFailure('Error creating session'));
      }
    });
  }

  /// تحديث جلسة موجودة
  Future<Either<Failure, SessionModel>> updateSession(
    int id,
    Map<String, dynamic> payload, {
    Map<String, dynamic>? queryParams,
  }) async {
    final response = await _dio.put(
      '${AppUrls.sessions}$id/',
      data: payload,
      queryParameters: queryParams,
    );

    return response.fold((failure) => Left(failure), (res) {
      try {
        final data = res.data['data'];
        return Right(SessionModel.fromJson(data));
      } catch (e) {
        return Left(ServerFailure('Error updating session'));
      }
    });
  }

  /// حذف جلسة
  Future<Either<Failure, bool>> deleteSession(
    int id, {
    Map<String, dynamic>? queryParams,
  }) async {
    final response = await _dio.delete(
      '${AppUrls.sessions}$id/',
      queryParameters: queryParams,
    );

    return response.fold((failure) => Left(failure), (_) => const Right(true));
  }
}
