import 'package:dartz/dartz.dart';
import 'package:qrattendance/core/error/failure.dart';
import '../repositories/attendance_repository.dart';

class SyncOfflineDataUseCase {
  final AttendanceRepository repository;

  SyncOfflineDataUseCase(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call() {
    return repository.syncOfflineData();
  }
}
