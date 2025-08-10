import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
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
        debugPrint('[CASES] URL: ${uri.toString()}');
        debugPrint('[CASES] Full response: ${res.data}');

        // Check if response has the expected structure
        if (res.data == null) {
          return Left(ServerFailure('Empty response data'));
        }

        if (res.data['data'] == null) {
          return Left(ServerFailure('Missing data field in response'));
        }

        final data = res.data['data'] as Map<String, dynamic>;
        debugPrint('[CASES] Inner data: $data');

        if (data['data'] == null) {
          return Left(ServerFailure('Missing cases array in data'));
        }

        final List<dynamic> casesJson = data['data'] as List;
        debugPrint('[CASES] Cases count: ${casesJson.length}');

        final cases = casesJson.map((e) {
          debugPrint('[CASES] Parsing case: $e');
          return CaseModel.fromJson(e as Map<String, dynamic>);
        }).toList();

        if (data['pagination'] == null) {
          return Left(ServerFailure('Missing pagination in data'));
        }

        final pagination = PaginationModel.fromJson(
          data['pagination'] as Map<String, dynamic>,
        );
        debugPrint('[CASES] Pagination: ${data['pagination']}');

        return Right(
          CasesWithPaginationResponse(cases: cases, pagination: pagination),
        );
      } catch (e, stackTrace) {
        debugPrint('[CASES] Error parsing: $e');
        debugPrint('[CASES] Stack trace: $stackTrace');
        return Left(ServerFailure('Error parsing case list: $e'));
      }
    });
  }

  Future<Either<Failure, CaseModel>> getCaseDetail(
    int id, {
    Map<String, dynamic>? queryParams,
  }) async {
    final response = await _dio.get(
      '${AppUrls.cases}$id/',
      queryParameters: queryParams,
    );

    return response.fold((failure) => Left(failure), (res) {
      try {
        debugPrint('[CASE_DETAIL] Full response: ${res.data}');

        // Check if response has the expected structure
        if (res.data == null) {
          return Left(ServerFailure('Empty response data'));
        }

        if (res.data['data'] == null) {
          return Left(ServerFailure('Missing data field in response'));
        }

        // For case details, the structure might be different
        // Check if it's nested like the list endpoint
        final outerData = res.data['data'];
        final caseData =
            outerData is Map<String, dynamic> && outerData.containsKey('data')
            ? outerData['data'] // Nested structure
            : outerData; // Direct structure

        debugPrint('[CASE_DETAIL] Case data: $caseData');

        return Right(CaseModel.fromJson(caseData as Map<String, dynamic>));
      } catch (e, stackTrace) {
        debugPrint('[CASE_DETAIL] Error parsing: $e');
        debugPrint('[CASE_DETAIL] Stack trace: $stackTrace');
        return Left(ServerFailure('Error parsing case detail: $e'));
      }
    });
  }

  Future<Either<Failure, CaseModel>> createCase(
    Map<String, dynamic> payload, {
    Map<String, dynamic>? queryParams,
  }) async {
    final response = await _dio.post(
      AppUrls.cases,
      data: payload,
      queryParameters: queryParams,
    );

    return response.fold((failure) => Left(failure), (res) {
      try {
        debugPrint('[CREATE_CASE] Full response: ${res.data}');

        if (res.data == null || res.data['data'] == null) {
          return Left(ServerFailure('Invalid response structure'));
        }

        // Handle nested structure like other endpoints
        final outerData = res.data['data'];
        final caseData =
            outerData is Map<String, dynamic> && outerData.containsKey('data')
            ? outerData['data'] // Nested structure
            : outerData; // Direct structure

        debugPrint('[CREATE_CASE] Case data: $caseData');

        return Right(CaseModel.fromJson(caseData as Map<String, dynamic>));
      } catch (e, stackTrace) {
        debugPrint('[CREATE_CASE] Error parsing: $e');
        debugPrint('[CREATE_CASE] Stack trace: $stackTrace');
        return Left(ServerFailure('Error creating case: $e'));
      }
    });
  }

  Future<Either<Failure, CaseModel>> updateCase(
    int id,
    Map<String, dynamic> payload, {
    Map<String, dynamic>? queryParams,
  }) async {
    final response = await _dio.put(
      '${AppUrls.cases}$id/',
      data: payload,
      queryParameters: queryParams,
    );

    return response.fold((failure) => Left(failure), (res) {
      try {
        debugPrint('[UPDATE_CASE] Full response: ${res.data}');

        if (res.data == null || res.data['data'] == null) {
          return Left(ServerFailure('Invalid response structure'));
        }

        // Handle nested structure like other endpoints
        final outerData = res.data['data'];
        final caseData =
            outerData is Map<String, dynamic> && outerData.containsKey('data')
            ? outerData['data'] // Nested structure
            : outerData; // Direct structure

        debugPrint('[UPDATE_CASE] Case data: $caseData');

        return Right(CaseModel.fromJson(caseData as Map<String, dynamic>));
      } catch (e, stackTrace) {
        debugPrint('[UPDATE_CASE] Error parsing: $e');
        debugPrint('[UPDATE_CASE] Stack trace: $stackTrace');
        return Left(ServerFailure('Error updating case: $e'));
      }
    });
  }

  Future<Either<Failure, bool>> deleteCase(
    int id, {
    Map<String, dynamic>? queryParams,
  }) async {
    final response = await _dio.delete(
      '${AppUrls.cases}$id/',
      queryParameters: queryParams,
    );

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
