import 'package:dartz/dartz.dart';
import 'package:qrattendance/core/error/failure.dart';
import 'package:qrattendance/features/atendance/data/model/manual_search_student_model.dart';
import 'package:qrattendance/features/atendance/domain/entities/manual_search_student_entity.dart';
import 'package:qrattendance/features/atendance/domain/entities/student_entity.dart';
import 'package:qrattendance/features/atendance/data/repositories/mixins/attendance_offline_base_mixin.dart';

mixin AttendanceOnlineStudentsMixin on AttendanceOfflineBaseMixin {
  Future<Either<Failure, StudentEntity>> fetchStudentDataLocally({
    required String uid,
  }) async {
    try {
      final studentModel = await localDataSource.getStudentByUid(uid);

      if (studentModel == null) {
        return Right(
          StudentEntity(
            id: uid,
            studentQrCode: uid,
            name: 'بيانات الطالب غير متاحة بدون إنترنت',
            email: '',
            studentPhone: '',
            parentPhone: '',
            studentType: '',
            isApproved: true,
          ),
        );
      }

      return Right(
        StudentEntity(
          id: studentModel.id,
          studentQrCode: studentModel.id,
          name: studentModel.name,
          email: '',
          studentPhone: '',
          parentPhone: '',
          studentType: '',
          isApproved: true,
        ),
      );
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, ManualSearchStudentEntity?>> searchStudent(
    String query,
  ) async {
    try {
      final model = await remoteDataSource.searchStudent(query);
      return Right(model);
    } catch (e) {
      if (e is Failure) return Left(e);
      return Left(
        ServerFailure(message: e.toString().replaceAll('Exception: ', '')),
      );
    }
  }

  Future<Either<Failure, List<ManualSearchStudentEntity>>> bulkSearchStudents(
    List<String> queries,
  ) async {
    try {
      final rawDataList = await remoteDataSource.bulkSearchStudents(queries);

      final List<ManualSearchStudentEntity> result = [];
      for (final item in rawDataList) {
        if (item['status'] == true && item['data'] != null) {
          result.add(ManualSearchStudentModel.fromJson(item['data']));
        }
      }
      return Right(result);
    } catch (e) {
      if (e is Failure) return Left(e);
      return Left(
        ServerFailure(message: e.toString().replaceAll('Exception: ', '')),
      );
    }
  }
}
