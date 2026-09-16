import 'package:dartz/dartz.dart';
import 'package:qrattendance/core/error/failure.dart';
import '../entities/student_entity.dart';
import '../repositories/attendance_repository.dart';

class GetStudentDataUseCase {
  final AttendanceRepository repository;

  GetStudentDataUseCase(this.repository);

  Future<Either<Failure, StudentEntity>> call({required String uid}) {
    return repository.fetchStudentDataLocally(uid: uid);
  }
}
