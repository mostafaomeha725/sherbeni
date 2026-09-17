import 'package:dartz/dartz.dart';
import 'package:qrattendance/core/error/failure.dart';
import 'package:qrattendance/features/atendance/domain/entities/session_attendance_entity.dart';
import 'package:qrattendance/features/atendance/domain/repositories/attendance_repository.dart';

class GetOfflineSessionAttendancesUseCase {
  final AttendanceRepository repository;

  GetOfflineSessionAttendancesUseCase(this.repository);

  Future<Either<Failure, List<SessionAttendanceEntity>>> call(
    String sessionId,
  ) {
    return repository.getOfflineSessionAttendances(sessionId);
  }
}
