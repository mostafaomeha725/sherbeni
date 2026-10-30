import 'package:dio/dio.dart';
import 'package:qrattendance/core/constants/strings.dart';
import 'package:qrattendance/core/di/services_locator.dart';
import 'package:qrattendance/core/network/network_service.dart';
import 'package:qrattendance/core/network/token_refresh_service.dart';
import 'package:qrattendance/features/auth/data/data_sources/auth_remote_data_source.dart';
import 'package:qrattendance/features/auth/data/repositories/auth_repository_impl.dart';

import 'token_refresh_test_harness.dart';

class LogoutTestHarness {
  const LogoutTestHarness({
    required this.repository,
    required this.networkService,
    required this.adapter,
    required this.refreshAdapter,
    required this.retryAdapter,
  });

  final AuthRepositoryImpl repository;
  final NetworkService networkService;
  final FakeHttpAdapter adapter;
  final FakeHttpAdapter refreshAdapter;
  final FakeHttpAdapter retryAdapter;
}

LogoutTestHarness createLogoutHarness(
  FakeHttpAdapter adapter, {
  FakeHttpAdapter? refreshAdapter,
  FakeHttpAdapter? retryAdapter,
}) {
  final effectiveRefreshAdapter = refreshAdapter ?? respondWith(401, {});
  final effectiveRetryAdapter = retryAdapter ?? respondWith(419, {});
  final refreshDio = Dio(BaseOptions(baseUrl: AppStrings.baseUrl))
    ..httpClientAdapter = effectiveRefreshAdapter;
  sl.registerSingleton<TokenRefreshService>(
    TokenRefreshService(sl(), dio: refreshDio),
  );
  final dio = Dio(BaseOptions(baseUrl: AppStrings.baseUrl))
    ..httpClientAdapter = adapter;
  final networkService = NetworkService(
    dio,
    retryDioFactory: () =>
        Dio(BaseOptions(baseUrl: AppStrings.baseUrl))
          ..httpClientAdapter = effectiveRetryAdapter,
  );
  sl.registerSingleton<NetworkService>(networkService);
  return LogoutTestHarness(
    repository: AuthRepositoryImpl(AuthRemoteDataSourceImpl(networkService)),
    networkService: networkService,
    adapter: adapter,
    refreshAdapter: effectiveRefreshAdapter,
    retryAdapter: effectiveRetryAdapter,
  );
}
