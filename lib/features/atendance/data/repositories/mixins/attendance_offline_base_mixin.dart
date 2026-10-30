import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:qrattendance/core/network/network_service.dart';
import 'package:qrattendance/features/atendance/data/data_sources/attendance_local_data_source.dart';
import 'package:qrattendance/features/atendance/data/data_sources/attendance_remote_data_source.dart';
import 'package:qrattendance/features/atendance/data/data_sources/history_local_data_source.dart';

mixin AttendanceOfflineBaseMixin {
  AttendanceLocalDataSource get localDataSource;
  AttendanceRemoteDataSource get remoteDataSource;
  Connectivity get connectivity;
  HistoryLocalDataSource get historyLocalDataSource;

  Future<bool> isOffline() async {
    final connectivityResult = await connectivity.checkConnectivity();
    final hasInterface =
        connectivityResult.contains(ConnectivityResult.wifi) ||
        connectivityResult.contains(ConnectivityResult.mobile);
    if (!hasInterface) return true;

    final hasInternet = await NetworkService.hasInternetReachability();
    return !hasInternet;
  }
}
