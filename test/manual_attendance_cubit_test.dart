// ignore_for_file: unused_import
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qrattendance/core/error/failure.dart';
import 'package:qrattendance/features/atendance/domain/entities/academic_class_entity.dart';
import 'package:qrattendance/features/atendance/domain/entities/manual_search_student_entity.dart';
import 'package:qrattendance/features/atendance/domain/entities/session_attendance_entity.dart';
import 'package:qrattendance/features/atendance/domain/entities/session_entity.dart';
import 'package:qrattendance/features/atendance/domain/entities/student_entity.dart';
import 'package:qrattendance/features/atendance/domain/repositories/attendance_repository.dart';
import 'package:qrattendance/features/atendance/domain/use_cases/record_online_attendance_use_case.dart';
import 'package:qrattendance/features/atendance/domain/use_cases/save_offline_attendance_use_case.dart';
import 'package:qrattendance/features/atendance/domain/use_cases/save_offline_search_use_case.dart';
import 'package:qrattendance/features/atendance/domain/use_cases/search_student_use_case.dart';
import 'package:qrattendance/features/atendance/domain/use_cases/bulk_search_students_use_case.dart';
import 'package:qrattendance/features/atendance/presentation/cubit/manual_attendance/manual_attendance_cubit.dart';

// ──────────────────────── Minimal Stub Repository ────────────────────────

class _FakeAttendanceRepo implements AttendanceRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// ──────────────────────── Fake Use Cases ────────────────────────

class FakeSearchStudentUseCase extends SearchStudentUseCase {
  FakeSearchStudentUseCase() : super(_FakeAttendanceRepo());

  Either<Failure, ManualSearchStudentEntity?> Function(String)? _handler;

  void setHandler(
    Either<Failure, ManualSearchStudentEntity?> Function(String) handler,
  ) {
    _handler = handler;
  }

  @override
  Future<Either<Failure, ManualSearchStudentEntity?>> call(String query) async {
    if (_handler != null) return _handler!(query);
    return const Right(null);
  }
}

class FakeRecordOnlineAttendanceUseCase extends RecordOnlineAttendanceUseCase {
  FakeRecordOnlineAttendanceUseCase() : super(_FakeAttendanceRepo());

  Either<Failure, String> Function(String uid, String sessionId)? _handler;

  void setHandler(
    Either<Failure, String> Function(String uid, String sessionId) handler,
  ) {
    _handler = handler;
  }

  @override
  Future<Either<Failure, String>> call({
    required String uid,
    required String sessionId,
  }) async {
    if (_handler != null) return _handler!(uid, sessionId);
    return const Right('success');
  }
}

class FakeSaveOfflineAttendanceUseCase extends SaveOfflineAttendanceUseCase {
  FakeSaveOfflineAttendanceUseCase() : super(_FakeAttendanceRepo());

  Either<Failure, String> Function(String uid, String sessionId)? _handler;

  void setHandler(
    Either<Failure, String> Function(String uid, String sessionId) handler,
  ) {
    _handler = handler;
  }

  @override
  Future<Either<Failure, String>> call({
    required String uid,
    required String sessionId,
    String? sessionName,
    String? scanTime,
  }) async {
    if (_handler != null) return _handler!(uid, sessionId);
    return const Right('saved');
  }
}

class FakeSaveOfflineSearchUseCase extends SaveOfflineSearchUseCase {
  FakeSaveOfflineSearchUseCase() : super(_FakeAttendanceRepo());

  @override
  Future<Either<Failure, String>> call({
    required String query,
    required String sessionId,
    required String sessionName,
  }) async {
    return const Right('saved');
  }
}

// ──────────────────────── Helpers ────────────────────────

class FakeBulkSearchStudentsUseCase extends BulkSearchStudentsUseCase {
  final Future<Either<Failure, List<ManualSearchStudentEntity>>> Function(List<String>)?
      mockCall;

  FakeBulkSearchStudentsUseCase({this.mockCall}) : super(_FakeAttendanceRepo());

  @override
  Future<Either<Failure, List<ManualSearchStudentEntity>>> call(
      List<String> queries) async {
    if (mockCall != null) {
      return mockCall!(queries);
    }
    return const Right([]);
  }
}

const _student = ManualSearchStudentEntity(
  studentId: '6ee74b01-1a43-46eb-b18-d6e0ca643c8a',
  studentName: 'Ahmed Ali',
  studentCode: '50991466',
  educationalLevel: 'الصف الثالث الثانوي - علمي علوم',
  status: 'active',
  email: 'ahmed@example.com',
  phone: '01233123457',
  parentPhone: '01233123451',
);

ManualAttendanceCubit _cubit({
  FakeSearchStudentUseCase? searchUC,
  FakeBulkSearchStudentsUseCase? bulkSearchUC,
  FakeRecordOnlineAttendanceUseCase? recordUC,
  FakeSaveOfflineAttendanceUseCase? saveUC,
  FakeSaveOfflineSearchUseCase? saveSearchUC,
}) {
  return ManualAttendanceCubit(
    searchStudentUseCase: searchUC ?? FakeSearchStudentUseCase(),
    bulkSearchStudentsUseCase: bulkSearchUC ?? FakeBulkSearchStudentsUseCase(),
    recordOnlineAttendanceUseCase:
        recordUC ?? FakeRecordOnlineAttendanceUseCase(),
    saveOfflineAttendanceUseCase: saveUC ?? FakeSaveOfflineAttendanceUseCase(),
    saveOfflineSearchUseCase: saveSearchUC ?? FakeSaveOfflineSearchUseCase(),
  );
}

// ──────────────────────── Tests ────────────────────────

void main() {
  group('ManualAttendanceCubit – Search', () {
    test('Empty query emits Idle without calling API', () async {
      int searchCalled = 0;
      final searchUC = FakeSearchStudentUseCase();
      searchUC.setHandler((q) {
        searchCalled++;
        return const Right(null);
      });

      final cubit = _cubit(searchUC: searchUC);
      await cubit.searchStudent('   ');

      expect(cubit.state, isA<ManualAttendanceIdle>());
      expect(searchCalled, 0);
      await cubit.close();
    });

    test('Search by full name returns ManualAttendanceSearchSuccess', () async {
      final searchUC = FakeSearchStudentUseCase();
      searchUC.setHandler((_) => const Right(_student));

      final cubit = _cubit(searchUC: searchUC);
      await cubit.searchStudent('Ahmed Ali');

      expect(cubit.state, isA<ManualAttendanceSearchSuccess>());
      expect(
        (cubit.state as ManualAttendanceSearchSuccess).student.studentName,
        'Ahmed Ali',
      );
      await cubit.close();
    });

    test('Search by full student code returns ManualAttendanceSearchSuccess',
        () async {
      final searchUC = FakeSearchStudentUseCase();
      searchUC.setHandler((_) => const Right(_student));

      final cubit = _cubit(searchUC: searchUC);
      await cubit.searchStudent('50991466');

      expect(cubit.state, isA<ManualAttendanceSearchSuccess>());
      expect(
        (cubit.state as ManualAttendanceSearchSuccess).student.studentCode,
        '50991466',
      );
      await cubit.close();
    });

    test('Search by full phone returns ManualAttendanceSearchSuccess', () async {
      final searchUC = FakeSearchStudentUseCase();
      searchUC.setHandler((_) => const Right(_student));

      final cubit = _cubit(searchUC: searchUC);
      await cubit.searchStudent('01233123457');

      expect(cubit.state, isA<ManualAttendanceSearchSuccess>());
      await cubit.close();
    });

    test('Search by full email returns ManualAttendanceSearchSuccess', () async {
      final searchUC = FakeSearchStudentUseCase();
      searchUC.setHandler((_) => const Right(_student));

      final cubit = _cubit(searchUC: searchUC);
      await cubit.searchStudent('ahmed@example.com');

      expect(cubit.state, isA<ManualAttendanceSearchSuccess>());
      await cubit.close();
    });

    test('API returns null -> emits ManualAttendanceEmpty', () async {
      final searchUC = FakeSearchStudentUseCase();
      searchUC.setHandler((_) => const Right(null));

      final cubit = _cubit(searchUC: searchUC);
      await cubit.searchStudent('some query');

      expect(cubit.state, isA<ManualAttendanceEmpty>());
      await cubit.close();
    });

    test(
        'API returns entity with empty studentId -> emits ManualAttendanceEmpty',
        () async {
      final searchUC = FakeSearchStudentUseCase();
      searchUC.setHandler(
        (_) => const Right(
          ManualSearchStudentEntity(
            studentId: '',
            studentName: '',
            studentCode: '',
            educationalLevel: '',
            status: '',
            email: '',
            phone: '',
            parentPhone: '',
          ),
        ),
      );

      final cubit = _cubit(searchUC: searchUC);
      await cubit.searchStudent('partial name');

      expect(cubit.state, isA<ManualAttendanceEmpty>());
      await cubit.close();
    });

    test('Network error emits ManualAttendanceSearchError', () async {
      final searchUC = FakeSearchStudentUseCase();
      searchUC.setHandler(
        (_) => const Left(ServerFailure(message: 'No internet connection')),
      );

      final cubit = _cubit(searchUC: searchUC);
      await cubit.searchStudent('some query');

      expect(cubit.state, isA<ManualAttendanceSearchError>());
      expect(
        (cubit.state as ManualAttendanceSearchError).message,
        'No internet connection',
      );
      await cubit.close();
    });

    test('Latest search result wins – no stale result from old request',
        () async {
      int calls = 0;
      final searchUC = FakeSearchStudentUseCase();
      searchUC.setHandler((_) {
        calls++;
        if (calls == 1) {
          return const Right(null); // Old request: no match
        }
        return const Right(_student); // New request: match
      });

      final cubit = _cubit(searchUC: searchUC);
      await cubit.searchStudent('old query');
      expect(cubit.state, isA<ManualAttendanceEmpty>());

      await cubit.searchStudent('Ahmed Ali');
      expect(cubit.state, isA<ManualAttendanceSearchSuccess>());
      await cubit.close();
    });

    test('reset() returns cubit to ManualAttendanceIdle', () async {
      final searchUC = FakeSearchStudentUseCase();
      searchUC.setHandler((_) => const Right(_student));

      final cubit = _cubit(searchUC: searchUC);
      await cubit.searchStudent('Ahmed Ali');
      expect(cubit.state, isA<ManualAttendanceSearchSuccess>());

      cubit.reset();
      expect(cubit.state, isA<ManualAttendanceIdle>());
      await cubit.close();
    });
  });

  group('ManualAttendanceCubit – Record Online Attendance', () {
    test('Success emits ManualAttendanceSuccess with correct student',
        () async {
      final recordUC = FakeRecordOnlineAttendanceUseCase();
      recordUC.setHandler((_, __) => const Right('success'));

      final cubit = _cubit(recordUC: recordUC);
      await cubit.recordOnlineAttendance(
        student: _student,
        sessionId: 'session-123',
      );

      expect(cubit.state, isA<ManualAttendanceSuccess>());
      expect(
        (cubit.state as ManualAttendanceSuccess).student.studentId,
        _student.studentId,
      );
      await cubit.close();
    });

    test('Failure emits ManualAttendanceError with error message', () async {
      final recordUC = FakeRecordOnlineAttendanceUseCase();
      recordUC.setHandler(
        (_, __) =>
            const Left(ServerFailure(message: 'Duplicate attendance')),
      );

      final cubit = _cubit(recordUC: recordUC);
      await cubit.recordOnlineAttendance(
        student: _student,
        sessionId: 'session-123',
      );

      expect(cubit.state, isA<ManualAttendanceError>());
      expect(
        (cubit.state as ManualAttendanceError).message,
        'Duplicate attendance',
      );
      await cubit.close();
    });

    test('Passes correct studentId and sessionId to use case', () async {
      String? capturedUid;
      String? capturedSession;
      final recordUC = FakeRecordOnlineAttendanceUseCase();
      recordUC.setHandler((uid, sessionId) {
        capturedUid = uid;
        capturedSession = sessionId;
        return const Right('success');
      });

      final cubit = _cubit(recordUC: recordUC);
      await cubit.recordOnlineAttendance(
        student: _student,
        sessionId: 'session-456',
      );

      expect(capturedUid, _student.studentId);
      expect(capturedSession, 'session-456');
      await cubit.close();
    });

    test('ManualAttendanceError preserves student reference for retry',
        () async {
      final recordUC = FakeRecordOnlineAttendanceUseCase();
      recordUC.setHandler(
        (_, __) => const Left(ServerFailure(message: 'Network error')),
      );

      final cubit = _cubit(recordUC: recordUC);
      await cubit.recordOnlineAttendance(
        student: _student,
        sessionId: 'session-123',
      );

      expect(cubit.state, isA<ManualAttendanceError>());
      expect(
        (cubit.state as ManualAttendanceError).student.studentId,
        _student.studentId,
      );
      await cubit.close();
    });
  });

  group('ManualAttendanceCubit – Record Offline Attendance', () {
    test('Success emits ManualAttendanceSuccess', () async {
      final saveUC = FakeSaveOfflineAttendanceUseCase();
      saveUC.setHandler((_, __) => const Right('saved'));

      final cubit = _cubit(saveUC: saveUC);
      await cubit.recordOfflineAttendance(
        student: _student,
        sessionId: 'session-1',
        sessionName: 'Math - S1',
      );

      expect(cubit.state, isA<ManualAttendanceSuccess>());
      await cubit.close();
    });

    test('Duplicate offline error emits ManualAttendanceError', () async {
      final saveUC = FakeSaveOfflineAttendanceUseCase();
      saveUC.setHandler(
        (_, __) => const Left(
          ServerFailure(message: 'تم تسجيل الحضور مسبقًا'),
        ),
      );

      final cubit = _cubit(saveUC: saveUC);
      await cubit.recordOfflineAttendance(
        student: _student,
        sessionId: 'session-1',
        sessionName: 'Math - S1',
      );

      expect(cubit.state, isA<ManualAttendanceError>());
      expect(
        (cubit.state as ManualAttendanceError).message,
        contains('مسبقًا'),
      );
      await cubit.close();
    });

    test('Passes correct studentId to save use case', () async {
      String? capturedUid;
      final saveUC = FakeSaveOfflineAttendanceUseCase();
      saveUC.setHandler((uid, _) {
        capturedUid = uid;
        return const Right('saved');
      });

      final cubit = _cubit(saveUC: saveUC);
      await cubit.recordOfflineAttendance(
        student: _student,
        sessionId: 'session-1',
        sessionName: 'Math - S1',
      );

      expect(capturedUid, _student.studentId);
      await cubit.close();
    });
  });

  group('ManualSearchStudentEntity – equality and identity', () {
    test('Two entities with same data are equal', () {
      const e1 = ManualSearchStudentEntity(
        studentId: 'id-1',
        studentName: 'Ahmed',
        studentCode: '1234',
        educationalLevel: 'Grade 3',
        status: 'active',
        email: 'ahmed@test.com',
        phone: '01000000001',
        parentPhone: '01000000002',
      );
      const e2 = ManualSearchStudentEntity(
        studentId: 'id-1',
        studentName: 'Ahmed',
        studentCode: '1234',
        educationalLevel: 'Grade 3',
        status: 'active',
        email: 'ahmed@test.com',
        phone: '01000000001',
        parentPhone: '01000000002',
      );
      expect(e1, e2);
    });

    test('Entity with empty studentId is detected as no student', () async {
      final searchUC = FakeSearchStudentUseCase();
      searchUC.setHandler(
        (_) => const Right(
          ManualSearchStudentEntity(
            studentId: '',
            studentName: 'Ghost',
            studentCode: '',
            educationalLevel: '',
            status: '',
            email: '',
            phone: '',
            parentPhone: '',
          ),
        ),
      );

      final cubit = _cubit(searchUC: searchUC);
      await cubit.searchStudent('Ghost');

      // studentId is empty => treated as empty result
      expect(cubit.state, isA<ManualAttendanceEmpty>());
      await cubit.close();
    });
  });
}
