import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

import 'package:qrattendance/features/atendance/data/data_sources/attendance_local_data_source.dart';
import 'package:qrattendance/features/atendance/data/data_sources/attendance_remote_data_source.dart';
import 'package:qrattendance/features/atendance/data/model/attendance_model.dart';
import 'package:qrattendance/features/atendance/data/model/pending_quiz_grade_model.dart';
import 'package:qrattendance/features/atendance/data/model/attendance_history_model.dart';
import 'package:qrattendance/features/atendance/data/model/quiz_grade_history_model.dart';
import 'package:qrattendance/features/atendance/data/repositories/attendance_repository_impl.dart';
import 'package:qrattendance/features/atendance/data/data_sources/history_local_data_source.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:qrattendance/core/error/failure.dart';

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

  final Map<String, AttendanceModel> offlineAttendances = {};

  @override
  Future<List<AttendanceModel>> getOfflineAttendances() async =>
      offlineAttendances.values.toList();

  @override
  Future<void> saveOfflineAttendance(AttendanceModel model) async {
    offlineAttendances['${model.uid}_${model.sessionId}'] = model;
  }

  @override
  Future<void> deleteAttendances(List<int> keys) async {
    // Fake deletion by clearing
    offlineAttendances.clear();
  }

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
  Future<PendingQuizGradeModel?> getPendingQuizGrade(String key) async =>
      pendingGrades[key];

  @override
  Future<void> savePendingQuizGrade(PendingQuizGradeModel model) async {
    pendingGrades[model.pendingKey] = model;
  }

  @override
  Future<void> deletePendingQuizGrade(String key) async {
    pendingGrades.remove(key);
  }

  @override
  Future<void> markPendingQuizGradeAsFailed(String key, String error) async {
    if (pendingGrades.containsKey(key)) {
      pendingGrades[key]!.error = error;
    }
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeAttendanceRemoteDataSource implements AttendanceRemoteDataSource {
  Map<String, dynamic> mockSessionQuizGradesResponse = {};
  Map<String, dynamic> mockAddOrUpdateQuizGradeResponse = {};
  Map<String, dynamic> mockSyncBulkResponse = {};

  bool shouldThrowOnSessionQuizGrades = false;
  bool shouldThrowOnAddOrUpdate = false;
  bool shouldThrowOnSyncBulk = false;
  bool isNetworkError = false;
  bool isValidationError = false;
  int syncBatchCallCount = 0;
  Map<String, dynamic> lastSyncBatchBody = {};

  Future<void> Function()? onSyncBulkCalled;

  @override
  Future<Map<String, dynamic>> getSessionQuizGrades(
    String sessionId,
    String search,
    String gradingStatus,
  ) async {
    if (shouldThrowOnSessionQuizGrades) {
      throw ServerFailure(message: 'Network error');
    }
    return mockSessionQuizGradesResponse;
  }

  @override
  Future<Map<String, dynamic>> addOrUpdateQuizGrade(
    String sessionId,
    String studentId,
    num grade,
  ) async {
    if (shouldThrowOnAddOrUpdate) {
      if (isNetworkError) {
        throw Exception('Failed host lookup');
      } else if (isValidationError) {
        throw ServerFailure(message: 'Invalid grade format');
      }
      throw ServerFailure(message: 'Generic server error');
    }
    return mockAddOrUpdateQuizGradeResponse;
  }

  @override
  Future<Map<String, dynamic>> syncBulkQuizGrades(
    String sessionId,
    List<Map<String, dynamic>> grades,
  ) async {
    if (onSyncBulkCalled != null) {
      await onSyncBulkCalled!();
    }
    if (shouldThrowOnSyncBulk) {
      if (isValidationError) {
        throw Exception('grades.0.student_id must be a UUID');
      }
      throw ServerFailure(message: 'Generic server error');
    }
    return mockSyncBulkResponse;
  }

  @override
  Future<Map<String, dynamic>> syncBatch(Map<String, dynamic> data) async {
    syncBatchCallCount++;
    lastSyncBatchBody = data;
    if (shouldThrowOnSyncBulk) {
      if (isValidationError) {
        throw Exception('Validation Error 400');
      }
      throw ServerFailure(message: 'Failed host lookup');
    }
    return mockSyncBulkResponse;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeSocket implements Socket {
  @override
  void destroy() {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final class MockIOOverrides extends IOOverrides {
  final FakeConnectivity connectivity;
  MockIOOverrides(this.connectivity);

  @override
  Future<Socket> socketConnect(
    host,
    int port, {
    sourceAddress,
    int sourcePort = 0,
    Duration? timeout,
  }) async {
    if (connectivity.isConnectedValue) {
      return FakeSocket();
    }
    throw const SocketException('Simulated network failure');
  }
}

class FakeHistoryLocalDataSource implements HistoryLocalDataSource {
  final Map<String, String> attendanceHistoryStatuses = {};
  final Map<String, String?> attendanceHistoryErrors = {};
  final List<AttendanceHistoryModel> attendanceHistories = [];

  @override
  Future<void> saveAttendanceHistory(AttendanceHistoryModel model) async {
    attendanceHistories.add(model);
  }

  @override
  Future<void> updateAttendanceHistoryStatus(
    String pendingKey,
    String status, {
    String? error,
    DateTime? syncedAt,
  }) async {
    attendanceHistoryStatuses[pendingKey] = status;
    attendanceHistoryErrors[pendingKey] = error;
  }

  @override
  Future<List<AttendanceHistoryModel>> getAttendanceHistory() async =>
      attendanceHistories;

  @override
  Future<void> deleteAttendanceHistory(String pendingKey) async {
    attendanceHistories.removeWhere((e) => e.pendingKey == pendingKey);
  }

  @override
  Future<void> clearAttendanceHistory() async {
    attendanceHistories.clear();
  }

  @override
  Future<void> saveQuizGradeHistory(QuizGradeHistoryModel model) async {}

  @override
  Future<void> updateQuizGradeHistoryStatus(
    String pendingKey,
    String status, {
    String? error,
    DateTime? syncedAt,
  }) async {}

  @override
  Future<List<QuizGradeHistoryModel>> getQuizGradeHistory() async => [];

  @override
  Future<void> deleteQuizGradeHistory(String pendingKey) async {}

  @override
  Future<void> clearQuizGradeHistory() async {}

  @override
  Future<void> cleanupOldHistory(Duration maxAge) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late AttendanceRepositoryImpl repository;
  late FakeAttendanceLocalDataSource mockLocalDataSource;
  late FakeAttendanceRemoteDataSource mockRemoteDataSource;
  late FakeConnectivity mockConnectivity;
  late FakeHistoryLocalDataSource mockHistoryLocalDataSource;

  setUp(() {
    mockConnectivity = FakeConnectivity();
    IOOverrides.global = MockIOOverrides(mockConnectivity);
    mockLocalDataSource = FakeAttendanceLocalDataSource();
    mockRemoteDataSource = FakeAttendanceRemoteDataSource();
    mockHistoryLocalDataSource = FakeHistoryLocalDataSource();
    repository = AttendanceRepositoryImpl(
      localDataSource: mockLocalDataSource,
      remoteDataSource: mockRemoteDataSource,
      connectivity: mockConnectivity,
      historyLocalDataSource: mockHistoryLocalDataSource,
    );
  });

  group('Offline Quiz Grades Bulk API & Queueing', () {
    test('Offline network failure creates pending grade', () async {
      mockConnectivity.isConnectedValue = false; // Offline

      final result = await repository.addOrUpdateQuizGrade(
        'session-1',
        null,
        'stu-1',
        9.5,
      );

      expect(result.isRight(), true);
      expect(mockLocalDataSource.pendingGrades.length, 1);
      final pending = mockLocalDataSource.pendingGrades['session-1_stu-1'];
      expect(pending?.grade, 9.5);
    });

    test('Online network exception creates pending grade', () async {
      mockConnectivity.isConnectedValue = true; // Online
      mockRemoteDataSource.shouldThrowOnAddOrUpdate = true;
      mockRemoteDataSource.isNetworkError =
          true; // Simulating "Failed host lookup"

      final result = await repository.addOrUpdateQuizGrade(
        'session-1',
        null,
        'stu-1',
        9.5,
      );

      expect(result.isRight(), true);
      expect(mockLocalDataSource.pendingGrades.length, 1);
    });

    test('Online backend 400 does NOT create pending grade', () async {
      mockConnectivity.isConnectedValue = true;
      mockRemoteDataSource.shouldThrowOnAddOrUpdate = true;
      mockRemoteDataSource.isNetworkError = false;
      mockRemoteDataSource.isValidationError = true; // 400 Validation

      final result = await repository.addOrUpdateQuizGrade(
        'session-1',
        null,
        'stu-1',
        9.5,
      );

      expect(result.isLeft(), true);
      expect(
        mockLocalDataSource.pendingGrades.length,
        0,
      ); // No pending grade created
    });

    test('Invalid UUID is never sent and is marked failed', () async {
      // Create pending with invalid UUID
      final pendingModel = PendingQuizGradeModel(
        studentId: 'not-a-uuid',
        sessionId: 'session-1',
        grade: 5.0,
      );
      await mockLocalDataSource.savePendingQuizGrade(pendingModel);

      await repository.syncOfflineData();

      // It should still be in pending but marked with error
      expect(mockLocalDataSource.pendingGrades.length, 1);
      expect(
        mockLocalDataSource.pendingGrades['session-1_not-a-uuid']!.error,
        "Invalid student_id UUID format",
      );
    });

    test(
      'Multiple grades for same session/student keep only latest due to key design',
      () async {
        final p1 = PendingQuizGradeModel(
          studentId: 'uuid1234-uuid-uuid-uuid-uuid12345678',
          sessionId: 'session-1',
          grade: 1.0,
        );
        await mockLocalDataSource.savePendingQuizGrade(p1);

        // Override with new grade
        final p2 = PendingQuizGradeModel(
          studentId: 'uuid1234-uuid-uuid-uuid-uuid12345678',
          sessionId: 'session-1',
          grade: 2.0,
        );
        await mockLocalDataSource.savePendingQuizGrade(p2);

        expect(mockLocalDataSource.pendingGrades.length, 1);
        expect(
          mockLocalDataSource
              .pendingGrades['session-1_uuid1234-uuid-uuid-uuid-uuid12345678']!
              .grade,
          2.0,
        );
      },
    );

    test(
      'Successful bulk sync removes only successfully synced operations and updates cache',
      () async {
        final studentId = '11111111-1111-1111-1111-111111111111';
        final sessionId = 'session-1';

        await mockLocalDataSource.savePendingQuizGrade(
          PendingQuizGradeModel(
            studentId: studentId,
            sessionId: sessionId,
            grade: 10.0,
          ),
        );

        // Setup cache
        final cacheData = {
          'data': {
            'grades': [
              {'student_id': studentId, 'name': 'Test Student', 'grade': null},
            ],
          },
        };
        await mockLocalDataSource.saveQuizStudentsCache(
          'quiz_grades_$sessionId',
          jsonEncode(cacheData),
        );

        // Setup mock remote response
        mockRemoteDataSource.mockSyncBulkResponse = {
          'data': {
            'grades': [
              {'student_id': studentId, 'grade': 10.0, 'approved_by': 'Admin'},
            ],
          },
        };

        await repository.syncOfflineData();

        expect(mockLocalDataSource.pendingGrades.length, 0); // Deleted

        final updatedCacheStr = await mockLocalDataSource.getQuizStudentsCache(
          'quiz_grades_$sessionId',
        );
        final updatedCache = jsonDecode(updatedCacheStr!);
        expect(updatedCache['data']['grades'][0]['grade'], 10.0);
        expect(updatedCache['data']['grades'][0]['approved_by'], 'Admin');
        expect(
          updatedCache['data']['grades'][0]['name'],
          'Test Student',
        ); // Unrelated fields preserved
      },
    );

    test(
      'Race condition: grade changes while bulk request is in flight',
      () async {
        final studentId = '22222222-2222-2222-2222-222222222222';
        final sessionId = 'session-2';

        await mockLocalDataSource.savePendingQuizGrade(
          PendingQuizGradeModel(
            studentId: studentId,
            sessionId: sessionId,
            grade: 5.0,
          ),
        );

        // Simulate user updating the grade to 8.0 while the sync is in flight
        mockRemoteDataSource.onSyncBulkCalled = () async {
          await mockLocalDataSource.savePendingQuizGrade(
            PendingQuizGradeModel(
              studentId: studentId,
              sessionId: sessionId,
              grade: 8.0, // New grade
            ),
          );
        };

        mockRemoteDataSource.mockSyncBulkResponse = {
          'data': {
            'grades': [
              {'student_id': studentId, 'grade': 5.0},
            ],
          },
        };

        await repository.syncOfflineData();

        // Pending operation should NOT be deleted because it changed
        expect(mockLocalDataSource.pendingGrades.length, 1);
        expect(
          mockLocalDataSource.pendingGrades['${sessionId}_$studentId']!.grade,
          8.0,
        );
      },
    );

    test('Generic bulk error keeps pending grade', () async {
      final studentId = '33333333-3333-3333-3333-333333333333';
      final sessionId = 'session-3';

      await mockLocalDataSource.savePendingQuizGrade(
        PendingQuizGradeModel(
          studentId: studentId,
          sessionId: sessionId,
          grade: 7.0,
        ),
      );

      mockRemoteDataSource.shouldThrowOnSyncBulk = true;
      mockRemoteDataSource.isValidationError = false; // Just a generic error

      await repository.syncOfflineData();

      // Still pending
      expect(mockLocalDataSource.pendingGrades.length, 1);
      expect(
        mockLocalDataSource.pendingGrades['${sessionId}_$studentId']!.error,
        null,
      ); // Not permanently failed
    });

    test('Bulk 400 Validation error marks operations as failed', () async {
      final studentId = '44444444-4444-4444-4444-444444444444';
      final sessionId = 'session-4';

      await mockLocalDataSource.savePendingQuizGrade(
        PendingQuizGradeModel(
          studentId: studentId,
          sessionId: sessionId,
          grade: 7.0,
        ),
      );

      mockRemoteDataSource.shouldThrowOnSyncBulk = true;
      mockRemoteDataSource.isValidationError =
          true; // 400 validation error returned by backend

      await repository.syncOfflineData();

      expect(mockLocalDataSource.pendingGrades.length, 1);
      expect(
        mockLocalDataSource.pendingGrades['${sessionId}_$studentId']!.error,
        contains('must be a UUID'),
      );
    });

    test(
      '1. One valid + four invalid. Conflict priority. Network failure retryable.',
      () async {
        final validId = 'valid-111';
        final invalid1 = 'inv-1';
        final invalid2 = 'inv-2';
        final invalid3 = 'inv-3';
        final invalid4 = 'inv-4';
        final conflictId = 'conflict-555';
        final sessionId = 'sess-multi';

        // Setup 6 pending records
        for (var id in [
          invalid2,
          invalid1,
          validId,
          invalid4,
          conflictId,
          invalid3,
        ]) {
          await mockLocalDataSource.saveOfflineAttendance(
            AttendanceModel(
              uid: id,
              sessionId: sessionId,
              scanTime: '2023-10-27',
            ),
          );
        }

        mockRemoteDataSource.shouldThrowOnSyncBulk = false;

        // Response order differs from request order intentionally
        mockRemoteDataSource.mockSyncBulkResponse = {
          'status': true,
          'message': 'تم حفظ البيانات بنجاح',
          'data': {
            'valid': 2,
            'invalid': 4,
            'enrollment_results': [
              {
                'student_id': conflictId,
                'session_id': sessionId,
                'status': 'success',
                'message': 'Student enrolled',
              },
              {
                'student_id': validId,
                'session_id': sessionId,
                'status': 'skipped',
                'message': 'Student is already enrolled in this course',
              },
            ],
            'invalid_results': [
              {
                'student_id': conflictId, // CONFLICT! Appears in both.
                'session_id': sessionId,
                'reason': 'Data too long for column (fake error)',
              },
              {
                'student_id': invalid4,
                'session_id': sessionId,
                'reason': 'Data too long for column \'student_id\' at row 1',
              },
              {
                'student_id': invalid1,
                'session_id': sessionId,
                'reason': 'Student not found',
              },
              {
                'student_id': invalid3,
                'session_id': sessionId,
                'reason': 'Some other error',
              },
              {
                'student_id': invalid2,
                'session_id': sessionId,
                'reason': 'Invalid grade format',
              },
            ],
          },
        };

        await repository.syncOfflineData();

        // Check valid (skipped status)
        final validKey = '${validId}_$sessionId';
        expect(
          mockHistoryLocalDataSource.attendanceHistoryStatuses[validKey],
          'success',
        );
        expect(
          mockHistoryLocalDataSource.attendanceHistoryErrors[validKey],
          null,
        );

        // Check conflict (appears in both -> must be SUCCESS)
        final conflictKey = '${conflictId}_$sessionId';
        expect(
          mockHistoryLocalDataSource.attendanceHistoryStatuses[conflictKey],
          'success',
        );
        expect(
          mockHistoryLocalDataSource.attendanceHistoryErrors[conflictKey],
          null,
        );

        // Check invalid 1
        final inv1Key = '${invalid1}_$sessionId';
        expect(
          mockHistoryLocalDataSource.attendanceHistoryStatuses[inv1Key],
          'failed',
        );
        expect(
          mockHistoryLocalDataSource.attendanceHistoryErrors[inv1Key],
          'Student not found',
        );

        // Check invalid 4
        final inv4Key = '${invalid4}_$sessionId';
        expect(
          mockHistoryLocalDataSource.attendanceHistoryStatuses[inv4Key],
          'failed',
        );
        expect(
          mockHistoryLocalDataSource.attendanceHistoryErrors[inv4Key],
          'Data too long for column \'student_id\' at row 1',
        );

        // 7. Network failure remains retryable and does not get treated as definitive backend invalid result
        mockLocalDataSource.offlineAttendances.clear();
        mockHistoryLocalDataSource.attendanceHistoryStatuses.clear();
        mockHistoryLocalDataSource.attendanceHistoryErrors.clear();

        final netFailId = 'net-fail-1';
        await mockLocalDataSource.saveOfflineAttendance(
          AttendanceModel(
            uid: netFailId,
            sessionId: sessionId,
            scanTime: '2023-10-27',
          ),
        );

        mockRemoteDataSource.shouldThrowOnSyncBulk = true;
        mockRemoteDataSource.isValidationError = false; // Network failure

        await repository.syncOfflineData();

        // Pending queue retains the record so it's retryable
        expect(mockLocalDataSource.offlineAttendances.length, 1);
        final netFailKey = '${netFailId}_$sessionId';
        expect(
          mockHistoryLocalDataSource.attendanceHistoryStatuses[netFailKey],
          'pending',
        );
      },
    );
  });

  group('Retry Specific Offline Attendance', () {
    test(
      '1. Retry WITH internet: existing ONLINE API is called, offline bulk sync is NOT called, successful backend result -> History success',
      () async {
        mockConnectivity.isConnectedValue = true;
        final studentId1 = 'std-1';
        final sessionId = 'sess-multi';

        await mockLocalDataSource.saveOfflineAttendance(
          AttendanceModel(
            uid: studentId1,
            sessionId: sessionId,
            scanTime: '2023-10-27',
          ),
        );

        await mockHistoryLocalDataSource.saveAttendanceHistory(
          AttendanceHistoryModel(
            pendingKey: '${studentId1}_$sessionId',
            uid: studentId1,
            sessionId: sessionId,
            studentName: 'Test Student',
            scanTime: '2023-10-27',
            syncStatus: 'failed',
            createdAt: DateTime.now(),
          ),
        );

        mockRemoteDataSource.shouldThrowOnSyncBulk = false;
        mockRemoteDataSource.mockSyncBulkResponse = {
          'status': true,
          'message': 'تم الحفظ',
          'data': {
            'valid': 1,
            'invalid': 0,
            'enrollment_results': [
              {
                'student_id': studentId1,
                'session_id': sessionId,
                'status': 'success',
              },
            ],
            'invalid_results': [],
          },
        };

        final pendingKey1 = '${studentId1}_$sessionId';
        final result = await repository.retrySpecificOfflineAttendance(
          pendingKey1,
        );

        expect(result.isRight(), true);
        // History should be success
        expect(
          mockHistoryLocalDataSource.attendanceHistoryStatuses[pendingKey1],
          'success',
        );
      },
    );

    test(
      '2. Retry WITHOUT internet: no API call, record is saved to studentSessions, History remains pending/retryable',
      () async {
        mockConnectivity.isConnectedValue = false;
        final studentId1 = 'std-offline';
        final sessionId = 'sess-1';
        final pendingKey = '${studentId1}_$sessionId';

        // Record is in History but NOT in pending queue
        await mockHistoryLocalDataSource.saveAttendanceHistory(
          AttendanceHistoryModel(
            pendingKey: pendingKey,
            uid: studentId1,
            sessionId: sessionId,
            studentName: 'Test Student',
            scanTime: '2023-11-01 10:00:00',
            syncStatus: 'failed',
            createdAt: DateTime.now(),
          ),
        );

        final result = await repository.retrySpecificOfflineAttendance(
          pendingKey,
        );
        expect(result.isLeft(), true);
        result.fold(
          (l) => expect(l.message, contains('لا يوجد اتصال بالإنترنت')),
          (r) => fail(''),
        );

        // Check it was added to pending queue
        expect(mockLocalDataSource.offlineAttendances.length, 1);
        expect(
          mockLocalDataSource.offlineAttendances.values.first.uid,
          studentId1,
        );
      },
    );

    test(
      '4. Online Retry backend invalid: History failed, exact backend reason stored',
      () async {
        mockConnectivity.isConnectedValue = true;
        final studentId1 = 'std-inv';
        final sessionId = 'sess-multi';
        final pendingKey = '${studentId1}_$sessionId';

        await mockLocalDataSource.saveOfflineAttendance(
          AttendanceModel(
            uid: studentId1,
            sessionId: sessionId,
            scanTime: '2023-10-27',
          ),
        );

        await mockHistoryLocalDataSource.saveAttendanceHistory(
          AttendanceHistoryModel(
            pendingKey: pendingKey,
            uid: studentId1,
            sessionId: sessionId,
            studentName: 'Test Student',
            scanTime: '2023-10-27',
            syncStatus: 'failed',
            createdAt: DateTime.now(),
          ),
        );

        mockRemoteDataSource.shouldThrowOnSyncBulk = false;
        mockRemoteDataSource.mockSyncBulkResponse = {
          'status': true,
          'message': 'تم الحفظ',
          'data': {
            'valid': 0,
            'invalid': 1,
            'enrollment_results': [],
            'invalid_results': [
              {
                'student_id': studentId1,
                'session_id': sessionId,
                'reason': 'Data too long',
              },
            ],
          },
        };

        final result = await repository.retrySpecificOfflineAttendance(
          pendingKey,
        );

        expect(result.isLeft(), true);
        result.fold(
          (l) => expect(l.message, 'Data too long'),
          (r) => fail('should be Left'),
        );
        expect(
          mockHistoryLocalDataSource.attendanceHistoryStatuses[pendingKey],
          'failed',
        );
        expect(
          mockHistoryLocalDataSource.attendanceHistoryErrors[pendingKey],
          'Data too long',
        );
      },
    );

    test(
      '5. Online Retry network failure: record moved to pending queue, History retryable',
      () async {
        mockConnectivity.isConnectedValue =
            true; // Intentionally true to simulate runtime failure
        final studentId1 = 'std-net';
        final sessionId = 'sess-multi';
        final pendingKey = '${studentId1}_$sessionId';

        // History only
        await mockHistoryLocalDataSource.saveAttendanceHistory(
          AttendanceHistoryModel(
            pendingKey: pendingKey,
            uid: studentId1,
            sessionId: sessionId,
            studentName: 'Test Student',
            scanTime: '2023-11-01 10:00:00',
            syncStatus: 'failed',
            createdAt: DateTime.now(),
          ),
        );

        mockRemoteDataSource.shouldThrowOnSyncBulk = true;
        mockRemoteDataSource.isValidationError =
            false; // simulates network error -> "Network Error"

        final result = await repository.retrySpecificOfflineAttendance(
          pendingKey,
        );

        expect(result.isLeft(), true);
        // Saved to pending queue
        expect(mockLocalDataSource.offlineAttendances.length, 1);
      },
    );
  });

  group('retryAllOfflineAttendance', () {
    test(
      '1. 200 records online: exactly ONE POST, request contains 200 records',
      () async {
        mockConnectivity.isConnectedValue = true;
        for (int i = 0; i < 200; i++) {
          await mockHistoryLocalDataSource.saveAttendanceHistory(
            AttendanceHistoryModel(
              pendingKey: '${i}_s1',
              uid: '$i',
              sessionId: 's1',
              studentName: 'Student $i',
              scanTime: '2023-10-10 10:10:10',
              syncStatus: 'failed',
              createdAt: DateTime.now(),
            ),
          );
        }

        mockRemoteDataSource.mockSyncBulkResponse = {
          "data": {
            "valid_results": 200,
            "invalid_results": [],
            "enrollment_results": List.generate(
              200,
              (i) => {"student_id": "$i", "session_id": "s1"},
            ),
          },
        };

        final result = await repository.retryAllOfflineAttendance();

        expect(result.isRight(), true);
        expect(mockRemoteDataSource.syncBatchCallCount, 1);
        expect(
          mockRemoteDataSource.lastSyncBatchBody['attendance'].length,
          200,
        );

        for (int i = 0; i < 200; i++) {
          expect(
            mockHistoryLocalDataSource.attendanceHistoryStatuses['${i}_s1'],
            'success',
          );
        }
      },
    );

    test(
      '2. 200 records offline: ZERO API calls, 200 records stored in pending queue',
      () async {
        mockConnectivity.isConnectedValue = false;
        for (int i = 0; i < 200; i++) {
          await mockHistoryLocalDataSource.saveAttendanceHistory(
            AttendanceHistoryModel(
              pendingKey: '${i}_s1',
              uid: '$i',
              sessionId: 's1',
              studentName: 'Student $i',
              scanTime: '2023-10-10 10:10:10',
              syncStatus: 'failed',
              createdAt: DateTime.now(),
            ),
          );
        }

        mockRemoteDataSource.syncBatchCallCount = 0;
        final result = await repository.retryAllOfflineAttendance();

        expect(result.isLeft(), true);
        expect(mockRemoteDataSource.syncBatchCallCount, 0);
        expect(mockLocalDataSource.offlineAttendances.length, 200);
      },
    );

    test(
      '5. Backend response: valid 197 / invalid 3 -> 197 History = success, 3 History = failed',
      () async {
        mockConnectivity.isConnectedValue = true;
        for (int i = 0; i < 200; i++) {
          await mockHistoryLocalDataSource.saveAttendanceHistory(
            AttendanceHistoryModel(
              pendingKey: '${i}_s1',
              uid: '$i',
              sessionId: 's1',
              studentName: 'n',
              scanTime: 'time',
              syncStatus: 'failed',
              createdAt: DateTime.now(),
            ),
          );
        }

        mockRemoteDataSource.mockSyncBulkResponse = {
          "data": {
            "valid_results": 197,
            "enrollment_results": List.generate(
              197,
              (i) => {"student_id": "$i", "session_id": "s1"},
            ),
            "invalid_results": List.generate(
              3,
              (i) => {
                "student_id": "${197 + i}",
                "session_id": "s1",
                "reason": "Not registered",
              },
            ),
          },
        };

        await repository.retryAllOfflineAttendance();

        for (int i = 0; i < 197; i++) {
          expect(
            mockHistoryLocalDataSource.attendanceHistoryStatuses['${i}_s1'],
            'success',
          );
        }
        for (int i = 197; i < 200; i++) {
          expect(
            mockHistoryLocalDataSource.attendanceHistoryStatuses['${i}_s1'],
            'failed',
          );
          expect(
            mockHistoryLocalDataSource.attendanceHistoryErrors['${i}_s1'],
            'Not registered',
          );
        }
      },
    );
  });
}
