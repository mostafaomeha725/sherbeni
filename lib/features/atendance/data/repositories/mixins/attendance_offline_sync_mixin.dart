import 'package:dartz/dartz.dart';
import 'package:qrattendance/core/error/failure.dart';

import 'attendance_offline_attendance_sync_mixin.dart';
import 'attendance_offline_base_mixin.dart';
import 'attendance_offline_homework_sync_mixin.dart';
import 'attendance_offline_quiz_sync_mixin.dart';
import 'attendance_offline_search_sync_mixin.dart';

mixin AttendanceOfflineSyncMixin
    on
        AttendanceOfflineBaseMixin,
        AttendanceOfflineAttendanceSyncMixin,
        AttendanceOfflineSearchSyncMixin,
        AttendanceOfflineQuizSyncMixin,
        AttendanceOfflineHomeworkSyncMixin {
  Future<Either<Failure, Map<String, dynamic>>> syncOfflineData() async {
    try {
      await syncPendingSearches();
      await syncAttendances();
      await syncQuizGrades();
      await syncHomeworkGrades();

      return const Right({"message": "تم المزامنة بنجاح"});
    } catch (e) {
      return Left(
        ServerFailure(
          message: e is Failure
              ? e.message
              : 'حدث خطأ غير متوقع أثناء المزامنة: $e',
        ),
      );
    }
  }
}
