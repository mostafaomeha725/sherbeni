import 'package:qrattendance/core/network/endpoints.dart';
import 'package:qrattendance/core/network/network_service.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({
    required String username,
    required String password,
    required String deviceId,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final NetworkService networkService;

  AuthRemoteDataSourceImpl(this.networkService);

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
