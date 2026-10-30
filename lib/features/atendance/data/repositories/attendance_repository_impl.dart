import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:qrattendance/features/atendance/data/data_sources/attendance_local_data_source.dart';
import 'package:qrattendance/features/atendance/data/data_sources/attendance_remote_data_source.dart';
import 'package:qrattendance/features/atendance/data/data_sources/history_local_data_source.dart';
import 'package:qrattendance/features/atendance/data/repositories/mixins/attendance_offline_base_mixin.dart';
import 'package:qrattendance/features/atendance/data/repositories/mixins/attendance_offline_save_mixin.dart';
import 'package:qrattendance/features/atendance/data/repositories/mixins/attendance_offline_attendance_sync_mixin.dart';
import 'package:qrattendance/features/atendance/data/repositories/mixins/attendance_offline_quiz_sync_mixin.dart';
import 'package:qrattendance/features/atendance/data/repositories/mixins/attendance_offline_homework_sync_mixin.dart';
import 'package:qrattendance/features/atendance/data/repositories/mixins/attendance_offline_search_sync_mixin.dart';
import 'package:qrattendance/features/atendance/data/repositories/mixins/attendance_offline_sync_mixin.dart';
import 'package:qrattendance/features/atendance/data/repositories/mixins/attendance_offline_retry_mixin.dart';
import 'package:qrattendance/features/atendance/data/repositories/mixins/attendance_online_mixin.dart';
import 'package:qrattendance/features/atendance/data/repositories/mixins/attendance_online_classes_mixin.dart';
import 'package:qrattendance/features/atendance/data/repositories/mixins/attendance_online_sessions_mixin.dart';
import 'package:qrattendance/features/atendance/data/repositories/mixins/attendance_online_students_mixin.dart';
import 'package:qrattendance/features/atendance/data/repositories/mixins/attendance_online_records_mixin.dart';
import 'package:qrattendance/features/atendance/data/repositories/mixins/attendance_quiz_mixin.dart';
import 'package:qrattendance/features/atendance/data/repositories/mixins/attendance_homework_mixin.dart';
import 'package:qrattendance/features/atendance/domain/repositories/attendance_repository.dart';

class AttendanceRepositoryImpl
    with 
        AttendanceOfflineBaseMixin, 
        AttendanceOfflineSaveMixin, 
        AttendanceOfflineAttendanceSyncMixin,
        AttendanceOfflineQuizSyncMixin,
        AttendanceOfflineHomeworkSyncMixin,
        AttendanceOfflineSearchSyncMixin,
        AttendanceOfflineSyncMixin, 
        AttendanceOfflineRetryMixin, 
        AttendanceOnlineClassesMixin,
        AttendanceOnlineSessionsMixin,
        AttendanceOnlineStudentsMixin,
        AttendanceOnlineRecordsMixin,
        AttendanceOnlineMixin, 
        AttendanceQuizMixin,
        AttendanceHomeworkMixin
    implements AttendanceRepository {
  @override
  final AttendanceLocalDataSource localDataSource;
  @override
  final AttendanceRemoteDataSource remoteDataSource;
  @override
  final Connectivity connectivity;
  @override
  final HistoryLocalDataSource historyLocalDataSource;

  AttendanceRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.connectivity,
    required this.historyLocalDataSource,
  });
}
