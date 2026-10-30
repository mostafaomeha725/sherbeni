import 'package:dartz/dartz.dart';
import 'package:qrattendance/core/error/failure.dart';
import '../../data/model/attendance_history_model.dart';
import '../repositories/history_repository.dart';

class GetAttendanceHistoryUseCase {
  final HistoryRepository repository;

  GetAttendanceHistoryUseCase(this.repository);

  Future<Either<Failure, List<AttendanceHistoryModel>>> call() async {
    return await repository.getAttendanceHistory();
  }
}
