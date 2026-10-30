import 'package:dartz/dartz.dart';
import 'package:qrattendance/core/error/failure.dart';
import '../repositories/attendance_repository.dart';

class RetrySpecificOfflineAttendanceUseCase {
  final AttendanceRepository repository;

  RetrySpecificOfflineAttendanceUseCase(this.repository);

  Future<Either<Failure, Unit>> call(String pendingKey) async {
    return await repository.retrySpecificOfflineAttendance(pendingKey);
  }
}
