import 'package:dartz/dartz.dart';
import 'package:new_ovacs/core/constants/app_urls.dart';
import 'package:new_ovacs/core/error/failure.dart';
import 'package:new_ovacs/core/network/dio_client.dart';

import '../models/client_model.dart';
import '../models/client_with_pagenation_response.dart';
import '../models/pagination_model.dart';

class ClientRepository {
  final DioClient _dioClient;

  ClientRepository(this._dioClient);

  Future<Either<Failure, ClientModel>> createClient({
    required String name,
    required String email,
    required String mobile,
    required int countryId,
  }) async {
    try {
      final response = await _dioClient.post(
        AppUrls.clients,
        data: {
          'name': name,
          'email': email,
          'mobile': mobile,
          'country_id': countryId,
        },
      );

      return response.fold((failure) => Left(failure), (res) {
        final data = res.data['data'];
        return Right(ClientModel.fromJson(data));
      });
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  Future<Either<Failure, ClientsWithPaginationResponse>> getClients({
    int page = 1,
  }) async {
    final response = await _dioClient.get('${AppUrls.clients}?page=$page');

    return response.fold((failure) => Left(failure), (res) {
      try {
        final data = res.data['data'] as Map<String, dynamic>;
        final List<ClientModel> clients = (data['data'] as List)
            .map((e) => ClientModel.fromJson(e))
            .toList();

        final pagination = PaginationModel.fromJson(data['pagination']);
        return Right(
          ClientsWithPaginationResponse(
            clients: clients,
            pagination: pagination,
          ),
        );
      } catch (e) {
        return Left(ServerFailure('Error parsing client list'));
      }
    });
  }

  Future<Either<Failure, ClientModel>> getClientDetail(int id) async {
    final response = await _dioClient.get('${AppUrls.clients}$id/');

    return response.fold((failure) => Left(failure), (res) {
      try {
        final data = res.data['data'];
        return Right(ClientModel.fromJson(data));
      } catch (e) {
        return Left(ServerFailure('Error parsing client details'));
      }
    });
  }

  Future<Either<Failure, ClientModel>> updateClient({
    required int id,
    required String name,
    required String email,
    required String mobile,
    required int countryId,
  }) async {
    final response = await _dioClient.put(
      '${AppUrls.clients}$id/',
      data: {
        'name': name,
        'email': email,
        'mobile': mobile,
        'country_id': countryId,
      },
    );

    return response.fold((failure) => Left(failure), (res) {
      try {
        final data = res.data['data'];
        return Right(ClientModel.fromJson(data));
      } catch (e) {
        return Left(ServerFailure('Error parsing updated client'));
      }
    });
  }

  Future<Either<Failure, bool>> deleteClient(int id) async {
    final response = await _dioClient.delete('${AppUrls.clients}$id/');

    return response.fold((failure) => Left(failure), (_) => Right(true));
  }

  Future<Either<Failure, ClientsWithPaginationResponse>> getClientsBySearch({
    dynamic page = 1,
    String? search,
    String? ordering,
    String? country,
  }) async {
    try {
      final queryParams = <String, String>{};

      if (page != null) queryParams['page'] = page.toString();
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (ordering != null && ordering.isNotEmpty) {
        queryParams['ordering'] = ordering;
      }
      if (country != null && country.isNotEmpty) {
        queryParams['country'] = country;
      }

      final queryString = Uri(queryParameters: queryParams).query;
      final url = '${AppUrls.clients}?$queryString';

      final response = await _dioClient.get(url);

      return response.fold((failure) => Left(failure), (res) {
        final responseData = res.data['data'];

        try {
          final rawClients = responseData['data'];
          if (rawClients is! List) {
            throw const FormatException('Expected a list of clients');
          }

          final clients = rawClients
              .map((e) => ClientModel.fromJson(e))
              .toList();
          final pagination = PaginationModel.fromJson(
            responseData['pagination'],
          );

          return Right(
            ClientsWithPaginationResponse(
              clients: clients,
              pagination: pagination,
            ),
          );
        } catch (e) {
          return Left(ServerFailure('Parsing error: ${e.toString()}'));
        }
      });
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }
}
