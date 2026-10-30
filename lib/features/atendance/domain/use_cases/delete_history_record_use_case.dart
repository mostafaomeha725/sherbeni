import 'package:dartz/dartz.dart';
import 'package:qrattendance/core/error/failure.dart';
import '../repositories/history_repository.dart';

class DeleteHistoryRecordUseCase {
  final HistoryRepository repository;

  DeleteHistoryRecordUseCase(this.repository);

  Future<Either<Failure, void>> deleteAttendance(String pendingKey) async {
    return await repository.deleteAttendanceHistory(pendingKey);
  }

  Future<Either<Failure, void>> deleteQuizGrade(String pendingKey) async {
    return await repository.deleteQuizGradeHistory(pendingKey);
  }

  Future<Either<Failure, void>> clearAllAttendance() async {
    return await repository.clearAttendanceHistory();
  }

  Future<Either<Failure, void>> clearAllQuizGrades() async {
    return await repository.clearQuizGradeHistory();
  }
}
