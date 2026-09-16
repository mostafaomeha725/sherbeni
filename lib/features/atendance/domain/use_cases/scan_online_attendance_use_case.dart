import 'package:dartz/dartz.dart';
import 'package:qrattendance/core/error/failure.dart';
import 'package:qrattendance/features/atendance/domain/entities/student_entity.dart';
import 'package:qrattendance/features/atendance/domain/repositories/attendance_repository.dart';

class ScanOnlineAttendanceUseCase {
  final AttendanceRepository repository;

  ScanOnlineAttendanceUseCase(this.repository);

  Future<Either<Failure, StudentEntity>> call({
    required String qrCode,
    required String sessionId,
  }) async {
    return await repository.scanOnlineAttendance(
      qrCode: qrCode,
      sessionId: sessionId,
    );
  }
}
