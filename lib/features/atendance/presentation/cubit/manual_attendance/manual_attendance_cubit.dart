import 'package:bloc/bloc.dart';
import 'package:intl/intl.dart';
import 'package:qrattendance/features/atendance/domain/entities/manual_search_student_entity.dart';
import 'package:qrattendance/features/atendance/domain/use_cases/record_online_attendance_use_case.dart';
import 'package:qrattendance/features/atendance/domain/use_cases/save_offline_attendance_use_case.dart';
import 'package:qrattendance/features/atendance/domain/use_cases/save_offline_search_use_case.dart';
import 'package:qrattendance/features/atendance/domain/use_cases/search_student_use_case.dart';
import 'package:qrattendance/features/atendance/domain/use_cases/bulk_search_students_use_case.dart';

part 'manual_attendance_state.dart';

class ManualAttendanceCubit extends Cubit<ManualAttendanceState> {
  final SearchStudentUseCase searchStudentUseCase;
  final BulkSearchStudentsUseCase bulkSearchStudentsUseCase;
  final RecordOnlineAttendanceUseCase recordOnlineAttendanceUseCase;
  final SaveOfflineAttendanceUseCase saveOfflineAttendanceUseCase;
  final SaveOfflineSearchUseCase saveOfflineSearchUseCase;

  ManualAttendanceCubit({
    required this.searchStudentUseCase,
    required this.bulkSearchStudentsUseCase,
    required this.recordOnlineAttendanceUseCase,
    required this.saveOfflineAttendanceUseCase,
    required this.saveOfflineSearchUseCase,
  }) : super(ManualAttendanceIdle());

  /// Search student – full match only, no debounce, triggered explicitly.
  Future<void> searchStudent(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      emit(ManualAttendanceIdle());
      return;
    }

    emit(ManualAttendanceSearching());

    final result = await searchStudentUseCase(trimmed);

    if (isClosed) return;

    result.fold(
      (failure) => emit(ManualAttendanceSearchError(failure.message)),
      (student) {
        if (student == null || student.studentId.isEmpty) {
          emit(ManualAttendanceEmpty());
        } else {
          emit(ManualAttendanceSearchSuccess(student));
        }
      },
    );
  }

  void reset() {
    emit(ManualAttendanceIdle());
  }

  /// Record attendance online using the existing [RecordOnlineAttendanceUseCase].
  Future<void> recordOnlineAttendance({
    required ManualSearchStudentEntity student,
    required String sessionId,
  }) async {
    emit(ManualAttendanceSubmitting(student));

    final result = await recordOnlineAttendanceUseCase(
      uid: student.studentId,
      sessionId: sessionId,
    );

    if (isClosed) return;

    result.fold(
      (failure) => emit(ManualAttendanceError(failure.message, student)),
      (_) => emit(ManualAttendanceSuccess(student)),
    );
  }

  /// Record attendance offline using the existing [SaveOfflineAttendanceUseCase].
  Future<void> recordOfflineAttendance({
    required ManualSearchStudentEntity student,
    required String sessionId,
    required String sessionName,
  }) async {
    emit(ManualAttendanceSubmitting(student));

    final scanTime = DateFormat(
      'yyyy-MM-dd HH:mm:ss',
      'en_US',
    ).format(DateTime.now());

    final result = await saveOfflineAttendanceUseCase(
      uid: student.studentId,
      sessionId: sessionId,
      sessionName: sessionName,
      scanTime: scanTime,
    );

    if (isClosed) return;

    result.fold(
      (failure) => emit(ManualAttendanceError(failure.message, student)),
      (_) => emit(ManualAttendanceSuccess(student)),
    );
  }

  Future<void> searchAndSubmitBulkOffline({
    required String queriesString,
    required String sessionId,
    required String sessionName,
  }) async {
    final queries = queriesString
        .split(RegExp(r'\n')) // ONLY split by newlines, keep spaces and full input
        .map((q) => q.trim())
        .where((q) => q.isNotEmpty)
        .toList();

    if (queries.isEmpty) {
      emit(ManualAttendanceIdle());
      return;
    }

    emit(ManualAttendanceSearching());

    final Map<String, String> queryToKeyMap = {};
    for (final query in queries) {
      final result = await saveOfflineSearchUseCase(
        query: query,
        sessionId: sessionId,
        sessionName: sessionName,
      );
      result.fold(
        (failure) {},
        (pendingKey) {
          queryToKeyMap[query] = pendingKey;
        }
      );
    }

    if (!isClosed) {
      emit(ManualAttendanceBulkSuccess(queries.length, queries, queryToKeyMap));
    }
  }
}
