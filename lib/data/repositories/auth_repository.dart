import 'package:dartz/dartz.dart';
import 'package:new_ovacs/core/network/dio_client.dart';
import 'package:new_ovacs/data/models/country_model.dart';
import 'package:new_ovacs/data/models/user_model.dart';
import '../../core/constants/app_urls.dart';
import '../../core/error/failure.dart';
import '../models/login_response.dart';

class AuthRepository {
  final DioClient _dioClient;
  AuthRepository(this._dioClient);

  Future<Either<Failure, Unit>> register({
    required String name,
    required String email,
    required String mobile,
    required String password,
    required int countryId,
  }) async {
    try {
      final data = {
        "name": name,
        "email": email,
        "mobile": mobile,
        "password": password,
        "country_id": countryId,
      };

      final response = await _dioClient.post(AppUrls.registerUrl, data: data);
      return response.fold((failure) => Left(failure), (_) => Right(unit));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, Unit>> confirmAccount({
    required String email,
    required String confirmationCode,
  }) async {
    try {
      final data = {"email": email, "confirmation_code": confirmationCode};
      final response = await _dioClient.post(
        AppUrls.confirmAccountUrl,
        data: data,
      );
      return response.fold((failure) => Left(failure), (_) => Right(unit));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, LoginResponse>> login({
    required String email,
    required String password,
  }) async {
    try {
      final data = {"email": email, "password": password};
      final response = await _dioClient.post(AppUrls.loginUrl, data: data);
      return response.fold((failure) => Left(failure), (res) {
        final loginResponse = LoginResponse.fromJson(res.data['data']);
        return Right(loginResponse);
      });
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, UserModel>> getAccountInfo() async {
    try {
      final response = await _dioClient.get(AppUrls.accountInfoUrl);
      return response.fold(
        (failure) => Left(failure),
        (res) =>
            Right(UserModel.fromJson(res.data['data'] as Map<String, dynamic>)),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, List<CountryModel>>> getCountries() async {
    try {
      final response = await _dioClient.get(AppUrls.countriesUrl);
      return response.fold((failure) => Left(failure), (res) {
        final List<dynamic> data = res.data['data'];
        final countries = data
            .map((json) => CountryModel.fromJson(json as Map<String, dynamic>))
            .toList();
        return Right(countries);
      });
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> refreshToken(
    String refreshToken,
  ) async {
    try {
      final data = {"refresh": refreshToken};
      final response = await _dioClient.post(
        AppUrls.tokenRefreshUrl,
        data: data,
      );
      return response.fold((failure) => Left(failure), (res) {
        final data = res.data['data'];
        return Right(data);
      });
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, Unit>> passwordResetRequest(String email) async {
    try {
      final data = {"email": email};
      final response = await _dioClient.post(
        AppUrls.passwordResetRequestUrl,
        data: data,
      );
      return response.fold((failure) => Left(failure), (_) => Right(unit));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, Unit>> passwordResetConfirm({
    required String email,
    required String token,
    required String newPassword,
  }) async {
    try {
      final data = {
        "email": email,
        "token": token,
        "new_password": newPassword,
      };
      final response = await _dioClient.post(
        AppUrls.passwordResetConfirmUrl,
        data: data,
      );
      return response.fold((failure) => Left(failure), (_) => Right(unit));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<Either<Failure, Unit>> resendConfirmationCode(String email) async {
    try {
      final data = {"email": email};
      final response = await _dioClient.post(
        AppUrls.resendConfirmationCodeUrl,
        data: data,
      );
      return response.fold((failure) => Left(failure), (_) => Right(unit));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
