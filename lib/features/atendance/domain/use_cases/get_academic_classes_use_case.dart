import 'package:dartz/dartz.dart';
import 'package:qrattendance/core/error/failure.dart';
import '../entities/academic_class_entity.dart';
import '../repositories/attendance_repository.dart';

class GetAcademicClassesUseCase {
  final AttendanceRepository repository;

  GetAcademicClassesUseCase(this.repository);

  Future<Either<Failure, List<AcademicClassEntity>>> call({
    required String token,
  }) {
    return repository.fetchAcademicClasses(token: token);
  }

  Future<Either<Failure, List<AcademicClassEntity>>> getCached() {
    return repository.getCachedAcademicClasses();
  }
}
