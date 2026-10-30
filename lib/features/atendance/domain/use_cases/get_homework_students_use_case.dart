import 'package:dartz/dartz.dart';
import 'package:qrattendance/core/error/failure.dart';
import 'package:qrattendance/features/atendance/domain/repositories/attendance_repository.dart';

class GetHomeworkStudentsUseCase {
  final AttendanceRepository repository;

  GetHomeworkStudentsUseCase(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call(
    String sessionId, {
    String search = '',
    String gradingStatus = 'all',
  }) async {
    return await repository.getSessionHomeworkGrades(
      sessionId,
      search,
      gradingStatus,
    );
  }
}

class GetCachedHomeworkStudentsUseCase {
  final AttendanceRepository repository;

  GetCachedHomeworkStudentsUseCase(this.repository);

  Future<Either<Failure, Map<String, dynamic>?>> call(String sessionId) async {
    return await repository.getCachedSessionHomeworkGrades(sessionId);
  }
}
