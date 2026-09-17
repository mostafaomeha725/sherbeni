import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qrattendance/core/error/failure.dart';
import 'package:qrattendance/features/atendance/domain/repositories/attendance_repository.dart';
import 'package:qrattendance/features/atendance/domain/use_cases/get_quiz_students_use_case.dart';
import 'package:qrattendance/features/atendance/domain/use_cases/update_quiz_grade_use_case.dart';
import 'package:qrattendance/features/atendance/presentation/cubit/quiz_grades/quiz_grades_cubit.dart';
import 'package:qrattendance/features/atendance/presentation/cubit/quiz_grades/quiz_grades_state.dart';

// -----------------------------------------------------------------------------
// FAKE USE CASES
// -----------------------------------------------------------------------------

class FakeAttendanceRepository implements AttendanceRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeGetQuizStudentsUseCase extends GetQuizStudentsUseCase {
  Either<Failure, Map<String, dynamic>> Function(int page)? mockResponse;

  FakeGetQuizStudentsUseCase() : super(FakeAttendanceRepository());

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(
    String sessionId,
    String quizTemplateId, {
    int page = 1,
    int limit = 10,
    String search = '',
    String gradingStatus = 'all',
  }) async {
    if (mockResponse != null) {
      return mockResponse!(page);
    }
    return Left(ServerFailure(message: 'Unmocked response'));
  }
}

class FakeGetCachedQuizStudentsUseCase extends GetCachedQuizStudentsUseCase {
  Either<Failure, Map<String, dynamic>?>? mockResponse;

  FakeGetCachedQuizStudentsUseCase() : super(FakeAttendanceRepository());

  @override
  Future<Either<Failure, Map<String, dynamic>?>> call(
    String sessionId,
    String quizTemplateId,
  ) async {
    if (mockResponse != null) {
      return mockResponse!;
    }
    return const Right(null);
  }
}

class FakeUpdateQuizGradeUseCase extends UpdateQuizGradeUseCase {
  Either<Failure, Map<String, dynamic>>? mockResponse;

  FakeUpdateQuizGradeUseCase() : super(FakeAttendanceRepository());

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(
    String quizAttemptId,
    num grade,
    String sessionId,
    String quizTemplateId,
  ) async {
    if (mockResponse != null) {
      return mockResponse!;
    }
    return Right({
      'data': {
        'grade': grade,
        'maxScore': 10,
        'percentage': (grade / 10) * 100,
        'grading_status': 'graded',
      },
    });
  }
}

// -----------------------------------------------------------------------------
// TESTS
// -----------------------------------------------------------------------------

void main() {
  late FakeGetQuizStudentsUseCase fakeGetQuizStudentsUseCase;
  late FakeGetCachedQuizStudentsUseCase fakeGetCachedQuizStudentsUseCase;
  late FakeUpdateQuizGradeUseCase fakeUpdateQuizGradeUseCase;
  late QuizGradesCubit cubit;

  setUp(() {
    fakeGetQuizStudentsUseCase = FakeGetQuizStudentsUseCase();
    fakeGetCachedQuizStudentsUseCase = FakeGetCachedQuizStudentsUseCase();
    fakeUpdateQuizGradeUseCase = FakeUpdateQuizGradeUseCase();

    cubit = QuizGradesCubit(
      fakeGetQuizStudentsUseCase,
      fakeGetCachedQuizStudentsUseCase,
      fakeUpdateQuizGradeUseCase,
    );
  });

  tearDown(() {
    cubit.close();
  });

  Map<String, dynamic> createMockStudents(
    List<String> names, {
    bool hasNextPage = false,
  }) {
    return {
      'data': {
        'students': names
            .map(
              (n) => {
                'student_id': 'id_$n',
                'name': n,
                'student_code': 'code_$n',
                'email': '$n@test.com',
                'phone': '123',
                'picture': null,
                'offline_status': 'online',
                'quiz_attempt_id': 'att_$n',
                'grading_status': 'graded',
                'grade': 10,
                'maxScore': 10,
                'percentage': 100,
              },
            )
            .toList(),
      },
      'pagination': {
        'hasNextPage': hasNextPage,
        'page': 1,
        'limit': 10,
        'totalPages': hasNextPage ? 2 : 1,
        'totalItems': hasNextPage ? 20 : names.length,
      },
    };
  }

  test('TEST 1 - Offline + Cache', () async {
    // Arrange
    fakeGetCachedQuizStudentsUseCase.mockResponse = Right(
      createMockStudents(['A', 'B', 'C'], hasNextPage: true),
    );

    // Simulate API network failure due to offline
    fakeGetQuizStudentsUseCase.mockResponse = (page) => Left(
      CacheFailure(
        message:
            'عذراً، لا تتوفر بيانات محفوظة محلياً لهذا الاختبار. يرجى التأكد من اتصالك بالإنترنت والمحاولة مجدداً.',
      ),
    );

    // Act
    await cubit.fetchStudents('session_1', 'template_1');

    // Assert
    expect(cubit.state, isA<QuizGradesLoaded>());
    final state = cubit.state as QuizGradesLoaded;

    // Must be marked offline
    expect(state.isOffline, true);
    // Must NOT have pagination active from cache
    expect(state.pagination, isNull);
    // Students must be A, B, C
    expect(state.students.map((e) => e.name).toList(), ['A', 'B', 'C']);

    // Attempt to fetch next page (should be blocked because pagination == null)
    cubit.fetchNextPage();
    // Verify no new fetch happened
    expect((cubit.state as QuizGradesLoaded).isFetchingMore, false);
  });

  test('TEST 2 - Offline + No Cache', () async {
    // Arrange
    fakeGetCachedQuizStudentsUseCase.mockResponse = const Right(null);
    fakeGetQuizStudentsUseCase.mockResponse = (page) => Left(
      CacheFailure(
        message:
            'لا توجد بيانات مخزنة لهذا الكويز حاليًا، يرجى الاتصال بالإنترنت أولًا.',
      ),
    );

    // Act
    await cubit.fetchStudents('session_1', 'template_1');

    // Assert
    expect(cubit.state, isA<QuizGradesError>());
    final state = cubit.state as QuizGradesError;
    // Verify the friendly message is emitted
    expect(
      state.message,
      'لا توجد بيانات مخزنة لهذا الكويز حاليًا، يرجى الاتصال بالإنترنت أولًا.',
    );
  });

  test('TEST 3 - Online Pagination Success', () async {
    // Arrange
    fakeGetCachedQuizStudentsUseCase.mockResponse = const Right(null);
    fakeGetQuizStudentsUseCase.mockResponse = (page) {
      if (page == 1) {
        return Right(createMockStudents(['A', 'B', 'C'], hasNextPage: true));
      } else if (page == 2) {
        return Right(createMockStudents(['D', 'E', 'F'], hasNextPage: false));
      }
      return Left(ServerFailure(message: 'Error'));
    };

    // Act
    await cubit.fetchStudents('session_1', 'template_1');

    // Assert Page 1
    var state = cubit.state as QuizGradesLoaded;
    expect(state.students.map((e) => e.name).toList(), ['A', 'B', 'C']);
    expect(state.isOffline, false);
    expect(state.pagination, isNotNull);
    expect(state.pagination!.hasNextPage, true);
    expect(state.isFetchingMore, false);

    // Act Page 2
    cubit.fetchNextPage();

    // Check loading state immediately
    state = cubit.state as QuizGradesLoaded;
    expect(state.isFetchingMore, true);

    // Wait for event loop to finish async call
    await Future.delayed(Duration.zero);

    // Assert Page 2 Appended
    state = cubit.state as QuizGradesLoaded;
    expect(state.students.map((e) => e.name).toList(), [
      'A',
      'B',
      'C',
      'D',
      'E',
      'F',
    ]);
    expect(state.isFetchingMore, false);
    expect(state.pagination!.hasNextPage, false);
  });

  test('TEST 4 - Page 2 Network Failure + Retry', () async {
    // Arrange
    fakeGetCachedQuizStudentsUseCase.mockResponse = const Right(null);

    int page2Attempts = 0;
    fakeGetQuizStudentsUseCase.mockResponse = (page) {
      if (page == 1) {
        return Right(createMockStudents(['A', 'B', 'C'], hasNextPage: true));
      } else if (page == 2) {
        page2Attempts++;
        if (page2Attempts == 1) {
          // First attempt fails
          return Left(ServerFailure(message: 'Network error'));
        } else {
          // Second attempt succeeds
          return Right(createMockStudents(['D', 'E', 'F'], hasNextPage: false));
        }
      }
      return Left(ServerFailure(message: 'Error'));
    };

    // Act: Load Page 1
    await cubit.fetchStudents('session_1', 'template_1');
    var state = cubit.state as QuizGradesLoaded;
    expect(state.students.map((e) => e.name).toList(), ['A', 'B', 'C']);

    // Act: Request Page 2 (Fails)
    cubit.fetchNextPage();
    await Future.delayed(Duration.zero);

    // Assert: Existing students remain EXACTLY A B C, not duplicated
    state = cubit.state as QuizGradesLoaded;
    expect(state.students.map((e) => e.name).toList(), ['A', 'B', 'C']);
    // isFetchingMore becomes false
    expect(state.isFetchingMore, false);
    // hasNextPage remains true so we can retry
    expect(state.pagination!.hasNextPage, true);

    // Act: Retry Page 2 (Succeeds)
    cubit.fetchNextPage();
    await Future.delayed(Duration.zero);

    // Assert: Retry was successful, D E F appended exactly once
    state = cubit.state as QuizGradesLoaded;
    expect(state.students.map((e) => e.name).toList(), [
      'A',
      'B',
      'C',
      'D',
      'E',
      'F',
    ]);
    expect(page2Attempts, 2); // Proves page 2 was retried
  });

  test('TEST 5 - Decimal Grade Updates (Online)', () async {
    // Arrange
    fakeGetCachedQuizStudentsUseCase.mockResponse = const Right(null);
    fakeGetQuizStudentsUseCase.mockResponse = (page) {
      final mockData = createMockStudents(['A']);
      mockData['data']['students'][0]['grade'] = 0.5; // Starts with 0.5
      return Right(mockData);
    };

    // Act: Load Page 1
    await cubit.fetchStudents('session_1', 'template_1');
    var state = cubit.state as QuizGradesLoaded;
    expect(state.students[0].grade, 0.5);

    // Act: Update Grade to 1.55
    await cubit.updateGrade(state.students[0].quizAttemptId!, 1.55);

    // Check that state updated
    state = cubit.state as QuizGradesLoaded;
    expect(state.students[0].grade, 1.55);
  });
}
