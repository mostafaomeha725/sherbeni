import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qrattendance/core/services/global_sync_coordinator.dart';
import 'package:qrattendance/features/atendance/domain/use_cases/sync_offline_data_use_case.dart';
import 'package:qrattendance/features/atendance/data/data_sources/attendance_local_data_source.dart';
import 'package:qrattendance/features/atendance/data/model/attendance_model.dart';
import 'package:qrattendance/features/atendance/data/model/pending_quiz_grade_model.dart';
import 'package:qrattendance/core/error/failure.dart';
import 'dart:io';

class FakeSyncOfflineDataUseCase implements SyncOfflineDataUseCase {
  int callCount = 0;
  Completer<void>? _completer;
  bool shouldFail = false;

  FakeSyncOfflineDataUseCase();

  @override
  Future<Either<Failure, Map<String, dynamic>>> call() async {
    callCount++;
    if (_completer != null) {
      await _completer!.future;
    }
    if (shouldFail) {
      return Left(ServerFailure(message: 'Simulated backend error'));
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
  final _controller = StreamController<List<ConnectivityResult>>.broadcast();

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async {
    return mockResult;
  }

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      _controller.stream;

  void emit(List<ConnectivityResult> result) {
    mockResult = result;
    _controller.add(result);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeAttendanceLocalDataSource implements AttendanceLocalDataSource {
  List<AttendanceModel> attendances = [];
  List<PendingQuizGradeModel> grades = [];

  @override
  Future<List<AttendanceModel>> getOfflineAttendances() async => attendances;

  @override
  Future<List<PendingQuizGradeModel>> getPendingQuizGrades() async => grades;

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
  late FakeAttendanceLocalDataSource mockLocalDataSource;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    mockSyncUseCase = FakeSyncOfflineDataUseCase();
    mockConnectivity = FakeConnectivity();
    mockLocalDataSource = FakeAttendanceLocalDataSource();

    coordinator = GlobalSyncCoordinator(
      syncOfflineDataUseCase: mockSyncUseCase,
      localDataSource: mockLocalDataSource,
      connectivity: mockConnectivity,
    );
  });

  tearDown(() {
    coordinator.dispose();
  });

  test('1. Wi-Fi connected + Internet available -> sync happens', () async {
    mockLocalDataSource.attendances = [
      AttendanceModel(uid: '123', sessionId: '456', scanTime: 'time'),
    ];

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
  });

  test('2. Wi-Fi connected + NO Internet -> no sync', () async {
    mockLocalDataSource.attendances = [
      AttendanceModel(uid: '123', sessionId: '456', scanTime: 'time'),
    ];

    await IOOverrides.runZoned(
      () async {
        coordinator.init();
        await Future.delayed(const Duration(milliseconds: 100));
        expect(mockSyncUseCase.callCount, 0); // No internet
      },
      socketConnect:
          (host, port, {sourceAddress, sourcePort = 0, timeout}) async {
            throw const SocketException('No internet');
          },
    );
  });

  test(
    '3. Internet becomes available later (backoff fires) -> pending attendance syncs',
    () async {
      mockLocalDataSource.attendances = [
        AttendanceModel(uid: '123', sessionId: '456', scanTime: 'time'),
      ];

      bool hasInternet = false;

      await IOOverrides.runZoned(
        () async {
          coordinator.init(); // Starts with backoff 5s because no internet
          await Future.delayed(const Duration(milliseconds: 100));
          expect(mockSyncUseCase.callCount, 0);

          // Internet is restored
          hasInternet = true;

          // Wait for the 5s timer to fire
          await Future.delayed(const Duration(seconds: 6));
          expect(mockSyncUseCase.callCount, 1);
        },
        socketConnect:
            (host, port, {sourceAddress, sourcePort = 0, timeout}) async {
              if (hasInternet) return FakeSocket();
              throw const SocketException('No internet');
            },
      );
    },
  );

  test('4. App resumes with pending attendance + Internet -> sync', () async {
    mockLocalDataSource.attendances = [
      AttendanceModel(uid: '123', sessionId: '456', scanTime: 'time'),
    ];

    await IOOverrides.runZoned(
      () async {
        coordinator.init();
        await Future.delayed(const Duration(milliseconds: 100));
        mockSyncUseCase.callCount = 0; // reset

        coordinator.didChangeAppLifecycleState(AppLifecycleState.resumed);
        await Future.delayed(const Duration(milliseconds: 100));
        expect(mockSyncUseCase.callCount, 1);
      },
      socketConnect:
          (host, port, {sourceAddress, sourcePort = 0, timeout}) async {
            return FakeSocket();
          },
    );
  });

  test(
    '6. Multiple triggers at the same time -> only one sync (single flight)',
    () async {
      mockLocalDataSource.attendances = [
        AttendanceModel(uid: '123', sessionId: '456', scanTime: 'time'),
      ];
      mockSyncUseCase.block();

      await IOOverrides.runZoned(
        () async {
          coordinator.init();

          // Simulate multiple triggers instantly
          coordinator.didChangeAppLifecycleState(AppLifecycleState.resumed);
          mockConnectivity.emit([ConnectivityResult.wifi]);

          await Future.delayed(const Duration(milliseconds: 50));
          expect(mockSyncUseCase.callCount, 1); // Only 1 concurrent call

          mockSyncUseCase.unblock();
        },
        socketConnect:
            (host, port, {sourceAddress, sourcePort = 0, timeout}) async {
              return FakeSocket();
            },
      );
    },
  );

  test('7. No pending attendance -> no reachability checks/retries', () async {
    mockLocalDataSource.attendances = []; // Empty
    mockLocalDataSource.grades = [];

    int reachabilityCheckCount = 0;

    await IOOverrides.runZoned(
      () async {
        coordinator.init();
        await Future.delayed(const Duration(milliseconds: 100));
        expect(mockSyncUseCase.callCount, 0);
        expect(reachabilityCheckCount, 0);
      },
      socketConnect:
          (host, port, {sourceAddress, sourcePort = 0, timeout}) async {
            reachabilityCheckCount++;
            return FakeSocket();
          },
    );
  });

  test('8. Sync failure keeps pending records and retries', () async {
    mockLocalDataSource.attendances = [
      AttendanceModel(uid: '123', sessionId: '456', scanTime: 'time'),
    ];
    mockSyncUseCase.shouldFail = true;

    await IOOverrides.runZoned(
      () async {
        coordinator.init();
        await Future.delayed(const Duration(milliseconds: 100));
        expect(mockSyncUseCase.callCount, 1); // First attempt failed

        // Wait for 5s backoff
        await Future.delayed(const Duration(seconds: 6));
        expect(mockSyncUseCase.callCount, 2); // Retried automatically
      },
      socketConnect:
          (host, port, {sourceAddress, sourcePort = 0, timeout}) async {
            return FakeSocket();
          },
    );
  });

  test('9. Successful sync stops retrying', () async {
    mockLocalDataSource.attendances = [
      AttendanceModel(uid: '123', sessionId: '456', scanTime: 'time'),
    ];

    await IOOverrides.runZoned(
      () async {
        coordinator.init();
        await Future.delayed(const Duration(milliseconds: 100));
        expect(mockSyncUseCase.callCount, 1);

        // Clear pending data to simulate successful deletion by repository
        mockLocalDataSource.attendances = [];

        // Wait 6s, there should NOT be another call
        await Future.delayed(const Duration(seconds: 6));
        expect(mockSyncUseCase.callCount, 1);
      },
      socketConnect:
          (host, port, {sourceAddress, sourcePort = 0, timeout}) async {
            return FakeSocket();
          },
    );
  });
}
