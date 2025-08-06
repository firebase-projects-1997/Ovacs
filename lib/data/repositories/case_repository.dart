import 'package:dartz/dartz.dart';
import 'package:new_ovacs/core/constants/app_urls.dart';
import 'package:new_ovacs/core/error/failure.dart';
import 'package:new_ovacs/core/network/dio_client.dart';
import '../models/assigned_model.dart';
import '../models/case_model.dart';
import '../models/cases_with_pagination.dart';
import '../models/pagination_model.dart';

class CaseRepository {
  final DioClient _dio;

  CaseRepository(this._dio);

  Future<Either<Failure, CasesWithPaginationResponse>> getCases({
    int page = 1,
    Map<String, dynamic>? filters,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      if (filters != null) ...filters.map((k, v) => MapEntry(k, v.toString())),
    };

    final uri = Uri.parse(AppUrls.cases).replace(queryParameters: queryParams);
    final response = await _dio.get(uri.toString());

    return response.fold((failure) => Left(failure), (res) {
      try {
        final data = res.data['data'] as Map<String, dynamic>;
        final List<dynamic> casesJson = data['data'] ?? [];
        final cases = casesJson.map((e) => CaseModel.fromJson(e)).toList();

        final pagination = PaginationModel.fromJson(data['pagination']);
        return Right(
          CasesWithPaginationResponse(cases: cases, pagination: pagination),
        );
      } catch (e) {
        return Left(ServerFailure('Error parsing case list'));
      }
    });
  }

  Future<Either<Failure, CaseModel>> getCaseDetail(int id) async {
    final response = await _dio.get('${AppUrls.cases}$id/');

    return response.fold((failure) => Left(failure), (res) {
      try {
        final data = res.data['data'];
        return Right(CaseModel.fromJson(data));
      } catch (e) {
        return Left(ServerFailure('Error parsing case detail'));
      }
    });
  }

  Future<Either<Failure, CaseModel>> createCase(
    Map<String, dynamic> payload,
  ) async {
    final response = await _dio.post(AppUrls.cases, data: payload);

    return response.fold((failure) => Left(failure), (res) {
      try {
        final data = res.data['data'];
        return Right(CaseModel.fromJson(data));
      } catch (e) {
        return Left(ServerFailure('Error creating case'));
      }
    });
  }

  Future<Either<Failure, CaseModel>> updateCase(
    int id,
    Map<String, dynamic> payload,
  ) async {
    final response = await _dio.put('${AppUrls.cases}$id/', data: payload);

    return response.fold((failure) => Left(failure), (res) {
      try {
        final data = res.data['data'];
        return Right(CaseModel.fromJson(data));
      } catch (e) {
        return Left(ServerFailure('Error updating case'));
      }
    });
  }

  Future<Either<Failure, bool>> deleteCase(int id) async {
    final response = await _dio.delete('${AppUrls.cases}$id/');

    return response.fold((failure) => Left(failure), (_) => Right(true));
  }

  Future<Either<Failure, bool>> assignAccountToCase({
    required int caseId,
    required int accountId,
    required String role,
  }) async {
    final payload = {"case": caseId, "account": accountId, "role": role};
    final response = await _dio.post(
      '${AppUrls.cases}assign-user/',
      data: payload,
    );

    return response.fold((failure) => Left(failure), (_) => Right(true));
  }

  Future<Either<Failure, List<AssignedAccountModel>>> getAssignedAccounts(
    int caseId,
  ) async {
    final response = await _dio.get(
      '${AppUrls.cases}$caseId/assigned-accounts/',
    );

    return response.fold((failure) => Left(failure), (res) {
      try {
        final data = res.data['data'] as List;
        final accounts = data
            .map((e) => AssignedAccountModel.fromJson(e))
            .toList();
        return Right(accounts);
      } catch (e) {
        return Left(ServerFailure('Error parsing assigned accounts'));
      }
    });
  }

  Future<Either<Failure, bool>> updateAccountRole({
    required int caseId,
    required int accountId,
    required String role,
  }) async {
    final payload = {"role": role};
    final response = await _dio.put(
      '${AppUrls.cases}$caseId/assigned-accounts/$accountId/',
      data: payload,
    );

    return response.fold((failure) => Left(failure), (_) => Right(true));
  }

  Future<Either<Failure, bool>> deassignAccount({
    required int caseId,
    required int accountId,
  }) async {
    final response = await _dio.delete(
      '${AppUrls.cases}$caseId/assigned-accounts/$accountId/',
    );

    return response.fold((failure) => Left(failure), (_) => Right(true));
  }
}
