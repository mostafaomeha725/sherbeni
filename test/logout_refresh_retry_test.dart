import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:qrattendance/core/cache/preferences_storage.dart';
import 'package:qrattendance/core/di/services_locator.dart';
import 'package:qrattendance/core/network/endpoints.dart';
import 'package:qrattendance/features/auth/domain/use_cases/logout_use_case.dart';
import 'package:qrattendance/features/auth/presentation/cubit/logout_cubit/logout_cubit.dart';
import 'package:qrattendance/features/auth/presentation/cubit/logout_cubit/logout_state.dart';

import 'support/logout_test_harness.dart';
import 'support/token_refresh_test_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late PreferencesStorage storage;

  setUp(() async => storage = await installFakePreferences());
  tearDown(() async => sl.reset());

  test(
    'Logout 419 refreshes once then retries logout with the new token',
    () async {
      final harness = createLogoutHarness(
        respondWith(419, {'message': 'Token expired'}),
        refreshAdapter: respondWith(200, {
          'data': {
            'access_token': 'dummy-new-access',
            'refresh_token': 'dummy-new-refresh',
          },
        }),
        retryAdapter: respondWith(201, {'statusCode': 200}),
      );

      final result = await harness.repository.logout();

      expect(result.isRight(), isTrue);
      expect(harness.adapter.requests, hasLength(1));
      expect(
        harness.adapter.requests.single.authorization,
        'Bearer dummy-old-access',
      );
      expect(harness.refreshAdapter.requests, hasLength(1));
      expect(harness.refreshAdapter.requests.single.options.method, 'POST');
      expect(
        harness.refreshAdapter.requests.single.options.path,
        EndPoints.refreshToken,
      );
      expect(
        harness.refreshAdapter.requests.single.body,
        contains('dummy-old-refresh'),
      );
      expect(harness.retryAdapter.requests, hasLength(1));
      expect(
        harness.retryAdapter.requests.single.options.path,
        EndPoints.mobileLogout,
      );
      expect(harness.retryAdapter.requests.single.options.method, 'POST');
      expect(harness.retryAdapter.requests.single.body, isNull);
      expect(
        harness.retryAdapter.requests.single.authorization,
        'Bearer dummy-new-access',
      );
      expect(storage.getUserToken(), isNull);
      expect(storage.getRefreshToken(), isNull);
    },
  );

  test(
    'refresh rejection stops attempts and preserves local credentials',
    () async {
      final harness = createLogoutHarness(
        respondWith(419, {'message': 'Token expired'}),
        refreshAdapter: respondWith(401, {'message': 'refresh rejected'}),
      );

      final result = await harness.repository.logout();

      expect(result.isLeft(), isTrue);
      expect(harness.adapter.requests, hasLength(1));
      expect(harness.refreshAdapter.requests, hasLength(1));
      expect(harness.retryAdapter.requests, isEmpty);
      expect(storage.getUserToken(), 'dummy-old-access');
      expect(storage.getRefreshToken(), 'dummy-old-refresh');
    },
  );

  test(
    'retried Logout 419 is returned without another refresh or retry',
    () async {
      final harness = createLogoutHarness(
        respondWith(419, {'message': 'Token expired'}),
        refreshAdapter: respondWith(200, {
          'data': {
            'access_token': 'dummy-new-access',
            'refresh_token': 'dummy-new-refresh',
          },
        }),
        retryAdapter: respondWith(419, {'message': 'Token expired again'}),
      );

      final result = await harness.repository.logout();

      expect(result.isLeft(), isTrue);
      expect(harness.adapter.requests, hasLength(1));
      expect(harness.refreshAdapter.requests, hasLength(1));
      expect(harness.retryAdapter.requests, hasLength(1));
      expect(storage.getUserToken(), 'dummy-new-access');
      expect(storage.getRefreshToken(), 'dummy-new-refresh');
    },
  );

  test('concurrent Cubit calls issue one Logout and one Refresh', () async {
    final refreshStarted = Completer<void>();
    final releaseRefresh = Completer<void>();
    final refreshAdapter = FakeHttpAdapter((_, _) async {
      if (!refreshStarted.isCompleted) refreshStarted.complete();
      await releaseRefresh.future;
      return jsonResponse(200, {
        'data': {'access_token': 'dummy-concurrent-access'},
      });
    });
    final harness = createLogoutHarness(
      respondWith(419, {'message': 'Token expired'}),
      refreshAdapter: refreshAdapter,
      retryAdapter: respondWith(201, {'statusCode': 200}),
    );
    final cubit = LogoutCubit(LogoutUseCase(harness.repository));
    final states = <LogoutState>[];
    final subscription = cubit.stream.listen(states.add);

    final first = cubit.logout();
    await refreshStarted.future.timeout(const Duration(seconds: 2));
    await cubit.logout();
    releaseRefresh.complete();
    await first;
    await Future<void>.delayed(Duration.zero);

    expect(harness.adapter.requests, hasLength(1));
    expect(harness.refreshAdapter.requests, hasLength(1));
    expect(harness.retryAdapter.requests, hasLength(1));
    expect(states.whereType<LogoutLoading>(), hasLength(1));
    expect(states.whereType<LogoutSuccess>(), hasLength(1));

    await subscription.cancel();
    await cubit.close();
  });
}
