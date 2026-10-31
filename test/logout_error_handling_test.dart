import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:qrattendance/core/di/services_locator.dart';
import 'package:qrattendance/core/error/failure.dart';
import 'package:qrattendance/core/network/network_service.dart';
import 'package:qrattendance/features/auth/domain/use_cases/logout_use_case.dart';
import 'package:qrattendance/features/auth/presentation/cubit/logout_cubit/logout_cubit.dart';
import 'package:qrattendance/features/auth/presentation/cubit/logout_cubit/logout_state.dart';

import 'support/logout_test_harness.dart';
import 'support/token_refresh_test_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;
  late Box<dynamic> history;
  late Box<dynamic> attendance;
  late Box<dynamic> searches;
  late dynamic storage;

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('logout_error_');
    Hive.init(directory.path);
    history = await Hive.openBox<dynamic>('attendanceHistory');
    attendance = await Hive.openBox<dynamic>('studentSessions');
    searches = await Hive.openBox<dynamic>('pendingSearches');
    await history.put('history', {'recorded': true});
    await attendance.put('queued', {'pending': true});
    await searches.put('queued-search', {'query': 'offline'});
    storage = await installFakePreferences();
  });

  tearDown(() async {
    await Hive.close();
    if (await directory.exists()) await directory.delete(recursive: true);
    NetworkService.internetCheckerOverride = null;
    await sl.reset();
  });

  test(
    '1. Logout without internet returns exact Arabic message and preserves tokens/session/Hive',
    () async {
      final adapter = respondWith(201, {'statusCode': 200});
      final harness = createLogoutHarness(
        adapter,
        checkInternet: () async => false,
      );

      final result = await harness.repository.logout();

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<NetworkFailure>());
          expect(
            failure.message,
            'لا يوجد اتصال بالإنترنت، تحقق من اتصالك وحاول مرة أخرى.',
          );
        },
        (_) => fail('Logout must not succeed without internet'),
      );

      // Adapter should not even be called when there is no internet
      expect(adapter.requests, isEmpty);

      // Local tokens and data must NOT be cleared
      expect(storage.getUserToken(), 'dummy-old-access');
      expect(storage.getRefreshToken(), 'dummy-old-refresh');
      expect(history.get('history'), {'recorded': true});
      expect(attendance.get('queued'), {'pending': true});
      expect(searches.get('queued-search'), {'query': 'offline'});
    },
  );

  test(
    '2. Logout with internet active but server connection error returns ServerFailure, not no-internet',
    () async {
      final adapter = FakeHttpAdapter((options, _) async {
        throw DioException.connectionError(
          requestOptions: options,
          reason: 'Connection refused / host down',
        );
      });
      final harness = createLogoutHarness(
        adapter,
        checkInternet: () async => true,
      );

      final result = await harness.repository.logout();

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, 'تعذر الاتصال بالخادم، يرجى المحاولة لاحقًا.');
          expect(
            failure.message,
            isNot(contains('لا يوجد اتصال بالإنترنت')),
          );
        },
        (_) => fail('Logout must not succeed on server connection error'),
      );

      expect(storage.getUserToken(), 'dummy-old-access');
      expect(storage.getRefreshToken(), 'dummy-old-refresh');
      expect(history.get('history'), {'recorded': true});
    },
  );

  test(
    '3. Logout with server HTTP 500/502/503 returns ServerFailure with server error message',
    () async {
      for (final statusCode in [500, 502, 503]) {
        await sl.reset();
        storage = await installFakePreferences();
        final adapter = respondWith(statusCode, {
          'message': 'Internal Server Error on cluster',
        });
        final harness = createLogoutHarness(
          adapter,
          checkInternet: () async => true,
        );

        final result = await harness.repository.logout();

        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) {
            expect(failure, isA<ServerFailure>());
            expect(failure.message, 'Internal Server Error on cluster');
            expect(failure.message, isNot(contains('لا يوجد اتصال بالإنترنت')));
          },
          (_) => fail('Logout must not succeed on $statusCode'),
        );

        expect(storage.getUserToken(), 'dummy-old-access');
      }
    },
  );

  test(
    '4. Logout with connection timeout returns TimeoutFailure with timeout message',
    () async {
      final adapter = FakeHttpAdapter((options, _) async {
        throw DioException.connectionTimeout(
          requestOptions: options,
          timeout: const Duration(seconds: 30),
        );
      });
      final harness = createLogoutHarness(
        adapter,
        checkInternet: () async => true,
      );

      final result = await harness.repository.logout();

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<TimeoutFailure>());
          expect(
            failure.message,
            'انتهت مهلة الاتصال بالخادم، يرجى المحاولة مرة أخرى.',
          );
        },
        (_) => fail('Logout must not succeed on timeout'),
      );

      expect(storage.getUserToken(), 'dummy-old-access');
    },
  );

  test(
    '5. Logout with receive timeout and send timeout return TimeoutFailure',
    () async {
      for (final type in [
        DioExceptionType.receiveTimeout,
        DioExceptionType.sendTimeout,
      ]) {
        await sl.reset();
        storage = await installFakePreferences();
        final adapter = FakeHttpAdapter((options, _) async {
          throw DioException(
            requestOptions: options,
            type: type,
          );
        });
        final harness = createLogoutHarness(
          adapter,
          checkInternet: () async => true,
        );

        final result = await harness.repository.logout();

        expect(result.isLeft(), isTrue);
        result.fold(
          (failure) {
            expect(failure, isA<TimeoutFailure>());
            expect(
              failure.message,
              'انتهت مهلة الاتصال بالخادم، يرجى المحاولة مرة أخرى.',
            );
          },
          (_) => fail('Logout must not succeed on timeout'),
        );
      }
    },
  );

  test(
    '6. Logout with HTTP 401 returns AuthFailure explaining session expiration',
    () async {
      final adapter = respondWith(401, {'message': 'Unauthorized session'});
      final harness = createLogoutHarness(
        adapter,
        checkInternet: () async => true,
      );

      final result = await harness.repository.logout();

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<AuthFailure>());
          expect(failure.message, 'Unauthorized session');
          expect(failure.message, isNot(contains('لا يوجد اتصال بالإنترنت')));
        },
        (_) => fail('Logout must not succeed on 401'),
      );

      expect(storage.getUserToken(), 'dummy-old-access');
      expect(storage.getRefreshToken(), 'dummy-old-refresh');
    },
  );

  test(
    '7. Logout with HTTP 419 refreshes once then retries logout with new token',
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
        checkInternet: () async => true,
      );

      final result = await harness.repository.logout();

      expect(result.isRight(), isTrue);
      expect(harness.adapter.requests, hasLength(1));
      expect(harness.refreshAdapter.requests, hasLength(1));
      expect(harness.retryAdapter.requests, hasLength(1));
      expect(storage.getUserToken(), isNull);
      expect(storage.getRefreshToken(), isNull);
    },
  );

  test(
    '8. LogoutCubit emits LogoutLoading then LogoutFailure with no-internet message',
    () async {
      final adapter = respondWith(201, {'statusCode': 200});
      final harness = createLogoutHarness(
        adapter,
        checkInternet: () async => false,
      );
      final cubit = LogoutCubit(LogoutUseCase(harness.repository));
      final states = <LogoutState>[];
      final subscription = cubit.stream.listen(states.add);

      await cubit.logout();
      await Future<void>.delayed(Duration.zero);

      expect(states, [
        isA<LogoutLoading>(),
        isA<LogoutFailure>(),
      ]);
      expect(
        (states.last as LogoutFailure).message,
        'لا يوجد اتصال بالإنترنت، تحقق من اتصالك وحاول مرة أخرى.',
      );
      expect(states.whereType<LogoutSuccess>(), isEmpty);

      await subscription.cancel();
      await cubit.close();
    },
  );

  test(
    '9. Confirmed server 201 with statusCode 200 is the ONLY path that clears auth and allows login navigation',
    () async {
      final adapter = FakeHttpAdapter(
        (_, _) async => jsonResponse(201, {
          'statusCode': 200,
          'message': 'Logged out successfully',
        }),
      );
      final harness = createLogoutHarness(
        adapter,
        checkInternet: () async => true,
      );
      final cubit = LogoutCubit(LogoutUseCase(harness.repository));
      final states = <LogoutState>[];
      final subscription = cubit.stream.listen(states.add);

      await cubit.logout();
      await Future<void>.delayed(Duration.zero);

      expect(states, [
        isA<LogoutLoading>(),
        isA<LogoutSuccess>(),
      ]);
      expect(storage.getUserToken(), isNull);
      expect(storage.getRefreshToken(), isNull);

      // Offline Hive boxes must STILL be preserved even after successful logout!
      expect(history.get('history'), {'recorded': true});
      expect(attendance.get('queued'), {'pending': true});
      expect(searches.get('queued-search'), {'query': 'offline'});

      await subscription.cancel();
      await cubit.close();
    },
  );
}
