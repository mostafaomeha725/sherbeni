import 'dart:developer';

import 'package:qrattendance/core/error/failure.dart';
import 'package:qrattendance/core/network/endpoints.dart';
import 'package:qrattendance/core/network/network_service.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({
    required String username,
    required String password,
    required String deviceId,
  });

  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final NetworkService networkService;

  AuthRemoteDataSourceImpl(this.networkService);

  @override
  Future<void> logout() async {
    final result = await networkService.postData(
      endPoint: EndPoints.mobileLogout,
      expectedStatusCode: 201,
    );

    result.fold((failure) => throw failure, (response) {
      if (response is Map && response['statusCode'] == 200) return;
      final bodyStatusCode = response is Map ? response['statusCode'] : null;
      log(
        'Logout response parsing rejected: '
        'httpStatus=201 (expected status validated); '
        'bodyStatusCode=$bodyStatusCode; '
        'responseType=${response.runtimeType}.',
        name: 'AuthRemoteDataSource',
      );
      throw const ServerFailure(
        message: 'Logout response was not confirmed by the server.',
      );
    });
  }

  @override
  Future<UserModel> login({
    required String username,
    required String password,
    required String deviceId,
  }) async {
    final response = await networkService.postData(
      endPoint: EndPoints.mobileLogin,
      data: {"email": username, "password": password},
    );

    return response.fold((failure) => throw failure, (data) {
      // The API returns status 201 with body. We parse it into UserModel
      // Fallback token extraction in case the API nests the token differently
      return UserModel.fromJson(data);
    });
  }
}
