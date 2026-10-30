import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:qrattendance/core/di/services_locator.dart';
import 'package:qrattendance/core/enums/app_enums.dart';

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
    directory = await Directory.systemTemp.createTemp('logout_preserve_');
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
    await sl.reset();
  });

  test('successful server logout preserves all offline Hive data', () async {
    final adapter = FakeHttpAdapter(
      (_, _) async => jsonResponse(201, {
        'statusCode': 200,
        'message': 'Offline assistant logged out successfully',
      }),
    );
    final harness = createLogoutHarness(adapter);

    final result = await harness.repository.logout();

    expect(result.isRight(), isTrue);
    expect(history.get('history'), {'recorded': true});
    expect(attendance.get('queued'), {'pending': true});
    expect(searches.get('queued-search'), {'query': 'offline'});
    expect(storage.getUserToken(), isNull);
    expect(storage.getRefreshToken(), isNull);
    expect(storage.getString(key: PreferencesKeys.currentLanguage), 'ar');
    expect(storage.getString(key: PreferencesKeys.currentCurrency), 'EGP');
    expect(storage.getString(key: PreferencesKeys.fcmToken), 'dummy-fcm');
    expect(storage.getBoolean(key: PreferencesKeys.hasSeenOnBoarding), isTrue);
  });

  test(
    'failed server logout preserves session and all offline Hive data',
    () async {
      final adapter = respondWith(500, {'message': 'server error'});
      final harness = createLogoutHarness(adapter);

      final result = await harness.repository.logout();

      expect(result.isLeft(), isTrue);
      expect(storage.getUserToken(), 'dummy-old-access');
      expect(storage.getRefreshToken(), 'dummy-old-refresh');
      expect(history.get('history'), {'recorded': true});
      expect(attendance.get('queued'), {'pending': true});
      expect(searches.get('queued-search'), {'query': 'offline'});
    },
  );
}
