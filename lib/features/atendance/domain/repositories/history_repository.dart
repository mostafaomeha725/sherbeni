import 'package:dartz/dartz.dart';
import 'package:qrattendance/core/error/failure.dart';
import '../../data/model/attendance_history_model.dart';
import '../../data/model/quiz_grade_history_model.dart';

abstract class HistoryRepository {
  Future<Either<Failure, List<AttendanceHistoryModel>>> getAttendanceHistory();
  Future<Either<Failure, void>> deleteAttendanceHistory(String pendingKey);
  Future<Either<Failure, void>> clearAttendanceHistory();

  Future<Either<Failure, List<QuizGradeHistoryModel>>> getQuizGradeHistory();
  Future<Either<Failure, void>> deleteQuizGradeHistory(String pendingKey);
  Future<Either<Failure, void>> clearQuizGradeHistory();

  Future<Either<Failure, void>> cleanupOldHistory();
}
