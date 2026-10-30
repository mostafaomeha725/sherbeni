import 'package:dartz/dartz.dart';
import 'package:qrattendance/core/error/failure.dart';
import 'package:qrattendance/features/atendance/domain/repositories/attendance_repository.dart';

class DeleteSessionAttendanceUseCase {
  final AttendanceRepository repository;

  DeleteSessionAttendanceUseCase(this.repository);

  Future<Either<Failure, String>> call({
    required String sessionId,
    required String attendanceId,
  }) async {
    return await repository.deleteSessionAttendance(
      sessionId: sessionId,
      attendanceId: attendanceId,
    );
  }
}
