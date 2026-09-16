import 'package:dartz/dartz.dart';
import 'package:qrattendance/core/error/failure.dart';
import '../repositories/attendance_repository.dart';

class SaveOfflineAttendanceUseCase {
  final AttendanceRepository repository;

  SaveOfflineAttendanceUseCase(this.repository);

  Future<Either<Failure, String>> call({
    required String uid,
    required String sessionId,
    String? scanTime,
  }) async {
    return await repository.saveOfflineAttendance(
      uid: uid,
      sessionId: sessionId,
      scanTime: scanTime,
    );
  }
}
