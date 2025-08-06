import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:new_ovacs/data/models/account_model.dart';

import '../../core/constants/app_urls.dart';
import '../../core/error/failure.dart';
import '../../core/network/dio_client.dart';
import '../models/all_connections_response.dart';
import '../models/connection_request_model.dart';

class ConnectionsRepository {
  final DioClient _dioClient;

  ConnectionsRepository(this._dioClient);

  Future<Either<Failure, bool>> sendConnectionRequest({
    required int receiverAccountId,
    required String receiverAccountName,
  }) async {
    final body = {
      "receiver_account_id": receiverAccountId,
      "receiver_account_name": receiverAccountName,
    };

    final response = await _dioClient.post(
      AppUrls.sendConnectionRequest,
      data: body,
    );

    return response.fold((failure) => Left(failure), (_) => const Right(true));
  }

  Future<Either<Failure, List<ConnectionRequestModel>>> getReceivedRequests() async {
    final response = await _dioClient.get(AppUrls.connectionRequestsReceived);
    return response.fold((failure) => Left(failure), (res) {
      try {
        final data = res.data as Map<String, dynamic>;
        final list = data['data'] as List;
        return Right(
          list.map((value) => ConnectionRequestModel.fromJson(value)).toList(),
        );
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    });
  }

  Future<Either<Failure, List<ConnectionRequestModel>>> getSentRequests() async {
    final response = await _dioClient.get(AppUrls.connectionRequestsSent);
    return response.fold((failure) => Left(failure), (res) {
      try {
        final data = res.data as Map<String, dynamic>;
        final list = data['data'] as List;
        return Right(
          list.map((value) => ConnectionRequestModel.fromJson(value)).toList(),
        );
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    });
  }

  Future<Either<Failure, bool>> respondToConnectionRequest({
    required int senderAccountId,
    required String status,
    required int requestId,
    required String action,
  }) async {
    final body = {
      "id": senderAccountId,
      "status": status,
      "request_id": requestId,
      "action": action,
    };

    final response = await _dioClient.put(
      AppUrls.respondConnectionRequest,
      data: body,
    );

    return response.fold((failure) => Left(failure), (_) => const Right(true));
  }

  Future<Either<Failure, AllConnectionsResponse>> getAllConnections() async {
    final response = await _dioClient.get(AppUrls.allConnections);
    return response.fold((failure) => Left(failure), (res) {
      try {
        final data = res.data as Map<String, dynamic>;
        return Right(AllConnectionsResponse.fromJson(data['data']));
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    });
  }

  Future<Either<Failure, List<AccountModel>>> getAssignedCasesForConnection(
    int connectionId,
  ) async {
    final url =
        '${AppUrls.connectionAssignedCases}$connectionId/assigned-cases/';
    final response = await _dioClient.get(url);
    return _handleListResponse(response);
  }

  Future<Either<Failure, List<AccountModel>>> getNonConnections() async {
    final response = await _dioClient.get(AppUrls.nonConnections);
    return response.fold((failure) => Left(failure), (res) {
      try {
        final data = res.data as Map<String, dynamic>;
        final list = data['data'] as List;
        return Right(
          list.map((value) => AccountModel.fromJson(value)).toList(),
        );
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    });
  }

  Future<Either<Failure, List<AccountModel>>> _handleListResponse(
    Either<Failure, Response> response,
  ) async {
    return response.fold((failure) => Left(failure), (res) {
      try {
        final data = res.data as Map<String, dynamic>;
        final list = data['data'] as List<AccountModel>;
        return Right(list);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    });
  }
}
