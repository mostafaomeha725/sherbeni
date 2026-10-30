import 'package:dartz/dartz.dart';
import 'package:qrattendance/core/error/failure.dart';
import '../repositories/attendance_repository.dart';

class UpdateHomeworkGradeUseCase {
  final AttendanceRepository repository;

  UpdateHomeworkGradeUseCase(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call(
    String sessionId,
    String? sessionName,
    String studentId,
    num grade,
  ) async {
    return await repository.addOrUpdateHomeworkGrade(
      sessionId,
      sessionName,
      studentId,
      grade,
    );
  }
}
