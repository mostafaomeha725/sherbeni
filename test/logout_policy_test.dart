import 'package:flutter_test/flutter_test.dart';
import 'package:qrattendance/core/cache/preferences_storage.dart';
import 'package:qrattendance/core/di/services_locator.dart';
import 'package:qrattendance/core/enums/app_enums.dart';

import 'support/logout_test_harness.dart';
import 'support/token_refresh_test_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late PreferencesStorage storage;

  setUp(() async => storage = await installFakePreferences());
  tearDown(() async => sl.reset());

  test(
    'logout 419 with refresh rejection stops retry and preserves credentials',
    () async {
      final adapter = FakeHttpAdapter(
        (_, _) async => jsonResponse(419, {'message': 'expired'}),
      );
      final harness = createLogoutHarness(
        adapter,
        refreshAdapter: respondWith(401, {'message': 'refresh rejected'}),
      );

      final result = await harness.repository.logout();

      expect(result.isLeft(), isTrue);
      expect(adapter.requests, hasLength(1));
      expect(adapter.requests.single.options.path, 'api/v1/mobile/logout');
      expect(adapter.requests.single.options.method, 'POST');
      expect(harness.refreshAdapter.requests, hasLength(1));
      expect(harness.retryAdapter.requests, isEmpty);
      expect(storage.getUserToken(), 'dummy-old-access');
    },
  );

  test(
    'missing access token performs local auth cleanup without API request',
    () async {
      storage = await installFakePreferences(
        initialValues: {
          'currentLanguage': 'ar',
          'currentCurrency': 'EGP',
          'fcmToken': 'dummy-fcm',
          'uuid': 'dummy-device',
          'hasSeenOnBoarding': true,
          'userProfile': '{"name":"Dummy"}',
        },
      );
      final adapter = respondWith(201, {'statusCode': 200});
      final harness = createLogoutHarness(adapter);

      final result = await harness.repository.logout();

      expect(result.isRight(), isTrue);
      expect(adapter.requests, isEmpty);
      expect(storage.getUserProfile(), isNull);
      expect(storage.getString(key: PreferencesKeys.currentLanguage), 'ar');
      expect(storage.getString(key: PreferencesKeys.fcmToken), 'dummy-fcm');
    },
  );
}
