import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qrattendance/core/error/failure.dart';
import 'package:qrattendance/features/atendance/domain/entities/session_entity.dart';
import 'package:qrattendance/features/atendance/domain/repositories/attendance_repository.dart';
import 'package:qrattendance/features/atendance/domain/use_cases/get_sessions_use_case.dart';
import 'package:qrattendance/features/atendance/presentation/cubit/show_sessions/show_sessions_cubit.dart';

// -----------------------------------------------------------------------------
// FAKE REPOSITORY
// -----------------------------------------------------------------------------

class FakeAttendanceRepository implements AttendanceRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeGetSessionsUseCase extends GetSessionsUseCase {
  Either<Failure, List<SessionEntity>>? mockCallResponse;
  Either<Failure, List<SessionEntity>>? mockCachedResponse;

  String? lastCallClassId;
  String? lastCachedClassId;

  FakeGetSessionsUseCase() : super(FakeAttendanceRepository());

  @override
  Future<Either<Failure, List<SessionEntity>>> call({
    required String token,
    required String classId,
  }) async {
    lastCallClassId = classId;
    if (mockCallResponse != null) {
      return mockCallResponse!;
    }
    return const Left(ServerFailure(message: 'Unmocked response'));
  }

  @override
  Future<Either<Failure, List<SessionEntity>>> getCached({
    required String classId,
  }) async {
    lastCachedClassId = classId;
    if (mockCachedResponse != null) {
      return mockCachedResponse!;
    }
    return const Right([]);
  }
}

void main() {
  late ShowSessionsCubit cubit;
  late FakeGetSessionsUseCase useCase;

  setUp(() {
    useCase = FakeGetSessionsUseCase();
    cubit = ShowSessionsCubit(useCase);
  });

  group('ShowSessionsCubit Tests - Subject/Session Fetching by class_id', () {
    final sessionA = const SessionEntity(
      id: 'sessionA',
      title: 'Math',
      description: '',
      courseId: 'course1',
      courseTitle: '',
      startTime: '',
      endTime: '',
      status: '',
      hasHomework: false,
      totalAttendance: 0,
      attendedCount: 0,
      lateCount: 0,
      hasQuiz: false,
    );

    final sessionB = const SessionEntity(
      id: 'sessionB',
      title: 'Physics',
      description: '',
      courseId: 'course2',
      courseTitle: '',
      startTime: '',
      endTime: '',
      status: '',
      hasHomework: false,
      totalAttendance: 0,
      attendedCount: 0,
      lateCount: 0,
      hasQuiz: false,
    );

    test('TEST 1: Online -> Select Class A -> Subjects A displayed', () async {
      useCase.mockCachedResponse = const Right([]);
      useCase.mockCallResponse = Right([sessionA]);

      await cubit.fetchSessions('token123', 'classA');

      expect(useCase.lastCachedClassId, 'classA');
      expect(useCase.lastCallClassId, 'classA');

      expect(cubit.state, isA<ShowSessionsSuccess>());
      expect(
        (cubit.state as ShowSessionsSuccess).sessions.first.id,
        'sessionA',
      );
    });

    test(
      'TEST 2: Offline -> Select Class A -> Class A sessions cache exists -> Subjects A displayed',
      () async {
        useCase.mockCachedResponse = Right([sessionA]);
        useCase.mockCallResponse = const Left(
          CacheFailure(message: 'OFFLINE_FALLBACK'),
        );

        await cubit.fetchSessions('token123', 'classA');

        expect(useCase.lastCachedClassId, 'classA');
        expect(useCase.lastCallClassId, 'classA');

        expect(cubit.state, isA<ShowSessionsSuccess>());
        expect(
          (cubit.state as ShowSessionsSuccess).sessions.first.id,
          'sessionA',
        );
      },
    );

    test(
      'TEST 3: Offline -> Select Class A -> Class A sessions cache DOES NOT exist -> No Offline Data Available state (ShowSessionsOfflineFallback) is displayed',
      () async {
        useCase.mockCachedResponse = const Right([]);
        useCase.mockCallResponse = const Left(
          CacheFailure(message: 'OFFLINE_FALLBACK'),
        );

        await cubit.fetchSessions('token123', 'classA');

        expect(useCase.lastCachedClassId, 'classA');
        expect(useCase.lastCallClassId, 'classA');

        expect(cubit.state, isA<ShowSessionsOfflineFallback>());
      },
    );

    test(
      'TEST 4: Offline -> Select Class B -> Class B has no cache -> Do NOT display Class A subjects',
      () async {
        useCase.mockCachedResponse = const Right([]);
        useCase.mockCallResponse = const Left(
          CacheFailure(message: 'OFFLINE_FALLBACK'),
        );

        await cubit.fetchSessions('token123', 'classB');

        expect(useCase.lastCachedClassId, 'classB');
        expect(useCase.lastCallClassId, 'classB');

        expect(cubit.state, isA<ShowSessionsOfflineFallback>());
      },
    );

    test(
      'TEST 5: Offline no cache -> Retry -> still offline -> remain on Subject screen',
      () async {
        // First try
        useCase.mockCachedResponse = const Right([]);
        useCase.mockCallResponse = const Left(
          CacheFailure(message: 'OFFLINE_FALLBACK'),
        );
        await cubit.fetchSessions('token123', 'classB');

        // Retry
        await cubit.fetchSessions('token123', 'classB');

        expect(cubit.state, isA<ShowSessionsOfflineFallback>());
      },
    );

    test(
      'TEST 6: Offline no cache -> Retry after internet returns -> fetch correct class_id -> display Subjects',
      () async {
        // First try (Offline)
        useCase.mockCachedResponse = const Right([]);
        useCase.mockCallResponse = const Left(
          CacheFailure(message: 'OFFLINE_FALLBACK'),
        );
        await cubit.fetchSessions('token123', 'classB');

        // Retry (Online)
        useCase.mockCallResponse = Right([sessionB]);
        await cubit.fetchSessions('token123', 'classB');

        expect(cubit.state, isA<ShowSessionsSuccess>());
        expect(
          (cubit.state as ShowSessionsSuccess).sessions.first.id,
          'sessionB',
        );
      },
    );
  });
}
