import 'package:dartz/dartz.dart';
import 'package:qrattendance/core/error/failure.dart';
import 'package:qrattendance/features/atendance/domain/repositories/attendance_repository.dart';

class CheckSessionQuizzesUseCase {
  final AttendanceRepository repository;

  CheckSessionQuizzesUseCase(this.repository);

  Future<Either<Failure, bool>> call(String sessionId) async {
    return await repository.checkSessionHasQuizzes(sessionId);
  }

  Future<Either<Failure, bool?>> getCached(String sessionId) async {
    return await repository.getCachedSessionQuizzes(sessionId);
  }
}
