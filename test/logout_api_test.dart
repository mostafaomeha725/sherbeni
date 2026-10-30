import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:qrattendance/core/cache/preferences_storage.dart';
import 'package:qrattendance/core/di/services_locator.dart';
import 'package:qrattendance/core/enums/app_enums.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/logout_test_harness.dart';
import 'support/token_refresh_test_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late PreferencesStorage storage;

  setUp(() async => storage = await installFakePreferences());
  tearDown(() async => sl.reset());

  test(
    'POST logout with current bearer token, then clean only auth data',
    () async {
      final directory = await Directory.systemTemp.createTemp('logout_api_');
      Hive.init(directory.path);
      final history = await Hive.openBox<dynamic>('attendanceHistory');
      final attendance = await Hive.openBox<dynamic>('studentSessions');
      final searches = await Hive.openBox<dynamic>('pendingSearches');
      await history.put('history', {'recorded': true});
      await attendance.put('offline-attendance', {'pending': true});
      await searches.put('offline-search', {'query': 'dummy'});
      final adapter = FakeHttpAdapter(
        (_, _) async => jsonResponse(201, {
          'statusCode': 200,
          'message': 'Offline assistant logged out successfully',
        }),
      );
      final harness = createLogoutHarness(adapter);

      try {
        final result = await harness.repository.logout();

        expect(result.isRight(), isTrue);
        expect(adapter.requests, hasLength(1));
        expect(adapter.requests.single.options.method, 'POST');
        expect(adapter.requests.single.options.path, 'api/v1/mobile/logout');
        expect(adapter.requests.single.body, isNull);
        expect(
          adapter.requests.single.authorization,
          'Bearer dummy-old-access',
        );
        expect(storage.getUserToken(), isNull);
        expect(storage.getRefreshToken(), isNull);
        expect(storage.isUserAdmin(), isFalse);
        expect(storage.getUserSecretKey(), isNull);
        expect(storage.getUserId(), isNull);
        expect(storage.getUserType(), isNull);
        expect(storage.getRoleId(), isNull);
        expect(
          (await SharedPreferences.getInstance()).getBool('isEmailConfirmed'),
          isNull,
        );
        expect(storage.getBranchName(), isNull);
        expect(storage.getBranchId(), isNull);
        expect(storage.getUserName(), isNull);
        expect(storage.getUserProfile(), isNull);
        expect(storage.getString(key: PreferencesKeys.picture), isNull);
        expect(storage.getString(key: PreferencesKeys.email), isNull);
        expect(storage.getString(key: PreferencesKeys.phone), isNull);
        expect(storage.getString(key: PreferencesKeys.currentLanguage), 'ar');
        expect(storage.getString(key: PreferencesKeys.currentCurrency), 'EGP');
        expect(storage.getString(key: PreferencesKeys.fcmToken), 'dummy-fcm');
        expect(storage.getString(key: PreferencesKeys.uuid), 'dummy-device');
        expect(
          storage.getBoolean(key: PreferencesKeys.hasSeenOnBoarding),
          isTrue,
        );
        expect(history.get('history'), {'recorded': true});
        expect(attendance.get('offline-attendance'), {'pending': true});
        expect(searches.get('offline-search'), {'query': 'dummy'});

        await harness.networkService.getData(endPoint: '/after-logout');
        expect(adapter.requests.last.authorization, isNull);
      } finally {
        await Hive.close();
        await directory.delete(recursive: true);
      }
    },
  );

  test(
    'server rejection or unexpected status preserves the local session',
    () async {
      for (final status in [401, 403, 500, 200]) {
        await sl.reset();
        storage = await installFakePreferences();
        final adapter = FakeHttpAdapter(
          (_, _) async => jsonResponse(status, {
            'statusCode': 200,
            'message': 'not confirmed',
          }),
        );
        final harness = createLogoutHarness(adapter);

        final result = await harness.repository.logout();

        expect(
          result.isLeft(),
          isTrue,
          reason: 'HTTP $status must not log out',
        );
        expect(adapter.requests, hasLength(1));
        expect(storage.getUserToken(), 'dummy-old-access');
        expect(storage.getRefreshToken(), 'dummy-old-refresh');
      }
    },
  );

  test(
    'timeout and network errors do not claim success or clear credentials',
    () async {
      for (final failureType in [
        DioExceptionType.connectionTimeout,
        DioExceptionType.connectionError,
      ]) {
        await sl.reset();
        storage = await installFakePreferences();
        final adapter = FakeHttpAdapter((options, _) async {
          throw failureType == DioExceptionType.connectionTimeout
              ? DioException.connectionTimeout(
                  requestOptions: options,
                  timeout: const Duration(seconds: 1),
                )
              : DioException.connectionError(
                  requestOptions: options,
                  reason: 'dummy network error',
                );
        });
        final harness = createLogoutHarness(adapter);

        final result = await harness.repository.logout();

        expect(result.isLeft(), isTrue);
        expect(storage.getUserToken(), 'dummy-old-access');
        expect(storage.getRefreshToken(), 'dummy-old-refresh');
      }
    },
  );
}
