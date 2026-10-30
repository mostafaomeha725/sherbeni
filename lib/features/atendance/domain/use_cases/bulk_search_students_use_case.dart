import 'package:dartz/dartz.dart';
import 'package:qrattendance/core/error/failure.dart';
import 'package:qrattendance/features/atendance/domain/entities/manual_search_student_entity.dart';
import 'package:qrattendance/features/atendance/domain/repositories/attendance_repository.dart';

class BulkSearchStudentsUseCase {
  final AttendanceRepository repository;

  BulkSearchStudentsUseCase(this.repository);

  Future<Either<Failure, List<ManualSearchStudentEntity>>> call(
      List<String> queries) async {
    return await repository.bulkSearchStudents(queries);
  }
}
