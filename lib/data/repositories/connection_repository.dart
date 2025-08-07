import 'package:dartz/dartz.dart';

import '../../core/constants/app_urls.dart';
import '../../core/error/failure.dart';
import '../../core/network/dio_client.dart';
import '../models/invitation_model.dart';
import '../models/space_account_model.dart';

class ConnectionsRepository {
  final DioClient _dioClient;

  ConnectionsRepository(this._dioClient);

  Future<Either<Failure, List<SpaceAccountModel>>> getMyFollowers() async {
    final response = await _dioClient.get(AppUrls.myFollowers);
    return response.fold((failure) => Left(failure), (res) {
      try {
        final data = res.data as Map<String, dynamic>;
        final list = data['data'] as List<dynamic>;
        final followers = list
            .map((item) => SpaceAccountModel.fromJson(item))
            .toList();
        return Right(followers);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    });
  }

  Future<Either<Failure, List<SpaceAccountModel>>> getMyFollowing() async {
    final response = await _dioClient.get(AppUrls.myFollowing);
    return response.fold((failure) => Left(failure), (res) {
      try {
        final data = res.data as Map<String, dynamic>;
        final list = data['data'] as List<dynamic>;
        final connections = list
            .map((item) => SpaceAccountModel.fromJson(item))
            .toList();
        return Right(connections);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    });
  }

  Future<Either<Failure, InvitationResponse>> sendDirectInvitations(
    SendInvitationRequest request,
  ) async {
    print(request.toJson());
    try {
      final response = await _dioClient.post(
        AppUrls.sendDirectInvitation,
        data: request.toJson(),
      );

      return response.fold((failure) => Left(failure), (res) {
        try {
          final data = res.data as Map<String, dynamic>;
          return Right(InvitationResponse.fromJson(data));
        } catch (e) {
          return Left(ServerFailure('Failed to parse invitation response: $e'));
        }
      });
    } catch (e) {
      return Left(ServerFailure('Failed to send invitations: $e'));
    }
  }
}
