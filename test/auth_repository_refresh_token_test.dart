import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:qrattendance/core/cache/preferences_storage.dart';
import 'package:qrattendance/features/auth/data/data_sources/auth_remote_data_source.dart';
import 'package:qrattendance/features/auth/data/models/user_model.dart';
import 'package:qrattendance/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeAuthRemoteDataSource implements AuthRemoteDataSource {
  FakeAuthRemoteDataSource(this.userModel);

  final UserModel userModel;

  @override
  Future<UserModel> login({
    required String username,
    required String password,
    required String deviceId,
  }) async => userModel;

  @override
  Future<void> logout() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final serviceLocator = GetIt.instance;
  late PreferencesStorage preferencesStorage;

  setUp(() async {
    await serviceLocator.reset();
    SharedPreferences.setMockInitialValues({});
    preferencesStorage = PreferencesStorage(
      await SharedPreferences.getInstance(),
    );
    serviceLocator.registerSingleton<PreferencesStorage>(preferencesStorage);
  });

  tearDown(() async {
    await serviceLocator.reset();
  });

  test(
    'login parses and persists the refresh_token from the API response',
    () async {
      const response = <String, dynamic>{
        'data': {
          'user': {
            'id': 42,
            'name': 'Test User',
            'email': 'test@example.invalid',
            'role': 'teacher',
          },
          'token': 'dummy-access-token',
          'refresh_token': 'dummy-refresh-token',
        },
      };
      final userModel = UserModel.fromJson(response);
      final repository = AuthRepositoryImpl(
        FakeAuthRemoteDataSource(userModel),
      );

      final result = await repository.login(
        username: 'test@example.invalid',
        password: 'dummy-password',
        deviceId: 'dummy-device-id',
      );

      expect(result.isRight(), isTrue);
      expect(userModel.refreshToken, 'dummy-refresh-token');
      expect(preferencesStorage.getUserToken(), 'dummy-access-token');
      expect(preferencesStorage.getRefreshToken(), 'dummy-refresh-token');
    },
  );
}
