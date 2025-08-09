import 'package:dartz/dartz.dart';
import 'package:new_ovacs/core/constants/app_urls.dart';

import '../../core/error/failure.dart';
import '../../core/network/dio_client.dart';
import '../models/dashboard_summary_model.dart';
import '../models/pagination_model.dart';
import '../models/session_model.dart';
import '../models/session_with_pagenation_response.dart';

class DashboardRepository {
  final DioClient _dioClient;

  DashboardRepository(this._dioClient);

  Future<Either<Failure, DashboardSummaryModel>> getDashboardSummery({
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      final request = await _dioClient.get(
        AppUrls.dashboardSummary,
        queryParameters: queryParams,
      );
      return request.fold((failure) => Left(failure), (response) {
        final data = response.data as Map<String, dynamic>;
        return Right(DashboardSummaryModel.fromJson(data['data']));
      });
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  Future<Either<Failure, List<String>>> getSessionsDate() async {
    try {
      final request = await _dioClient.get(AppUrls.sessionDates);
      return request.fold((failure) => Left(failure), (response) {
        final data = response.data as Map<String, dynamic>;
        final List<dynamic> datesJson = data['data']['dates'] ?? [];
        final List<String> dates = datesJson.map((e) => e.toString()).toList();
        return Right(dates);
      });
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  Future<Either<Failure, SessionsWithPaginationResponse>> getUpcomingSessions({
    int page = 1,
    Map<String, dynamic>? queryParams,
  }) async {
    final params = <String, dynamic>{'page': page};
    if (queryParams != null) {
      params.addAll(queryParams);
    }

    final response = await _dioClient.get(
      AppUrls.upcomingSessions,
      queryParameters: params,
    );

    return response.fold((failure) => Left(failure), (res) {
      try {
        final data = res.data as Map<String, dynamic>;
        final List<SessionModel> sessions = (data['data'] as List)
            .map((e) => SessionModel.fromJson(e as Map<String, dynamic>))
            .toList();

        final pagination = PaginationModel.fromJson(
          data['pagination'] as Map<String, dynamic>,
        );

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
}
