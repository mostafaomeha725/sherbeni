import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qrattendance/core/cache/preferences_storage.dart';
import 'package:qrattendance/core/di/services_locator.dart';
import 'package:qrattendance/core/network/endpoints.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/token_refresh_test_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late PreferencesStorage storage;

  setUp(() async => storage = await installFakePreferences());
  tearDown(() async => sl.reset());

  test(
    '419 refreshes once, saves rotated tokens and retries with the new token',
    () async {
      final harness = createRefreshHarness(
        mainAdapter: respondWith(419, {'message': 'expired'}),
        refreshAdapter: respondWith(200, {
          'data': {
            'access_token': 'dummy-new-access',
            'refresh_token': 'dummy-new-refresh',
          },
        }),
        retryAdapter: respondWith(200, {'ok': true}),
      );
      final response = await harness.client.get(EndPoints.mobileSubjects);

      expect(response.statusCode, 200);
      expect(harness.mainAdapter.requests, hasLength(1));
      expect(harness.refreshAdapter.requests, hasLength(1));
      expect(harness.retryAdapter.requests, hasLength(1));
      expect(harness.refreshAdapter.requests.single.options.method, 'POST');
      expect(
        harness.refreshAdapter.requests.single.options.path,
        EndPoints.refreshToken,
      );
      expect(
        harness.refreshAdapter.requests.single.body,
        contains('dummy-old-refresh'),
      );
      expect(
        harness.retryAdapter.requests.single.authorization,
        'Bearer dummy-new-access',
      );
      expect(storage.getUserToken(), 'dummy-new-access');
      expect(storage.getRefreshToken(), 'dummy-new-refresh');
      expect(harness.cleanupCount(), 0);
    },
  );

  test('refresh endpoint 419 is not recursively refreshed', () async {
    final harness = createRefreshHarness(
      mainAdapter: respondWith(419, {'message': 'expired'}),
      refreshAdapter: respondWith(200, {
        'data': {'access_token': 'unused'},
      }),
      retryAdapter: respondWith(200, {'unused': true}),
    );
    final error = await captureDioException(
      harness.client.post(EndPoints.refreshToken),
    );

    expect(error.response?.statusCode, 419);
    expect(harness.refreshAdapter.requests, isEmpty);
    expect(harness.retryAdapter.requests, isEmpty);
    expect(harness.cleanupCount(), 0);
  });

  test(
    'a retried request is attempted once even if it returns 419 again',
    () async {
      final harness = createRefreshHarness(
        mainAdapter: respondWith(419, {'message': 'expired'}),
        refreshAdapter: respondWith(200, {
          'data': {'access_token': 'dummy-new'},
        }),
        retryAdapter: respondWith(419, {'message': 'still expired'}),
      );
      final error = await captureDioException(harness.client.get('/resource'));

      expect(error.response?.statusCode, 419);
      expect(harness.mainAdapter.requests, hasLength(1));
      expect(harness.refreshAdapter.requests, hasLength(1));
      expect(harness.retryAdapter.requests, hasLength(1));
      expect(harness.cleanupCount(), 0);
    },
  );

  test(
    'retry HTTP 500 is propagated without clearing auth or logging out',
    () async {
      final harness = createRefreshHarness(
        mainAdapter: respondWith(419, {'message': 'expired'}),
        refreshAdapter: respondWith(200, {
          'data': {'access_token': 'dummy-new'},
        }),
        retryAdapter: respondWith(500, {'message': 'server failure'}),
      );
      final error = await captureDioException(harness.client.get('/resource'));

      expect(error.response?.statusCode, 500);
      expect(harness.retryAdapter.requests, hasLength(1));
      expect(storage.getUserToken(), 'dummy-new');
      expect(harness.cleanupCount(), 0);
    },
  );

  test(
    'retry timeout and network errors are propagated without logout',
    () async {
      for (final type in [
        DioExceptionType.connectionTimeout,
        DioExceptionType.connectionError,
      ]) {
        final harness = createRefreshHarness(
          mainAdapter: respondWith(419, {'message': 'expired'}),
          refreshAdapter: respondWith(200, {
            'data': {'access_token': 'dummy-new'},
          }),
          retryAdapter: FakeHttpAdapter((options, _) async {
            throw type == DioExceptionType.connectionTimeout
                ? DioException.connectionTimeout(
                    requestOptions: options,
                    timeout: const Duration(seconds: 1),
                  )
                : DioException.connectionError(
                    requestOptions: options,
                    reason: 'fake network failure',
                  );
          }),
        );
        final error = await captureDioException(
          harness.client.get('/resource'),
        );

        expect(error.type, type);
        expect(harness.retryAdapter.requests, hasLength(1));
        expect(harness.cleanupCount(), 0);
        await sl.reset();
        SharedPreferences.setMockInitialValues({});
        storage = await installFakePreferences();
      }
    },
  );

  test(
    'refresh server error is propagated without an assumed logout',
    () async {
      final harness = createRefreshHarness(
        mainAdapter: respondWith(419, {'message': 'expired'}),
        refreshAdapter: respondWith(503, {'message': 'unavailable'}),
        retryAdapter: respondWith(200, {'unused': true}),
      );
      final error = await captureDioException(harness.client.get('/resource'));

      expect(error.response?.statusCode, 503);
      expect(harness.retryAdapter.requests, isEmpty);
      expect(harness.cleanupCount(), 0);
    },
  );
}
