import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

import 'package:qrattendance/features/atendance/data/data_sources/attendance_local_data_source.dart';
import 'package:qrattendance/features/atendance/data/data_sources/attendance_remote_data_source.dart';
import 'package:qrattendance/features/atendance/data/model/attendance_model.dart';
import 'package:qrattendance/features/atendance/data/model/pending_quiz_grade_model.dart';
import 'package:qrattendance/features/atendance/data/repositories/attendance_repository_impl.dart';
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

void main() {
  late AttendanceRepositoryImpl repository;
  late FakeAttendanceLocalDataSource mockLocalDataSource;
  late FakeAttendanceRemoteDataSource mockRemoteDataSource;
  late FakeConnectivity mockConnectivity;

  setUp(() {
    mockConnectivity = FakeConnectivity();
    IOOverrides.global = MockIOOverrides(mockConnectivity);
    mockLocalDataSource = FakeAttendanceLocalDataSource();
    mockRemoteDataSource = FakeAttendanceRemoteDataSource();
    mockConnectivity = FakeConnectivity();
    repository = AttendanceRepositoryImpl(
      localDataSource: mockLocalDataSource,
      remoteDataSource: mockRemoteDataSource,
      connectivity: mockConnectivity,
    );
  });

  group('Offline Quiz Grades Bulk API & Queueing', () {
    test('Offline network failure creates pending grade', () async {
      mockConnectivity.isConnectedValue = false; // Offline

      final result = await repository.addOrUpdateQuizGrade(
        'session-1',
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

      // Still pending but marked with error so it skips next time
      expect(mockLocalDataSource.pendingGrades.length, 1);
      expect(
        mockLocalDataSource.pendingGrades['${sessionId}_$studentId']!.error,
        contains('must be a UUID'),
      );
    });
  });
}
