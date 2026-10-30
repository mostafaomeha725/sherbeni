import 'attendance_offline_base_mixin.dart';
import 'attendance_offline_quiz_sync_helper.dart';

mixin AttendanceOfflineQuizSyncMixin on AttendanceOfflineBaseMixin {
  Future<void> syncQuizGrades() async {
    final helper = AttendanceOfflineQuizSyncHelper(
      localDataSource: localDataSource,
      historyLocalDataSource: historyLocalDataSource,
      remoteDataSource: remoteDataSource,
    );
    await helper.syncQuizGrades();
  }
}
