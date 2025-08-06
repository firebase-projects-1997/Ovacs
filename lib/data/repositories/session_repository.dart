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
    final queryParams = <String, String>{
      'page': page.toString(),
      'page_size': pageSize.toString(),
      'case': caseId.toString(),
      if (filters != null) ...filters.map((k, v) => MapEntry(k, v.toString())),
    };

    final uri = Uri.parse(
      AppUrls.sessions,
    ).replace(queryParameters: queryParams);
    final response = await _dio.get(uri.toString());

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
  Future<Either<Failure, SessionModel>> getSessionDetails(int id) async {
    final response = await _dio.get('${AppUrls.sessions}$id/');

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
    Map<String, dynamic> payload,
  ) async {
    final response = await _dio.post(AppUrls.sessions, data: payload);

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
    Map<String, dynamic> payload,
  ) async {
    final response = await _dio.put('${AppUrls.sessions}$id/', data: payload);

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
  Future<Either<Failure, bool>> deleteSession(int id) async {
    final response = await _dio.delete('${AppUrls.sessions}$id/');

    return response.fold((failure) => Left(failure), (_) => const Right(true));
  }
}
