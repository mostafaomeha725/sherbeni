import 'package:dartz/dartz.dart';
import 'package:qrattendance/core/error/failure.dart';
import 'package:qrattendance/features/atendance/domain/repositories/attendance_repository.dart';

class RecordOnlineAttendanceUseCase {
  final AttendanceRepository repository;

  RecordOnlineAttendanceUseCase(this.repository);

  Future<Either<Failure, String>> call({
    required String uid,
    required String sessionId,
  }) async {
    return await repository.recordOnlineAttendance(
      uid: uid,
      sessionId: sessionId,
    );
  }
}
