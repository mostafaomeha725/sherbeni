import 'package:dartz/dartz.dart';
import 'package:qrattendance/core/error/failure.dart';
import 'package:qrattendance/features/atendance/domain/repositories/attendance_repository.dart';

class CheckSessionQuizzesUseCase {
  final AttendanceRepository repository;

  CheckSessionQuizzesUseCase(this.repository);

  Future<Either<Failure, List<dynamic>>> call(String sessionId) async {
    return await repository.getSessionQuizzes(sessionId);
  }

  Future<Either<Failure, List<dynamic>?>> getCached(String sessionId) async {
    return await repository.getCachedSessionQuizzes(sessionId);
  }
}
