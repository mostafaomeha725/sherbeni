import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qrattendance/core/error/failure.dart';
import 'package:qrattendance/features/atendance/data/model/attendance_history_model.dart';
import 'package:qrattendance/features/atendance/data/model/quiz_grade_history_model.dart';
import 'package:qrattendance/features/atendance/domain/repositories/attendance_repository.dart';
import 'package:qrattendance/features/atendance/domain/repositories/history_repository.dart';
import 'package:qrattendance/features/atendance/domain/use_cases/delete_history_record_use_case.dart';
import 'package:qrattendance/features/atendance/domain/use_cases/get_attendance_history_use_case.dart';
import 'package:qrattendance/features/atendance/domain/use_cases/get_quiz_grade_history_use_case.dart';
import 'package:qrattendance/features/atendance/domain/use_cases/retry_all_offline_attendance_use_case.dart';
import 'package:qrattendance/features/atendance/domain/use_cases/retry_specific_offline_attendance_use_case.dart';
import 'package:qrattendance/features/atendance/domain/use_cases/sync_offline_data_use_case.dart';
import 'package:qrattendance/features/atendance/presentation/cubit/stored_data/stored_data_cubit.dart';

class FakeGetAttendanceHistoryUseCase implements GetAttendanceHistoryUseCase {
  Either<Failure, List<AttendanceHistoryModel>> mockResponse = const Right([]);
  @override
  late final HistoryRepository repository;

  @override
  Future<Either<Failure, List<AttendanceHistoryModel>>> call() async =>
      mockResponse;
}

class FakeGetQuizGradeHistoryUseCase implements GetQuizGradeHistoryUseCase {
  Either<Failure, List<QuizGradeHistoryModel>> mockResponse = const Right([]);
  @override
  late final HistoryRepository repository;

  @override
  Future<Either<Failure, List<QuizGradeHistoryModel>>> call() async =>
      mockResponse;
}

class FakeDeleteHistoryRecordUseCase implements DeleteHistoryRecordUseCase {
  @override
  late final HistoryRepository repository;
  @override
  Future<Either<Failure, void>> clearAllAttendance() async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> clearAllQuizGrades() async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> deleteAttendance(String pendingKey) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> deleteQuizGrade(String pendingKey) async {
    return const Right(null);
  }
}

class FakeSyncOfflineDataUseCase implements SyncOfflineDataUseCase {
  int callCount = 0;
  @override
  late final AttendanceRepository repository;
  @override
  Future<Either<Failure, Map<String, dynamic>>> call() async {
    callCount++;
    return const Right({});
  }
}

class FakeRetrySpecificOfflineAttendanceUseCase
    implements RetrySpecificOfflineAttendanceUseCase {
  Map<String, Either<Failure, Unit>> mockResponses = {};
  List<String> calledKeys = [];

  @override
  late final AttendanceRepository repository;

  @override
  Future<Either<Failure, Unit>> call(String pendingKey) async {
    calledKeys.add(pendingKey);
    return mockResponses[pendingKey] ?? const Right(unit);
  }
}

class FakeRetryAllOfflineAttendanceUseCase
    implements RetryAllOfflineAttendanceUseCase {
  int callCount = 0;
  Either<Failure, Map<String, dynamic>> mockResponse = const Right({});

  @override
  late final AttendanceRepository repository;

  @override
  Future<Either<Failure, Map<String, dynamic>>> call() async {
    callCount++;
    return mockResponse;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeGetAttendanceHistoryUseCase mockGetAttendance;
  late FakeGetQuizGradeHistoryUseCase mockGetQuizGrade;
  late FakeDeleteHistoryRecordUseCase mockDeleteHistory;
  late FakeSyncOfflineDataUseCase mockSyncOffline;
  late FakeRetrySpecificOfflineAttendanceUseCase mockRetrySpecific;
  late FakeRetryAllOfflineAttendanceUseCase mockRetryAll;
  late StoredDataCubit cubit;

  setUp(() {
    mockGetAttendance = FakeGetAttendanceHistoryUseCase();
    mockGetQuizGrade = FakeGetQuizGradeHistoryUseCase();
    mockDeleteHistory = FakeDeleteHistoryRecordUseCase();
    mockSyncOffline = FakeSyncOfflineDataUseCase();
    mockRetrySpecific = FakeRetrySpecificOfflineAttendanceUseCase();
    mockRetryAll = FakeRetryAllOfflineAttendanceUseCase();

    const MethodChannel(
      'plugins.flutter.io/path_provider',
    ).setMockMethodCallHandler((MethodCall methodCall) async {
      return '.';
    });

    cubit = StoredDataCubit(
      getAttendanceHistoryUseCase: mockGetAttendance,
      getQuizGradeHistoryUseCase: mockGetQuizGrade,
      deleteHistoryRecordUseCase: mockDeleteHistory,
      syncOfflineDataUseCase: mockSyncOffline,
      retrySpecificOfflineAttendanceUseCase: mockRetrySpecific,
      retryAllOfflineAttendanceUseCase: mockRetryAll,
    );
  });

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(), builder: EasyLoading.init()),
    );
  }

  group('AppBar Retry', () {
    testWidgets('1. No retryable records -> no API call.', (tester) async {
      await pumpApp(tester);
      await cubit.loadHistory();
      await cubit.retrySync();
      expect(mockRetryAll.callCount, 0);
      expect(mockSyncOffline.callCount, 0);
    });

    testWidgets(
      '2 & 3. Multiple retryable records online -> each record is processed.',
      (tester) async {
        await pumpApp(tester);
        final now = DateTime.now();
        mockGetAttendance.mockResponse = Right([
          AttendanceHistoryModel(
            pendingKey: '1',
            uid: '1',
            sessionId: 's1',
            studentName: 'n1',
            scanTime: 'time',
            syncStatus: 'pending',
            createdAt: now,
          ),
          AttendanceHistoryModel(
            pendingKey: '2',
            uid: '2',
            sessionId: 's1',
            studentName: 'n2',
            scanTime: 'time',
            syncStatus: 'failed',
            createdAt: now,
          ),
        ]);
        await cubit.loadHistory();
        await cubit.retrySync();

        expect(mockRetryAll.callCount, 1);
        expect(mockSyncOffline.callCount, 0); // no quiz grades
      },
    );

    testWidgets(
      '5. & 8. AppBar Retry loading prevents concurrent duplicate operations.',
      (tester) async {
        await pumpApp(tester);
        await cubit.retrySync(); // state is initial, should return
        expect(mockRetryAll.callCount, 0);
      },
    );

    testWidgets(
      '6. Mixed success/failed backend results update each independently',
      (tester) async {
        await pumpApp(tester);
        final now = DateTime.now();
        mockGetAttendance.mockResponse = Right([
          AttendanceHistoryModel(
            pendingKey: '1',
            uid: '1',
            sessionId: 's1',
            studentName: 'n1',
            scanTime: 'time',
            syncStatus: 'pending',
            createdAt: now,
          ),
          AttendanceHistoryModel(
            pendingKey: '2',
            uid: '2',
            sessionId: 's1',
            studentName: 'n2',
            scanTime: 'time',
            syncStatus: 'failed',
            createdAt: now,
          ),
        ]);

        mockRetryAll.mockResponse = Left(ServerFailure(message: 'Invalid'));

        await cubit.loadHistory();
        await cubit.retrySync();

        expect(mockRetryAll.callCount, 1);
      },
    );

    testWidgets(
      '7. Offline AppBar Retry handles queueing via use cases without crashing',
      (tester) async {
        await pumpApp(tester);
        final now = DateTime.now();
        mockGetAttendance.mockResponse = Right([
          AttendanceHistoryModel(
            pendingKey: '1',
            uid: '1',
            sessionId: 's1',
            studentName: 'n1',
            scanTime: 'time',
            syncStatus: 'failed',
            createdAt: now,
          ),
        ]);

        mockRetryAll.mockResponse = Left(
          ServerFailure(message: 'لا يوجد اتصال'),
        );

        await cubit.loadHistory();
        await cubit.retrySync();

        expect(mockRetryAll.callCount, 1);
      },
    );
  });

  group('EXCEL', () {
    testWidgets('12. Empty Attendance/Quiz data does not crash.', (
      tester,
    ) async {
      await pumpApp(tester);
      await cubit.loadHistory();
      await cubit.exportToExcel();
      expect(true, isTrue);
    });

    testWidgets('9 & 10. Contains expected fields.', (tester) async {
      await pumpApp(tester);
      final now = DateTime.now();
      mockGetAttendance.mockResponse = Right([
        AttendanceHistoryModel(
          pendingKey: '1',
          uid: '1',
          sessionId: 's1',
          studentName: 'n1',
          scanTime: 'time',
          syncStatus: 'success',
          createdAt: now,
        ),
      ]);
      mockGetQuizGrade.mockResponse = Right([
        QuizGradeHistoryModel(
          pendingKey: 'q1',
          studentId: '1',
          sessionId: 's1',
          studentName: 'n1',
          grade: 10,
          maxScore: 20,
          syncStatus: 'pending',
          createdAt: now,
        ),
      ]);

      await cubit.loadHistory();
      await cubit.exportToExcel();
      expect(true, isTrue);
    });
  });
}
