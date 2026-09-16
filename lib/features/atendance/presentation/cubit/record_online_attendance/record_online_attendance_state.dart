part of 'record_online_attendance_cubit.dart';

@immutable
abstract class RecordOnlineAttendanceState {}

class RecordOnlineAttendanceInitial extends RecordOnlineAttendanceState {}

class RecordOnlineAttendanceLoading extends RecordOnlineAttendanceState {}

class RecordOnlineAttendanceSuccess extends RecordOnlineAttendanceState {}

class RecordOnlineAttendanceFailure extends RecordOnlineAttendanceState {
  final String message;

  RecordOnlineAttendanceFailure(this.message);
}
