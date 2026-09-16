import 'package:dartz/dartz.dart';
import 'package:qrattendance/core/error/failure.dart';
import '../entities/session_entity.dart';
import '../repositories/attendance_repository.dart';

class GetSessionsUseCase {
  final AttendanceRepository repository;

  GetSessionsUseCase(this.repository);

  Future<Either<Failure, List<SessionEntity>>> call({required String token}) {
    return repository.fetchSessions(token: token);
  }

  Future<Either<Failure, List<SessionEntity>>> getCached() {
    return repository.getCachedSessions();
  }
}
