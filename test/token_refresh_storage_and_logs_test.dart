import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:qrattendance/core/cache/preferences_storage.dart';
import 'package:qrattendance/core/constants/strings.dart';
import 'package:qrattendance/core/di/services_locator.dart';
import 'package:qrattendance/core/enums/app_enums.dart';
import 'package:qrattendance/core/network/endpoints.dart';
import 'package:qrattendance/core/network/network_service.dart';

import 'support/token_refresh_test_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late PreferencesStorage storage;

  setUp(() async => storage = await installFakePreferences());
  tearDown(() async => sl.reset());

  test(
    'refresh rejection removes only credentials and preserves Hive queues',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'refresh_storage_',
      );
      Hive.init(directory.path);
      final attendance = await Hive.openBox<dynamic>('studentSessions');
      final searches = await Hive.openBox<dynamic>('pendingSearches');
      final history = await Hive.openBox<dynamic>('attendanceHistory');
      await attendance.put('offline-attendance', {'state': 'pending'});
      await searches.put('offline-search', {'query': 'dummy'});
      await history.put('history-entry', {'state': 'recorded'});
      final harness = createRefreshHarness(
        mainAdapter: respondWith(419, {'message': 'expired'}),
        refreshAdapter: respondWith(401, {'message': 'invalid refresh'}),
        retryAdapter: respondWith(200, {'unused': true}),
      );

      try {
        final error = await captureDioException(
          harness.client.get('/resource'),
        );
        expect(error.response?.statusCode, 419);
        expect(harness.retryAdapter.requests, isEmpty);
        expect(harness.cleanupCount(), 1);
        expect(storage.getUserToken(), isNull);
        expect(storage.getRefreshToken(), isNull);
        expect(storage.getString(key: PreferencesKeys.currentLanguage), 'ar');
        expect(storage.getString(key: PreferencesKeys.currentCurrency), 'EGP');
        expect(storage.getString(key: PreferencesKeys.fcmToken), 'dummy-fcm');
        expect(storage.getString(key: PreferencesKeys.uuid), 'dummy-device');
        expect(
          storage.getBoolean(key: PreferencesKeys.hasSeenOnBoarding),
          isTrue,
        );
        expect(storage.isUserAdmin(), isTrue);
        expect(storage.getUserProfile(), '{"name":"Dummy"}');
        expect(attendance.get('offline-attendance'), {'state': 'pending'});
        expect(searches.get('offline-search'), {'query': 'dummy'});
        expect(history.get('history-entry'), {'state': 'recorded'});
      } finally {
        await Hive.close();
        await directory.delete(recursive: true);
      }
    },
  );

  test(
    'requests after token deletion omit a stale default Authorization header',
    () async {
      final adapter = respondWith(200, {'ok': true});
      final dio = Dio(
        BaseOptions(
          baseUrl: AppStrings.baseUrl,
          headers: {'Authorization': 'Bearer dummy-stale-access'},
        ),
      )..httpClientAdapter = adapter;
      final service = NetworkService(dio);
      await storage.deleteUserToken();

      await service.getData(endPoint: '/resource');

      expect(adapter.requests.single.authorization, isNull);
    },
  );

  test(
    'HTTP logger omits headers and bodies and Chucker is not attached',
    () async {
      final service = NetworkService(Dio());
      final logger = service.dio.interceptors
          .whereType<PrettyDioLogger>()
          .single;

      expect(logger.requestHeader, isFalse);
      expect(logger.requestBody, isFalse);
      expect(logger.responseBody, isFalse);
      expect(logger.error, isFalse);
      expect(
        service.dio.interceptors.any(
          (interceptor) =>
              interceptor.runtimeType.toString() == 'ChuckerDioInterceptor',
        ),
        isFalse,
      );

      final loggedLines = <String>[];
      await runZoned(
        () async {
          final loggedService = NetworkService(Dio())
            ..dio.httpClientAdapter = respondWith(200, {
              'access_token': 'dummy-response-token',
            });
          await loggedService.dio.post(
            '/resource',
            data: {
              'password': 'dummy-password',
              'refresh_token': 'dummy-refresh-token',
            },
          );
        },
        zoneSpecification: ZoneSpecification(
          print: (_, _, _, line) => loggedLines.add(line),
        ),
      );
      final logs = loggedLines.join('\n');
      expect(logs, isNot(contains('dummy-old-access')));
      expect(logs, isNot(contains('dummy-password')));
      expect(logs, isNot(contains('dummy-refresh-token')));
      expect(logs, isNot(contains('dummy-response-token')));
    },
  );

  test(
    'refresh request retains the existing endpoint and request fields',
    () async {
      final harness = createRefreshHarness(
        mainAdapter: respondWith(419, {'message': 'expired'}),
        refreshAdapter: respondWith(200, {
          'data': {'access_token': 'dummy-access'},
        }),
        retryAdapter: respondWith(200, {'ok': true}),
      );

      await harness.client.get(EndPoints.mobileSubjects);

      expect(harness.refreshAdapter.requests.single.options.method, 'POST');
      expect(
        harness.refreshAdapter.requests.single.options.path,
        EndPoints.refreshToken,
      );
      expect(
        harness.refreshAdapter.requests.single.body,
        contains('refreshToken'),
      );
      expect(
        harness.refreshAdapter.requests.single.body,
        contains('dummy-old-refresh'),
      );
    },
  );
}
