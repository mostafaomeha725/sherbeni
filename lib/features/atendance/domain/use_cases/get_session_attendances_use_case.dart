import 'package:dartz/dartz.dart';
import 'package:qrattendance/core/error/failure.dart';
import 'package:qrattendance/features/atendance/domain/repositories/attendance_repository.dart';

class GetSessionAttendancesUseCase {
  final AttendanceRepository repository;

  GetSessionAttendancesUseCase(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call(String sessionId, int page, int limit) {
    return repository.getSessionAttendances(sessionId, page, limit);
  }
}
