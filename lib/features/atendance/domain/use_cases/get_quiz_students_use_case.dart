import 'package:dartz/dartz.dart';
import 'package:qrattendance/core/error/failure.dart';
import 'package:qrattendance/features/atendance/domain/repositories/attendance_repository.dart';

class GetQuizStudentsUseCase {
  final AttendanceRepository repository;

  GetQuizStudentsUseCase(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call(
    String sessionId, {
    String search = '',
    String gradingStatus = 'all',
  }) async {
    return await repository.getSessionQuizGrades(
      sessionId,
      search,
      gradingStatus,
    );
  }
}

class GetCachedQuizStudentsUseCase {
  final AttendanceRepository repository;

  GetCachedQuizStudentsUseCase(this.repository);

  Future<Either<Failure, Map<String, dynamic>?>> call(String sessionId) async {
    return await repository.getCachedSessionQuizGrades(sessionId);
  }
}
