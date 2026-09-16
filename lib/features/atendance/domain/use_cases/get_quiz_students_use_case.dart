import 'package:dartz/dartz.dart';
import 'package:qrattendance/core/error/failure.dart';
import 'package:qrattendance/features/atendance/domain/entities/student_entity.dart';

class GetQuizStudentsUseCase {
  Future<Either<Failure, List<StudentEntity>>> call(String sessionId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Dummy data for UI building until Backend API is ready
    final List<StudentEntity> dummyStudents = List.generate(
      20,
      (index) => StudentEntity(
        id: 'student_$index',
        studentQrCode: '100$index',
        name: 'طالب افتراضي رقم ${index + 1}',
        email: 'student$index@test.com',
        studentPhone: '011234567$index',
        parentPhone: '011234568$index',
        studentType: 'عادي',
        isApproved: true,
        group: const GroupEntity(id: 1, name: 'المجموعة الأولى'),
        isAttended: index % 3 != 0, // Dummy data for now
      ),
    );

    return Right(dummyStudents);
  }
}
