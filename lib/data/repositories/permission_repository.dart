import 'package:dartz/dartz.dart';
import '../../core/error/failure.dart';
import '../../core/network/dio_client.dart';
import '../models/permission_model.dart';

class PermissionRepository {
  final DioClient _dioClient;

  PermissionRepository(this._dioClient);

  Future<Either<Failure, UserPermissionsModel>> checkPermissions({
    int? spaceId,
    int? caseId,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (spaceId != null) queryParams['space_id'] = spaceId;
      if (caseId != null) queryParams['case_id'] = caseId;

      final response = await _dioClient.get(
        '/check-permissions/',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      return response.fold((failure) => Left(failure), (res) {
        try {
          // Handle the backend response structure
          if (res.data['type'] == 'success') {
            final data = res.data['data'] as Map<String, dynamic>;
            return Right(UserPermissionsModel.fromJson(data));
          } else {
            return Left(
              ServerFailure(res.data['message'] ?? 'Permission check failed'),
            );
          }
        } catch (e) {
          return Left(ServerFailure('Error parsing permissions: $e'));
        }
      });
    } catch (e) {
      return Left(ServerFailure('Error checking permissions: $e'));
    }
  }
}
