import 'package:dartz/dartz.dart';
import 'package:qrattendance/core/error/failure.dart';
import '../repositories/attendance_repository.dart';

class UpdateQuizGradeUseCase {
  final AttendanceRepository repository;

  UpdateQuizGradeUseCase(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call(
    String quizAttemptId,
    num grade,
    String sessionId,
    String quizTemplateId,
  ) async {
    return await repository.updateQuizGrade(
      quizAttemptId,
      grade,
      sessionId,
      quizTemplateId,
    );
  }
}
