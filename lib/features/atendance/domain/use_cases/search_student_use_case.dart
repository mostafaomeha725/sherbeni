import 'package:dartz/dartz.dart';
import 'package:qrattendance/core/error/failure.dart';
import 'package:qrattendance/features/atendance/domain/entities/manual_search_student_entity.dart';
import 'package:qrattendance/features/atendance/domain/repositories/attendance_repository.dart';

class SearchStudentUseCase {
  final AttendanceRepository repository;

  SearchStudentUseCase(this.repository);

  Future<Either<Failure, ManualSearchStudentEntity?>> call(
    String query,
  ) async {
    return await repository.searchStudent(query);
  }
}
