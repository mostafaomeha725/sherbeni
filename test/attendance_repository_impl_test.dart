import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:qrattendance/features/atendance/data/data_sources/attendance_local_data_source.dart';
import 'package:qrattendance/features/atendance/data/data_sources/attendance_remote_data_source.dart';
import 'package:qrattendance/features/atendance/data/model/attendance_model.dart';
import 'package:qrattendance/features/atendance/data/model/pending_quiz_grade_model.dart';
import 'package:qrattendance/features/atendance/data/repositories/attendance_repository_impl.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class FakeConnectivity implements Connectivity {
  bool isConnectedValue = true;

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async {
    return isConnectedValue
        ? [ConnectivityResult.wifi]
        : [ConnectivityResult.none];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeAttendanceLocalDataSource implements AttendanceLocalDataSource {
  final Map<String, String> quizStudentsCache = {};
  final Map<String, PendingQuizGradeModel> pendingGrades = {};

  @override
  Future<List<AttendanceModel>> getOfflineAttendances() async => [];

  @override
  Future<String?> getQuizStudentsCache(String key) async =>
      quizStudentsCache[key];

  @override
  Future<void> saveQuizStudentsCache(String key, String jsonData) async {
    quizStudentsCache[key] = jsonData;
  }

  @override
  Future<List<PendingQuizGradeModel>> getPendingQuizGrades() async =>
      pendingGrades.values.toList();

  @override
  Future<PendingQuizGradeModel?> getPendingQuizGrade(
    String quizAttemptId,
  ) async => pendingGrades[quizAttemptId];

  @override
  Future<void> savePendingQuizGrade(PendingQuizGradeModel model) async {
    pendingGrades[model.quizAttemptId] = model;
  }

  @override
  Future<void> deletePendingQuizGrade(String quizAttemptId) async {
    pendingGrades.remove(quizAttemptId);
  }

  @override
  Future<void> markPendingQuizGradeAsFailed(
    String quizAttemptId,
    String error,
  ) async {
    if (pendingGrades.containsKey(quizAttemptId)) {
      pendingGrades[quizAttemptId]!.error = error;
    }
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeAttendanceRemoteDataSource implements AttendanceRemoteDataSource {
  Map<String, dynamic> mockQuizStudentsResponse = {};
  Map<String, dynamic> mockUpdateResponse = {};
  bool shouldThrowOnUpdate = false;
  bool shouldThrowOnGetQuizStudents = false;
  Future<void> Function()? onUpdateGradeCalled;

  @override
  Future<Map<String, dynamic>> getQuizStudents(
    String sessionId,
    String quizTemplateId,
    int page,
    int limit,
    String search,
    String gradingStatus,
  ) async {
    if (shouldThrowOnGetQuizStudents) {
      throw Exception('Network error');
    }
    return mockQuizStudentsResponse;
  }

  @override
  Future<Map<String, dynamic>> updateQuizGrade(
    String quizAttemptId,
    num grade,
  ) async {
    if (onUpdateGradeCalled != null) {
      await onUpdateGradeCalled!();
    }
    if (shouldThrowOnUpdate) {
      throw Exception('Network error');
    }
    return mockUpdateResponse;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late AttendanceRepositoryImpl repository;
  late FakeAttendanceLocalDataSource localDataSource;
  late FakeAttendanceRemoteDataSource remoteDataSource;
  late FakeConnectivity connectivity;

  setUp(() {
    localDataSource = FakeAttendanceLocalDataSource();
    remoteDataSource = FakeAttendanceRemoteDataSource();
    connectivity = FakeConnectivity();
    repository = AttendanceRepositoryImpl(
      remoteDataSource: remoteDataSource,
      localDataSource: localDataSource,
      connectivity: connectivity,
    );
  });

  Map<String, dynamic> createMockStudents(List<Map<String, dynamic>> students) {
    return {
      'status': true,
      'data': {'students': students},
    };
  }

  test(
    'TEST 1 - Offline grade persists after reconnect (Cache Consistency)',
    () async {
      // 1. Initial State (cache = grade 1)
      final cacheKey = 'quiz_students_s1_t1';
      final initialData = createMockStudents([
        {
          'quiz_attempt_id': 'att_1',
          'student_id': 'stud_1',
          'grade': 1,
          'maxScore': 2,
          'percentage': 50,
        },
      ]);
      localDataSource.quizStudentsCache[cacheKey] = jsonEncode(initialData);

      // 2. Go Offline, update grade to 1.55
      connectivity.isConnectedValue = false;
      await repository.updateQuizGrade('att_1', 1.55, 's1', 't1');

      // Assert offline state
      expect(localDataSource.pendingGrades.containsKey('att_1'), true);
      expect(localDataSource.pendingGrades['att_1']!.grade, 1.55);

      final updatedCache = jsonDecode(
        localDataSource.quizStudentsCache[cacheKey]!,
      );
      expect(updatedCache['data']['students'][0]['grade'], 1.55);

      // 3. Reconnect and fetch API (Simulating the race condition where API returns old grade 1)
      connectivity.isConnectedValue = true;
      remoteDataSource.mockQuizStudentsResponse =
          initialData; // API returns grade 1

      final fetchResult = await repository.getQuizStudents(
        's1',
        't1',
        1,
        10,
        '',
        'all',
      );

      // 4. Verify that repository correctly applied pending grade to the API response
      fetchResult.fold((l) => fail('Should not fail'), (data) {
        expect(data['data']['students'][0]['grade'], 1.55);
      });

      // Verify cache was NOT overwritten with stale remote grade 1
      final finalCache = jsonDecode(
        localDataSource.quizStudentsCache[cacheKey]!,
      );
      expect(finalCache['data']['students'][0]['grade'], 1.55);
    },
  );

  test('TEST 2 - Successful sync must not restore old grade', () async {
    // Given
    localDataSource.pendingGrades['att_1'] = PendingQuizGradeModel(
      quizAttemptId: 'att_1',
      studentId: 'stud_1',
      sessionId: 's1',
      quizTemplateId: 't1',
      grade: 1.55,
    );

    final cacheKey = 'quiz_students_s1_t1';
    localDataSource.quizStudentsCache[cacheKey] = jsonEncode(
      createMockStudents([
        {'quiz_attempt_id': 'att_1', 'grade': 1, 'maxScore': 2},
      ]),
    );

    // Remote responds with successful 1.55
    remoteDataSource.mockUpdateResponse = {
      'status': true,
      'data': {
        'grade': 1.55,
        'maxScore': 2,
        'percentage': 77.5,
        'grading_status': 'graded',
      },
    };

    // Act
    await repository.syncOfflineData();

    // Assert
    expect(localDataSource.pendingGrades.containsKey('att_1'), false);
    final cache = jsonDecode(localDataSource.quizStudentsCache[cacheKey]!);
    expect(cache['data']['students'][0]['grade'], 1.55);
    expect(cache['data']['students'][0]['percentage'], 77.5);
  });

  test('TEST 3 - Failed sync keeps pending grade', () async {
    // Given
    localDataSource.pendingGrades['att_1'] = PendingQuizGradeModel(
      quizAttemptId: 'att_1',
      studentId: 'stud_1',
      sessionId: 's1',
      quizTemplateId: 't1',
      grade: 1.55,
    );

    remoteDataSource.shouldThrowOnUpdate = true;

    // Act
    await repository.syncOfflineData();

    // Assert
    expect(
      localDataSource.pendingGrades.containsKey('att_1'),
      true,
    ); // Still pending
  });

  test(
    'TEST 4 - Race condition protection (User updates offline while sync is in flight)',
    () async {
      // Given
      localDataSource.pendingGrades['att_1'] = PendingQuizGradeModel(
        quizAttemptId: 'att_1',
        studentId: 'stud_1',
        sessionId: 's1',
        quizTemplateId: 't1',
        grade: 1, // Syncing grade 1
      );

      remoteDataSource.mockUpdateResponse = {
        'data': {'grade': 1, 'maxScore': 2},
      };

      // Simulate user modifying grade to 2.25 while sync is in flight
      remoteDataSource.onUpdateGradeCalled = () async {
        localDataSource.pendingGrades['att_1'] = PendingQuizGradeModel(
          quizAttemptId: 'att_1',
          studentId: 'stud_1',
          sessionId: 's1',
          quizTemplateId: 't1',
          grade: 2.25, // New grade
        );
      };

      // Act
      await repository.syncOfflineData();

      // Assert
      expect(localDataSource.pendingGrades.containsKey('att_1'), true);
      expect(
        localDataSource.pendingGrades['att_1']!.grade,
        2.25,
      ); // Kept the newer pending
    },
  );

  test('TEST 5 - Decimal preservation', () async {
    connectivity.isConnectedValue = false;
    final cacheKey = 'quiz_students_s1_t1';
    localDataSource.quizStudentsCache[cacheKey] = jsonEncode(
      createMockStudents([
        {'quiz_attempt_id': 'att_1', 'grade': 1, 'maxScore': 2},
      ]),
    );

    // Update offline
    await repository.updateQuizGrade('att_1', 1.55, 's1', 't1');

    expect(localDataSource.pendingGrades['att_1']!.grade, 1.55);

    // Sync online
    remoteDataSource.mockUpdateResponse = {
      'data': {'grade': 1.55, 'maxScore': 2},
    };
    await repository.syncOfflineData();

    final cache = jsonDecode(localDataSource.quizStudentsCache[cacheKey]!);
    expect(cache['data']['students'][0]['grade'], 1.55); // Maintained perfectly
  });

  test(
    'TEST 6 - Online update overwrites in-flight sync (delete pending)',
    () async {
      connectivity.isConnectedValue = true;
      final cacheKey = 'quiz_students_s1_t1';
      localDataSource.quizStudentsCache[cacheKey] = jsonEncode(
        createMockStudents([
          {'quiz_attempt_id': 'att_1', 'grade': 1, 'maxScore': 2},
        ]),
      );

      // Given there is a stale pending grade (e.g. 1)
      localDataSource.pendingGrades['att_1'] = PendingQuizGradeModel(
        quizAttemptId: 'att_1',
        studentId: 'stud_1',
        sessionId: 's1',
        quizTemplateId: 't1',
        grade: 1,
      );

      // User performs online update to 2
      remoteDataSource.mockUpdateResponse = {
        'data': {'grade': 2, 'maxScore': 2},
      };

      await repository.updateQuizGrade('att_1', 2, 's1', 't1');

      // Assert the obsolete pending grade was deleted
      expect(localDataSource.pendingGrades.containsKey('att_1'), false);

      // Simulating the delayed in-flight sync finishing now
      // It will encounter currentPending == null and skip cache overwrite
    },
  );
  void setupSearchCache() {
    connectivity.isConnectedValue = false; // Offline
    remoteDataSource.shouldThrowOnGetQuizStudents = true;
    final cacheKey = 'quiz_students_s1_t1';
    localDataSource.quizStudentsCache[cacheKey] = jsonEncode(
      createMockStudents([
        {
          'quiz_attempt_id': 'att_1',
          'name': 'Ahmed',
          'studentCode': '100',
          'phone': '010',
          'grading_status': 'graded',
        },
        {
          'quiz_attempt_id': 'att_2',
          'name': 'Mohamed',
          'studentCode': '200',
          'phone': '011',
          'grading_status': 'unknown',
        },
        {
          'quiz_attempt_id': 'att_3',
          'name': 'Ahmed Ali',
          'studentCode': '300',
          'phone': '012',
          'grading_status': 'unknown',
        },
        {
          'quiz_attempt_id': 'att_4',
          'name': 'Ali',
          'studentCode': '400',
          'phone': '013',
          'grading_status': 'graded',
        },
      ]),
    );
  }

  test('TEST 7 - Offline All uses default cache', () async {
    setupSearchCache();
    final result = await repository.getQuizStudents(
      's1',
      't1',
      1,
      10,
      '',
      'all',
    );
    final data = result.getOrElse(() => {});
    expect((data['data']['students'] as List).length, 4);
  });

  test('TEST 8 - Offline Graded uses default cache', () async {
    setupSearchCache();
    final result = await repository.getQuizStudents(
      's1',
      't1',
      1,
      10,
      '',
      'graded',
    );
    final data = result.getOrElse(() => {});
    expect((data['data']['students'] as List).length, 2);
  });

  test('TEST 9 - Offline Not Graded uses default cache', () async {
    setupSearchCache();
    final result = await repository.getQuizStudents(
      's1',
      't1',
      1,
      10,
      '',
      'unknown',
    );
    final data = result.getOrElse(() => {});
    expect((data['data']['students'] as List).length, 2);
  });

  test('TEST 10 - Offline search by name', () async {
    setupSearchCache();
    final result = await repository.getQuizStudents(
      's1',
      't1',
      1,
      10,
      'Ahmed',
      'all',
    );
    final data = result.getOrElse(() => {});
    expect((data['data']['students'] as List).length, 2); // Ahmed, Ahmed Ali
  });

  test('TEST 11 - Offline search by student code', () async {
    setupSearchCache();
    final result = await repository.getQuizStudents(
      's1',
      't1',
      1,
      10,
      '200',
      'all',
    );
    final data = result.getOrElse(() => {});
    expect((data['data']['students'] as List).length, 1); // Mohamed
  });

  test('TEST 12 - Offline search by phone/number', () async {
    setupSearchCache();
    final result = await repository.getQuizStudents(
      's1',
      't1',
      1,
      10,
      '012',
      'all',
    );
    final data = result.getOrElse(() => {});
    expect((data['data']['students'] as List).length, 1); // Ahmed Ali
  });

  test('TEST 13 - Offline search + Graded', () async {
    setupSearchCache();
    final result = await repository.getQuizStudents(
      's1',
      't1',
      1,
      10,
      'Ahmed',
      'graded',
    );
    final data = result.getOrElse(() => {});
    expect((data['data']['students'] as List).length, 1); // Ahmed
  });

  test('TEST 14 - Offline search + Not Graded', () async {
    setupSearchCache();
    final result = await repository.getQuizStudents(
      's1',
      't1',
      1,
      10,
      'Ahmed',
      'unknown',
    );
    final data = result.getOrElse(() => {});
    expect((data['data']['students'] as List).length, 1); // Ahmed Ali
  });

  test('TEST 15 - Switching search/filter combinations', () async {
    setupSearchCache();
    // 1. All + empty search
    var result = await repository.getQuizStudents('s1', 't1', 1, 10, '', 'all');
    expect((result.getOrElse(() => {})['data']['students'] as List).length, 4);

    // 2. Search Ahmed
    result = await repository.getQuizStudents(
      's1',
      't1',
      1,
      10,
      'Ahmed',
      'all',
    );
    expect((result.getOrElse(() => {})['data']['students'] as List).length, 2);

    // 3. Graded + Ahmed
    result = await repository.getQuizStudents(
      's1',
      't1',
      1,
      10,
      'Ahmed',
      'graded',
    );
    expect((result.getOrElse(() => {})['data']['students'] as List).length, 1);

    // 4. Clear search
    result = await repository.getQuizStudents('s1', 't1', 1, 10, '', 'graded');
    expect((result.getOrElse(() => {})['data']['students'] as List).length, 2);

    // 5. All
    result = await repository.getQuizStudents('s1', 't1', 1, 10, '', 'all');
    expect((result.getOrElse(() => {})['data']['students'] as List).length, 4);
  });

  test('TEST 16 - No cache while offline returns friendly error', () async {
    connectivity.isConnectedValue = false; // Offline
    remoteDataSource.shouldThrowOnGetQuizStudents = true;
    final result = await repository.getQuizStudents(
      's1',
      't2',
      1,
      10,
      'Ahmed',
      'all',
    );
    expect(result.isLeft(), true);
    result.fold(
      (l) => expect(
        l.message.contains(
          'عذراً، لا تتوفر بيانات محفوظة محلياً لهذا الاختبار.',
        ),
        true,
      ),
      (r) => fail('Should fail'),
    );
  });

  test(
    'TEST 17 - Offline filtering never modifies the default cache',
    () async {
      setupSearchCache();
      await repository.getQuizStudents('s1', 't1', 1, 10, 'Ahmed', 'graded');
      // Verify cache is still full 4 students
      final cacheKey = 'quiz_students_s1_t1';
      final cached = jsonDecode(localDataSource.quizStudentsCache[cacheKey]!);
      expect((cached['data']['students'] as List).length, 4);
    },
  );

  test('TEST 18 - Offline filtering disables pagination', () async {
    setupSearchCache();
    final result = await repository.getQuizStudents(
      's1',
      't1',
      1,
      10,
      'Ahmed',
      'all',
    );
    final data = result.getOrElse(() => {});
    expect(data['pagination']['has_next_page'], false);
    expect(data['pagination']['current_page'], 1);
    expect(data['pagination']['last_page'], 1);
  });

  test(
    'TEST 19 - Online API errors are not converted into cache results',
    () async {
      setupSearchCache();
      connectivity.isConnectedValue = true; // Online
      remoteDataSource.shouldThrowOnGetQuizStudents =
          true; // API fails with 500/network error

      final result = await repository.getQuizStudents(
        's1',
        't1',
        1,
        10,
        'Ahmed',
        'all',
      );

      // Because it's online, it should NOT fallback to cache, it should return the server failure
      expect(result.isLeft(), true);
      result.fold(
        (l) => expect(l.message, 'Network error'),
        (r) => fail('Should fail'),
      );
    },
  );
}
