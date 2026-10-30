import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qrattendance/core/di/services_locator.dart';

import 'support/token_refresh_test_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() async => installFakePreferences());
  tearDown(() async => sl.reset());

  test('concurrent 419 responses share one refresh request', () async {
    final bothStarted = Completer<void>();
    final refreshStarted = Completer<void>();
    final releaseRefresh = Completer<void>();
    var mainRequestCount = 0;
    final mainAdapter = FakeHttpAdapter((_, _) async {
      mainRequestCount++;
      if (mainRequestCount == 2 && !bothStarted.isCompleted) {
        bothStarted.complete();
      }
      await bothStarted.future;
      return jsonResponse(419, {'message': 'expired'});
    });
    final harness = createRefreshHarness(
      mainAdapter: mainAdapter,
      refreshAdapter: FakeHttpAdapter((_, _) async {
        if (!refreshStarted.isCompleted) refreshStarted.complete();
        await releaseRefresh.future;
        return jsonResponse(200, {
          'data': {'access_token': 'dummy-concurrent-access'},
        });
      }),
      retryAdapter: respondWith(200, {'ok': true}),
    );
    final requests = Future.wait([
      harness.client.get('/resource', queryParameters: {'id': 'one'}),
      harness.client.get('/resource', queryParameters: {'id': 'two'}),
    ]);

    await refreshStarted.future.timeout(const Duration(seconds: 2));
    await Future<void>.delayed(const Duration(milliseconds: 25));
    releaseRefresh.complete();
    await requests;

    expect(harness.refreshAdapter.requests, hasLength(1));
    expect(harness.retryAdapter.requests, hasLength(2));
    expect(
      harness.retryAdapter.requests.map((request) => request.authorization),
      everyElement('Bearer dummy-concurrent-access'),
    );
    expect(harness.cleanupCount(), 0);
  });

  test(
    'late 419 uses the latest access token without a second refresh',
    () async {
      final lateStarted = Completer<void>();
      final releaseLate = Completer<void>();
      final mainAdapter = FakeHttpAdapter((options, _) async {
        if (options.queryParameters['id'] == 'late') {
          if (!lateStarted.isCompleted) lateStarted.complete();
          await releaseLate.future;
        }
        return jsonResponse(419, {'message': 'expired'});
      });
      final harness = createRefreshHarness(
        mainAdapter: mainAdapter,
        refreshAdapter: respondWith(200, {
          'data': {'access_token': 'dummy-latest-access'},
        }),
        retryAdapter: respondWith(200, {'ok': true}),
      );
      final lateRequest = harness.client.get(
        '/resource',
        queryParameters: {'id': 'late'},
      );

      await lateStarted.future.timeout(const Duration(seconds: 2));
      await harness.client.get('/resource', queryParameters: {'id': 'early'});
      releaseLate.complete();
      await lateRequest;

      expect(harness.refreshAdapter.requests, hasLength(1));
      expect(harness.retryAdapter.requests, hasLength(2));
      expect(
        harness.retryAdapter.requests.map((request) => request.authorization),
        everyElement('Bearer dummy-latest-access'),
      );
    },
  );

  test('concurrent explicit refresh rejection cleans up only once', () async {
    final bothStarted = Completer<void>();
    var mainRequestCount = 0;
    final mainAdapter = FakeHttpAdapter((_, _) async {
      mainRequestCount++;
      if (mainRequestCount == 2 && !bothStarted.isCompleted) {
        bothStarted.complete();
      }
      await bothStarted.future;
      return jsonResponse(419, {'message': 'expired'});
    });
    final harness = createRefreshHarness(
      mainAdapter: mainAdapter,
      refreshAdapter: respondWith(403, {'message': 'rejected'}),
      retryAdapter: respondWith(200, {'unused': true}),
    );
    final errors = await Future.wait([
      captureDioException(harness.client.get('/one')),
      captureDioException(harness.client.get('/two')),
    ]);

    expect(errors, everyElement(isA<DioException>()));
    expect(harness.refreshAdapter.requests, hasLength(1));
    expect(harness.retryAdapter.requests, isEmpty);
    expect(harness.cleanupCount(), 1);
  });
}
