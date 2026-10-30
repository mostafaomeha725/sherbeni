import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:qrattendance/core/cache/preferences_storage.dart';
import 'package:qrattendance/core/constants/strings.dart';
import 'package:qrattendance/core/di/services_locator.dart';
import 'package:qrattendance/core/network/authorization_interceptor.dart';
import 'package:qrattendance/core/network/token_refresh_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef FakeRequestHandler =
    Future<ResponseBody> Function(RequestOptions options, String? body);

class FakeHttpRequest {
  FakeHttpRequest(this.options, this.body)
    : authorization = options.headers.entries
          .where((entry) => entry.key.toLowerCase() == 'authorization')
          .map((entry) => entry.value?.toString())
          .firstOrNull;

  final RequestOptions options;
  final String? body;
  final String? authorization;
}

class FakeHttpAdapter implements HttpClientAdapter {
  FakeHttpAdapter(this.handler);

  final FakeRequestHandler handler;
  final requests = <FakeHttpRequest>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final bytes = <int>[];
    if (requestStream != null) {
      await for (final chunk in requestStream) {
        bytes.addAll(chunk);
      }
    }
    final body = requestStream == null ? null : utf8.decode(bytes);
    requests.add(FakeHttpRequest(options, body));
    return handler(options, body);
  }

  @override
  void close({bool force = false}) {}
}

class RefreshTestHarness {
  const RefreshTestHarness({
    required this.client,
    required this.mainAdapter,
    required this.refreshAdapter,
    required this.retryAdapter,
    required this.cleanupCount,
  });

  final Dio client;
  final FakeHttpAdapter mainAdapter;
  final FakeHttpAdapter refreshAdapter;
  final FakeHttpAdapter retryAdapter;
  final int Function() cleanupCount;
}

ResponseBody jsonResponse(int statusCode, Object? body) =>
    ResponseBody.fromString(
      jsonEncode(body),
      statusCode,
      headers: {
        Headers.contentTypeHeader: ['application/json; charset=utf-8'],
      },
    );

FakeHttpAdapter respondWith(int statusCode, Object? body) =>
    FakeHttpAdapter((_, _) async => jsonResponse(statusCode, body));

Future<PreferencesStorage> installFakePreferences({
  Map<String, Object> initialValues = const {
    'userToken': 'dummy-old-access',
    'refreshToken': 'dummy-old-refresh',
    'currentLanguage': 'ar',
    'currentCurrency': 'EGP',
    'fcmToken': 'dummy-fcm',
    'uuid': 'dummy-device',
    'name': 'Dummy User',
    'picture': 'dummy-picture',
    'email': 'dummy@example.invalid',
    'phone': '0000000000',
    'hasSeenOnBoarding': true,
    'userIsAdmin': true,
    'userSecretKey': 'dummy-secret',
    'userId': 12,
    'userType': 3,
    'roleId': 1,
    'isEmailConfirmed': true,
    'branchName': 'Dummy Branch',
    'branchId': 4,
    'userProfile': '{"name":"Dummy"}',
  },
}) async {
  await GetIt.instance.reset();
  SharedPreferences.setMockInitialValues(initialValues);
  final storage = PreferencesStorage(await SharedPreferences.getInstance());
  sl.registerSingleton<PreferencesStorage>(storage);
  return storage;
}

RefreshTestHarness createRefreshHarness({
  required FakeHttpAdapter mainAdapter,
  required FakeHttpAdapter refreshAdapter,
  required FakeHttpAdapter retryAdapter,
}) {
  var cleanupCount = 0;
  final refreshDio = Dio(BaseOptions(baseUrl: AppStrings.baseUrl))
    ..httpClientAdapter = refreshAdapter;
  sl.registerSingleton<TokenRefreshService>(
    TokenRefreshService(sl<PreferencesStorage>(), dio: refreshDio),
  );
  final interceptor = AuthorizationInterceptor(
    retryDioFactory: () =>
        Dio(BaseOptions(baseUrl: AppStrings.baseUrl))
          ..httpClientAdapter = retryAdapter,
    onSessionExpired: () async => cleanupCount++,
  );
  final client = Dio(BaseOptions(baseUrl: AppStrings.baseUrl))
    ..httpClientAdapter = mainAdapter
    ..interceptors.add(interceptor);
  return RefreshTestHarness(
    client: client,
    mainAdapter: mainAdapter,
    refreshAdapter: refreshAdapter,
    retryAdapter: retryAdapter,
    cleanupCount: () => cleanupCount,
  );
}

Future<DioException> captureDioException(Future<dynamic> request) async {
  try {
    await request;
  } on DioException catch (error) {
    return error;
  }
  throw StateError('Expected request to throw DioException.');
}
