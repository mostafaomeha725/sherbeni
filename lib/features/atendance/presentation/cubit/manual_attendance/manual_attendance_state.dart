part of 'manual_attendance_cubit.dart';

abstract class ManualAttendanceState {}

class ManualAttendanceIdle extends ManualAttendanceState {}

class ManualAttendanceSearching extends ManualAttendanceState {}

class ManualAttendanceSearchSuccess extends ManualAttendanceState {
  final ManualSearchStudentEntity student;
  ManualAttendanceSearchSuccess(this.student);
}

class ManualAttendanceEmpty extends ManualAttendanceState {}

class ManualAttendanceSearchError extends ManualAttendanceState {
  final String message;
  ManualAttendanceSearchError(this.message);
}

class ManualAttendanceSubmitting extends ManualAttendanceState {
  final ManualSearchStudentEntity student;
  ManualAttendanceSubmitting(this.student);
}

class ManualAttendanceSuccess extends ManualAttendanceState {
  final ManualSearchStudentEntity student;
  ManualAttendanceSuccess(this.student);
}

class ManualAttendanceError extends ManualAttendanceState {
  final String message;
  final ManualSearchStudentEntity student;
  ManualAttendanceError(this.message, this.student);
}

class ManualAttendanceBulkSuccess extends ManualAttendanceState {
  final int count;
  final List<String> queries;
  final Map<String, String> queryToKeyMap;
  ManualAttendanceBulkSuccess(this.count, this.queries, this.queryToKeyMap);
}
