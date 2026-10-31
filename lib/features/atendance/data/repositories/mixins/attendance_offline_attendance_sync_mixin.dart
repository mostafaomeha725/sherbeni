import 'package:hive/hive.dart';
import 'package:qrattendance/core/error/failure.dart';
import 'attendance_offline_base_mixin.dart';

mixin AttendanceOfflineAttendanceSyncMixin on AttendanceOfflineBaseMixin {
  Future<void> syncAttendances() async {
    final localData = await localDataSource.getOfflineAttendances();

    if (localData.isNotEmpty) {
      List<Map<String, dynamic>> attendanceList = [];
      final Set<String> uniqueKeys = {};

      for (var entry in localData) {
        final key = '${entry.uid}_${entry.sessionId}';
        if (uniqueKeys.contains(key)) continue;
        uniqueKeys.add(key);

        final dateTimeParts = entry.scanTime.split(' ');
        final date = dateTimeParts.isNotEmpty ? dateTimeParts[0] : '';
        final time = dateTimeParts.length > 1 ? dateTimeParts[1] : '';

        attendanceList.add({
          "student_id": entry.uid,
          "session_id": entry.sessionId,
          "date": date,
          "time": time,
        });
      }

      if (attendanceList.isNotEmpty) {
        print('BULK_ATTENDANCE_START:\ncount=${attendanceList.length}');
        final batchBody = {"attendance": attendanceList};
        try {
          final result = await remoteDataSource.syncBatch(batchBody);

          final responseData = result['data'] ?? {};
          final invalidResults = responseData['invalid_results'] as List? ?? [];
          final enrollmentResults =
              responseData['enrollment_results'] as List? ?? [];

          final enrollmentMap = <String, bool>{};
          for (var item in enrollmentResults) {
            if (item is Map &&
                item['student_id'] != null &&
                item['session_id'] != null) {
              enrollmentMap['${item['student_id']}_${item['session_id']}'] =
                  true;
            }
          }

          final invalidMap = <String, String>{};
          for (var item in invalidResults) {
            if (item is Map &&
                item['student_id'] != null &&
                item['session_id'] != null) {
              invalidMap['${item['student_id']}_${item['session_id']}'] =
                  item['reason']?.toString() ?? 'Invalid data';
            }
          }

          print('BULK_ATTENDANCE_RESULT:\nsuccess=${enrollmentMap.length}\nfailed=${invalidMap.length}');

          for (var entry in localData) {
            final pendingKey = '${entry.uid}_${entry.sessionId}';
            final entryKey = (entry as HiveObject).key;

            if (enrollmentMap.containsKey(pendingKey)) {
              if (entryKey != null) {
                await localDataSource.deleteAttendances([entryKey as int]);
              }
              await historyLocalDataSource.updateAttendanceHistoryStatus(
                pendingKey,
                'success',
                syncedAt: DateTime.now(),
              );
            } else if (invalidMap.containsKey(pendingKey)) {
              if (entryKey != null) {
                await localDataSource.deleteAttendances([entryKey as int]);
              }
              await historyLocalDataSource.updateAttendanceHistoryStatus(
                pendingKey,
                'failed',
                error: invalidMap[pendingKey],
                syncedAt: DateTime.now(),
              );
            } else {
              // Neither success nor explicit failure - do not mark as success, keep as pending
              await historyLocalDataSource.updateAttendanceHistoryStatus(
                pendingKey,
                'pending',
                error: 'لم تصل استجابة مؤكدة من السيرفر',
              );
            }
          }
        } catch (e) {
          final errorMessage = e is Failure
              ? e.message
              : e.toString().replaceAll('Exception: ', '');
          final isNetworkError =
              errorMessage.contains('لا يوجد اتصال') ||
              errorMessage.contains('تعذر الاتصال') ||
              errorMessage.contains('Failed host lookup') ||
              errorMessage.contains('SocketException') ||
              errorMessage.contains('Timeout');

          final isRetriableError =
              isNetworkError ||
              errorMessage.contains('401') ||
              errorMessage.contains('403') ||
              errorMessage.contains('419') ||
              errorMessage.contains('Unauthorised') ||
              errorMessage.contains('Unauthorized') ||
              errorMessage.contains('token') ||
              errorMessage.contains('Token') ||
              errorMessage.contains('Refresh') ||
              errorMessage.contains('refresh') ||
              errorMessage.contains('500') ||
              errorMessage.contains('502') ||
              errorMessage.contains('503') ||
              errorMessage.contains('504');

          for (var entry in localData) {
            final pendingKey = '${entry.uid}_${entry.sessionId}';

            if (isRetriableError) {
              // Keep as pending for network and auth/server errors so they can be retried
              await historyLocalDataSource.updateAttendanceHistoryStatus(
                pendingKey,
                'pending',
                error: errorMessage,
              );
            } else {
              // Mark as failed for other critical errors
              final entryKey = (entry as HiveObject).key;
              if (entryKey != null) {
                await localDataSource.deleteAttendances([entryKey as int]);
              }
              await historyLocalDataSource.updateAttendanceHistoryStatus(
                pendingKey,
                'failed',
                error: errorMessage,
                syncedAt: DateTime.now(),
              );
            }
          }
        }
      }
    }
  }
}
