import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:qrattendance/features/atendance/data/data_sources/attendance_local_data_source.dart';
import 'package:qrattendance/features/atendance/data/data_sources/attendance_remote_data_source.dart';
import 'package:qrattendance/features/atendance/data/data_sources/history_local_data_source.dart';
import 'package:qrattendance/features/atendance/data/repositories/mixins/attendance_offline_base_mixin.dart';
import 'package:qrattendance/features/atendance/data/repositories/mixins/attendance_online_classes_mixin.dart';
import 'package:qrattendance/features/atendance/data/repositories/mixins/attendance_online_records_mixin.dart';
import 'package:qrattendance/features/atendance/data/repositories/mixins/attendance_online_sessions_mixin.dart';
import 'package:qrattendance/features/atendance/data/repositories/mixins/attendance_online_students_mixin.dart';

mixin AttendanceOnlineMixin on 
  AttendanceOfflineBaseMixin,
  AttendanceOnlineClassesMixin,
  AttendanceOnlineSessionsMixin,
  AttendanceOnlineStudentsMixin,
  AttendanceOnlineRecordsMixin {
    
  @override
  AttendanceLocalDataSource get localDataSource;
  
  @override
  AttendanceRemoteDataSource get remoteDataSource;
  
  @override
  Connectivity get connectivity;
  
  @override
  HistoryLocalDataSource get historyLocalDataSource;
}
