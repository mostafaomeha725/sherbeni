import 'package:dartz/dartz.dart';
import 'package:qrattendance/core/error/failure.dart';
import 'package:qrattendance/features/atendance/domain/repositories/attendance_repository.dart';

class SaveOfflineSearchUseCase {
  final AttendanceRepository repository;

  SaveOfflineSearchUseCase(this.repository);

  Future<Either<Failure, String>> call({
    required String query,
    required String sessionId,
    required String sessionName,
  }) async {
    return await repository.saveOfflineSearch(
      query: query,
      sessionId: sessionId,
      sessionName: sessionName,
    );
  }
}
