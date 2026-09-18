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
  Either<Failure, Map<String, dynamic>>? mockResponse;

  FakeGetQuizStudentsUseCase() : super(FakeAttendanceRepository());

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(
    String sessionId, {
    String search = '',
    String gradingStatus = 'all',
  }) async {
    if (mockResponse != null) {
      return mockResponse!;
    }
    return Left(ServerFailure(message: 'Unmocked response'));
  }
}

class FakeGetCachedQuizStudentsUseCase extends GetCachedQuizStudentsUseCase {
  Either<Failure, Map<String, dynamic>?>? mockResponse;

  FakeGetCachedQuizStudentsUseCase() : super(FakeAttendanceRepository());

  @override
  Future<Either<Failure, Map<String, dynamic>?>> call(String sessionId) async {
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
    String sessionId,
    String studentId,
    num grade,
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

  Map<String, dynamic> createMockStudents(List<String> names) {
    return {
      'data': {
        'grades': names
            .map(
              (n) => {
                'student_id': 'id_$n',
                'name': n,
                'student_code': 'code_$n',
                'email': '$n@test.com',
                'phone_number': '123',
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
    };
  }

  test('TEST 1 - Offline + Cache', () async {
    // Arrange
    fakeGetCachedQuizStudentsUseCase.mockResponse = Right(
      createMockStudents(['A', 'B', 'C']),
    );

    // Simulate API network failure due to offline
    fakeGetQuizStudentsUseCase.mockResponse = Left(
      CacheFailure(message: 'عذراً، لا تتوفر بيانات محفوظة محلياً.'),
    );

    // Act
    await cubit.fetchStudents('session_1');

    // Assert
    expect(cubit.state, isA<QuizGradesLoaded>());
    final state = cubit.state as QuizGradesLoaded;

    // Must be marked offline
    expect(state.isOffline, true);
    // Must NOT have pagination active from cache
    expect(state.pagination, isNull);
    // Students must be A, B, C
    expect(state.students.map((e) => e.name).toList(), ['A', 'B', 'C']);
  });

  test('TEST 2 - Offline + No Cache', () async {
    // Arrange
    fakeGetCachedQuizStudentsUseCase.mockResponse = const Right(null);
    fakeGetQuizStudentsUseCase.mockResponse = Left(
      CacheFailure(
        message:
            'لا توجد بيانات مخزنة لهذا الكويز حاليًا، يرجى الاتصال بالإنترنت أولًا.',
      ),
    );

    // Act
    await cubit.fetchStudents('session_1');

    // Assert
    expect(cubit.state, isA<QuizGradesError>());
    final state = cubit.state as QuizGradesError;
    // Verify the friendly message is emitted
    expect(
      state.message,
      'لا توجد بيانات مخزنة لهذا الكويز حاليًا، يرجى الاتصال بالإنترنت أولًا.',
    );
  });

  test('TEST 3 - Online Success', () async {
    // Arrange
    fakeGetCachedQuizStudentsUseCase.mockResponse = const Right(null);
    fakeGetQuizStudentsUseCase.mockResponse = Right(
      createMockStudents(['A', 'B', 'C']),
    );

    // Act
    await cubit.fetchStudents('session_1');

    // Assert
    var state = cubit.state as QuizGradesLoaded;
    expect(state.students.map((e) => e.name).toList(), ['A', 'B', 'C']);
    expect(state.isOffline, false);
    expect(state.pagination, isNull); // API V2 has no pagination
  });

  test('TEST 5 - Decimal Grade Updates (Online)', () async {
    // Arrange
    fakeGetCachedQuizStudentsUseCase.mockResponse = const Right(null);
    final mockData = createMockStudents(['A']);
    mockData['data']['grades'][0]['grade'] = 0.5; // Starts with 0.5
    fakeGetQuizStudentsUseCase.mockResponse = Right(mockData);

    // Act: Load Data
    await cubit.fetchStudents('session_1');
    var state = cubit.state as QuizGradesLoaded;
    expect(state.students[0].grade, 0.5);

    // Act: Update Grade to 1.55
    await cubit.updateGrade(state.students[0].studentId, 1.55);

    // Check that state updated
    state = cubit.state as QuizGradesLoaded;
    expect(state.students[0].grade, 1.55);
  });
}
