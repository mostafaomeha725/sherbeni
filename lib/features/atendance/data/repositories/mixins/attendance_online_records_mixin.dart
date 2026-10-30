import 'package:dartz/dartz.dart';
import 'package:intl/intl.dart';
import 'package:qrattendance/core/error/failure.dart';
import 'package:qrattendance/features/atendance/domain/entities/student_entity.dart';
import 'package:qrattendance/features/atendance/data/repositories/mixins/attendance_offline_base_mixin.dart';

mixin AttendanceOnlineRecordsMixin on AttendanceOfflineBaseMixin {
  Future<Either<Failure, String>> recordOnlineAttendance({
    required String uid,
    required String sessionId,
  }) async {
    try {
      final now = DateTime.now();
      final date = DateFormat('yyyy-MM-dd', 'en_US').format(now);
      final time = DateFormat('HH:mm:ss', 'en_US').format(now);

      await remoteDataSource.recordAttendance({
        "student_id": uid,
        "session_id": sessionId,
        "date": date,
        "time": time,
      });

      return Right("success");
    } catch (e) {
      if (e is Failure) return Left(e);
      return Left(
        ServerFailure(message: e.toString().replaceAll('Exception: ', '')),
      );
    }
  }

  Future<Either<Failure, StudentEntity>> scanOnlineAttendance({
    required String qrCode,
    required String sessionId,
  }) async {
    try {
      final response = await remoteDataSource.scanOnline(qrCode, sessionId);
      final data = response['data'];

      if (data == null) {
        return Left(ServerFailure(message: 'لم يتم العثور على بيانات الطالب'));
      }

      final student = StudentEntity(
        id: data['studentId']?.toString() ?? '',
        studentQrCode: data['studentQrCode']?.toString() ?? '',
        name: data['studentName'] ?? 'طالب مجهول',
        email: data['email'] ?? '',
        studentPhone: data['phone']?.toString() ?? '',
        parentPhone: data['parentPhoneNumber']?.toString() ?? '',
        studentType: '',
        isApproved:
            data['status'] == 'approved' ||
            data['status'] == 'pending' ||
            data['status'] == true,
        group: GroupEntity(id: 0, name: data['educationalLevel'] ?? ''),
      );

      return Right(student);
    } catch (e) {
      if (e is Failure) return Left(e);
      return Left(
        ServerFailure(message: e.toString().replaceAll('Exception: ', '')),
      );
    }
  }
}
