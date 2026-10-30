import 'package:equatable/equatable.dart';
import '../../../data/model/attendance_history_model.dart';
import '../../../data/model/quiz_grade_history_model.dart';

abstract class StoredDataState extends Equatable {
  const StoredDataState();

  @override
  List<Object?> get props => [];
}

class StoredDataInitial extends StoredDataState {}

class StoredDataLoading extends StoredDataState {}

class StoredDataLoaded extends StoredDataState {
  final List<AttendanceHistoryModel> attendanceHistory;
  final List<QuizGradeHistoryModel> quizGradeHistory;

  const StoredDataLoaded({
    required this.attendanceHistory,
    required this.quizGradeHistory,
  });

  @override
  List<Object?> get props => [attendanceHistory, quizGradeHistory];
}

class StoredDataError extends StoredDataState {
  final String message;

  const StoredDataError(this.message);

  @override
  List<Object?> get props => [message];
}

class StoredDataSyncing extends StoredDataLoaded {
  const StoredDataSyncing({
    required super.attendanceHistory,
    required super.quizGradeHistory,
  });
}

class StoredDataBulkSyncResult extends StoredDataLoaded {
  final int validCount;
  final int invalidCount;
  final List<Map<String, dynamic>> invalidRecords;

  const StoredDataBulkSyncResult({
    required this.validCount,
    required this.invalidCount,
    required this.invalidRecords,
    required super.attendanceHistory,
    required super.quizGradeHistory,
  });

  @override
  List<Object?> get props => [
    validCount,
    invalidCount,
    invalidRecords,
    attendanceHistory,
    quizGradeHistory,
  ];
}
