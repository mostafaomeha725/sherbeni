import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qrattendance/core/services/global_sync_coordinator.dart';
import 'package:qrattendance/features/atendance/domain/use_cases/sync_offline_data_use_case.dart';
import 'package:qrattendance/core/error/failure.dart';
import 'dart:io';

class FakeSyncOfflineDataUseCase implements SyncOfflineDataUseCase {
  int callCount = 0;
  Completer<void>? _completer;

  FakeSyncOfflineDataUseCase();

  @override
  Future<Either<Failure, Map<String, dynamic>>> call() async {
    callCount++;
    if (_completer != null) {
      await _completer!.future;
    }
    return const Right<Failure, Map<String, dynamic>>({});
  }

  void block() {
    _completer = Completer<void>();
  }

  void unblock() {
    _completer?.complete();
    _completer = null;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeConnectivity implements Connectivity {
  List<ConnectivityResult> mockResult = [ConnectivityResult.wifi];

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async {
    return mockResult;
  }

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      Stream.value(mockResult);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeSocket implements Socket {
  @override
  void destroy() {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late GlobalSyncCoordinator coordinator;
  late FakeSyncOfflineDataUseCase mockSyncUseCase;
  late FakeConnectivity mockConnectivity;

  setUp(() {
    mockSyncUseCase = FakeSyncOfflineDataUseCase();
    mockConnectivity = FakeConnectivity();
    coordinator = GlobalSyncCoordinator(
      syncOfflineDataUseCase: mockSyncUseCase,
      connectivity: mockConnectivity,
    );
  });

  tearDown(() {
    coordinator.dispose();
  });

  test(
    '5. Pending attendance syncs on app startup (if internet available)',
    () async {
      await IOOverrides.runZoned(
        () async {
          coordinator.init();
          await Future.delayed(const Duration(milliseconds: 100));
          expect(mockSyncUseCase.callCount, 1);
        },
        socketConnect:
            (host, port, {sourceAddress, sourcePort = 0, timeout}) async {
              return FakeSocket();
            },
      );
    },
  );

  test('6. Wi-Fi with no internet does not trigger sync', () async {
    await IOOverrides.runZoned(
      () async {
        coordinator.init();
        await Future.delayed(const Duration(milliseconds: 100));
        expect(mockSyncUseCase.callCount, 0); // Should be 0 since no internet
      },
      socketConnect:
          (host, port, {sourceAddress, sourcePort = 0, timeout}) async {
            throw const SocketException('Simulated no internet');
          },
    );
  });

  test('8. No concurrent duplicate sync calls', () async {
    mockSyncUseCase.block();

    await IOOverrides.runZoned(
      () async {
        coordinator.init();
        await Future.delayed(const Duration(milliseconds: 50));

        // Simulate another connectivity event while the first one is blocked
        coordinator.init();
        await Future.delayed(const Duration(milliseconds: 50));

        expect(
          mockSyncUseCase.callCount,
          1,
        ); // still 1 because blocked by _isSyncing

        mockSyncUseCase.unblock();
      },
      socketConnect:
          (host, port, {sourceAddress, sourcePort = 0, timeout}) async {
            return FakeSocket();
          },
    );
  });
}
