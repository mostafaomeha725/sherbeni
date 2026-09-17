import 'package:dartz/dartz.dart';
import 'package:qrattendance/core/error/failure.dart';
import 'package:qrattendance/features/atendance/domain/repositories/attendance_repository.dart';

class GetQuizStudentsUseCase {
  final AttendanceRepository repository;

  GetQuizStudentsUseCase(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call(
    String sessionId,
    String quizTemplateId, {
    int page = 1,
    int limit = 10,
    String search = '',
    String gradingStatus = 'all',
  }) async {
    return await repository.getQuizStudents(
      sessionId,
      quizTemplateId,
      page,
      limit,
      search,
      gradingStatus,
    );
  }
}

class GetCachedQuizStudentsUseCase {
  final AttendanceRepository repository;

  GetCachedQuizStudentsUseCase(this.repository);

  Future<Either<Failure, Map<String, dynamic>?>> call(
    String sessionId,
    String quizTemplateId,
  ) async {
    return await repository.getCachedQuizStudents(sessionId, quizTemplateId);
  }
}
