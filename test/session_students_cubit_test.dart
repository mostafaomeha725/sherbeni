import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qrattendance/core/error/failure.dart';
import 'package:qrattendance/features/atendance/domain/entities/session_attendance_entity.dart';
import 'package:qrattendance/features/atendance/domain/repositories/attendance_repository.dart';
import 'package:qrattendance/features/atendance/domain/use_cases/get_offline_session_attendances_use_case.dart';
import 'package:qrattendance/features/atendance/domain/use_cases/get_session_attendances_use_case.dart';
import 'package:qrattendance/features/atendance/presentation/cubit/session_students/session_students_cubit.dart';

class FakeGetSessionAttendancesUseCase implements GetSessionAttendancesUseCase {
  Either<Failure, Map<String, dynamic>>? mockResponse;

  @override
  late final AttendanceRepository repository;

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(
    String sessionId,
    int page,
    int limit,
  ) async {
    return mockResponse ??
        const Right({
          'data': {'attendances': []},
          'pagination': null,
        });
  }
}

class FakeGetOfflineSessionAttendancesUseCase
    implements GetOfflineSessionAttendancesUseCase {
  Either<Failure, List<SessionAttendanceEntity>>? mockResponse;

  @override
  late final AttendanceRepository repository;

  @override
  Future<Either<Failure, List<SessionAttendanceEntity>>> call(
    String sessionId,
  ) async {
    return mockResponse ?? const Right([]);
  }
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
}

class FakeSocket implements Socket {
  @override
  void destroy() {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late SessionStudentsCubit cubit;
  late FakeGetSessionAttendancesUseCase onlineUseCase;
  late FakeGetOfflineSessionAttendancesUseCase offlineUseCase;
  late FakeConnectivity connectivity;

  setUp(() {
    onlineUseCase = FakeGetSessionAttendancesUseCase();
    offlineUseCase = FakeGetOfflineSessionAttendancesUseCase();
    connectivity = FakeConnectivity();
    cubit = SessionStudentsCubit(onlineUseCase, offlineUseCase, connectivity);
  });

  tearDown(() {
    cubit.close();
  });

  test('Wi-Fi + internet -> online students API', () async {
    connectivity.mockResult = [ConnectivityResult.wifi];

    onlineUseCase.mockResponse = const Right({
      'data': {
        'attendances': [
          {'student_id': '1', 'name': 'A', 'session_id': 's1'},
        ],
      },
      'pagination': null,
    });

    await IOOverrides.runZoned(
      () async {
        await cubit.fetchStudents('s1');
      },
      socketConnect:
          (host, port, {sourceAddress, sourcePort = 0, timeout}) async {
            return FakeSocket();
          },
    );

    expect(cubit.state, isA<SessionStudentsLoaded>());
    final state = cubit.state as SessionStudentsLoaded;
    expect(state.isOffline, isFalse);
    expect(state.attendances.length, 1);
  });

  test('Wi-Fi + no internet -> offline students/cache', () async {
    connectivity.mockResult = [ConnectivityResult.wifi];

    offlineUseCase.mockResponse = const Right([]);

    // Override socketConnect to simulate no actual internet reachability (Android "!")
    await IOOverrides.runZoned(
      () async {
        await cubit.fetchStudents('s1');
      },
      socketConnect:
          (host, port, {sourceAddress, sourcePort = 0, timeout}) async {
            throw const SocketException('Simulated network failure');
          },
    );

    expect(cubit.state, isA<SessionStudentsLoaded>());
    final state = cubit.state as SessionStudentsLoaded;
    expect(state.isOffline, isTrue);
  });

  test('Wi-Fi disconnected -> offline students/cache', () async {
    connectivity.mockResult = [ConnectivityResult.none];

    offlineUseCase.mockResponse = const Right([]);

    await cubit.fetchStudents('s1');

    expect(cubit.state, isA<SessionStudentsLoaded>());
    final state = cubit.state as SessionStudentsLoaded;
    expect(state.isOffline, isTrue);
  });

  test('mobile data + internet -> online students API', () async {
    connectivity.mockResult = [ConnectivityResult.mobile];

    onlineUseCase.mockResponse = const Right({
      'data': {'attendances': []},
      'pagination': null,
    });

    await IOOverrides.runZoned(
      () async {
        await cubit.fetchStudents('s1');
      },
      socketConnect:
          (host, port, {sourceAddress, sourcePort = 0, timeout}) async {
            return FakeSocket();
          },
    );

    expect(cubit.state, isA<SessionStudentsLoaded>());
    final state = cubit.state as SessionStudentsLoaded;
    expect(state.isOffline, isFalse);
  });
}
