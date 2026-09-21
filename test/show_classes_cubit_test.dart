import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qrattendance/core/error/failure.dart';
import 'package:qrattendance/features/atendance/domain/entities/session_entity.dart';
import 'package:qrattendance/features/atendance/domain/repositories/attendance_repository.dart';
import 'package:qrattendance/features/atendance/presentation/cubit/show_classes/show_classes_cubit.dart';

class FakeAttendanceRepository implements AttendanceRepository {
  Either<Failure, List<SessionEntity>>? mockCachedResponse;
  Either<Failure, List<SessionEntity>>? mockFetchResponse;

  String? lastCalledSubjectId;
  String? lastCalledClassId;

  @override
  Future<Either<Failure, List<SessionEntity>>> getCachedClasses({
    required String subjectId,
    required String classId,
  }) async {
    lastCalledSubjectId = subjectId;
    lastCalledClassId = classId;
    return mockCachedResponse ?? const Right([]);
  }

  @override
  Future<Either<Failure, List<SessionEntity>>> fetchClasses({
    required String subjectId,
    required String classId,
  }) async {
    lastCalledSubjectId = subjectId;
    lastCalledClassId = classId;
    return mockFetchResponse ?? const Right([]);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late ShowClassesCubit cubit;
  late FakeAttendanceRepository fakeRepository;

  setUp(() {
    fakeRepository = FakeAttendanceRepository();
    cubit = ShowClassesCubit(fakeRepository);
  });

  tearDown(() {
    cubit.close();
  });

  const subjectId = 'subject_1';
  const classIdA = 'class_A';
  const classIdB = 'class_B';

  final session1 = SessionEntity(
    id: 's1',
    title: 'Session 1',
    description: 'desc',
    courseId: 'c1',
    courseTitle: 'Course 1',
    startTime: '10:00',
    endTime: '12:00',
    status: 'ACTIVE',
    hasHomework: false,
    totalAttendance: 10,
    attendedCount: 8,
    lateCount: 2,
    hasQuiz: true,
  );

  test('1. Online + API returns sessions -> Sessions displayed', () async {
    fakeRepository.mockCachedResponse = const Left(
      CacheFailure(message: 'NO_CACHE_EXISTS'),
    );
    fakeRepository.mockFetchResponse = Right([session1]);

    expectLater(
      cubit.stream,
      emitsThrough(
        isA<ShowClassesSuccess>().having((s) => s.classes.length, 'length', 1),
      ),
    );

    await cubit.fetchClasses(subjectId, classIdA);
  });

  test(
    '2. & 3. Online + API returns [] -> "No Sessions Available" and persisted',
    () async {
      fakeRepository.mockCachedResponse = const Left(
        CacheFailure(message: 'NO_CACHE_EXISTS'),
      );
      fakeRepository.mockFetchResponse = const Right([]);

      expectLater(
        cubit.stream,
        emitsThrough(
          isA<ShowClassesSuccess>().having(
            (s) => s.classes.isEmpty,
            'isEmpty',
            true,
          ),
        ),
      );

      await cubit.fetchClasses(subjectId, classIdA);
      // Persisting is tested in data source test usually, but here we confirm Cubit handles [] properly.
    },
  );

  test(
    '4. Offline + existing cache with sessions -> cached sessions displayed',
    () async {
      fakeRepository.mockCachedResponse = Right([session1]);
      fakeRepository.mockFetchResponse = const Left(
        ServerFailure(message: 'Error'),
      );

      expectLater(
        cubit.stream,
        emitsThrough(
          isA<ShowClassesSuccess>().having(
            (s) => s.classes.first.id,
            'session id',
            's1',
          ),
        ),
      );

      await cubit.fetchClasses(subjectId, classIdA);
    },
  );

  test(
    '5. Offline + existing cache containing [] -> "No Sessions Available"',
    () async {
      fakeRepository.mockCachedResponse = const Right([]);
      fakeRepository.mockFetchResponse = const Left(
        ServerFailure(message: 'Error'),
      );

      expectLater(
        cubit.stream,
        emitsThrough(
          isA<ShowClassesSuccess>().having(
            (s) => s.classes.isEmpty,
            'isEmpty',
            true,
          ),
        ),
      );

      await cubit.fetchClasses(subjectId, classIdA);
    },
  );

  test('6. Offline + NO cache -> "No Offline Data Available"', () async {
    fakeRepository.mockCachedResponse = const Left(
      CacheFailure(message: 'NO_CACHE_EXISTS'),
    );
    fakeRepository.mockFetchResponse = const Left(
      CacheFailure(message: 'OFFLINE_FALLBACK'),
    );

    expectLater(cubit.stream, emitsThrough(isA<ShowClassesOfflineFallback>()));

    await cubit.fetchClasses(subjectId, classIdA);
  });

  test('8. Verify class-specific cache isolation still works', () async {
    fakeRepository.mockCachedResponse = Right([session1]);
    fakeRepository.mockFetchResponse = const Left(
      ServerFailure(message: 'Error'),
    );

    expectLater(
      cubit.stream,
      emitsThrough(
        isA<ShowClassesSuccess>().having(
          (s) => s.classes.first.id,
          'session id',
          's1',
        ),
      ),
    );

    await cubit.fetchClasses(subjectId, classIdB);

    expect(fakeRepository.lastCalledSubjectId, subjectId);
    expect(fakeRepository.lastCalledClassId, classIdB);
  });
}
