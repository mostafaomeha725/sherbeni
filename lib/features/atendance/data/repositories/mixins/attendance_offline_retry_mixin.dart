import 'package:dartz/dartz.dart';
import 'package:qrattendance/core/error/failure.dart';
import 'package:qrattendance/features/atendance/data/model/attendance_model.dart';
import 'attendance_offline_base_mixin.dart';

mixin AttendanceOfflineRetryMixin on AttendanceOfflineBaseMixin {
  Future<Either<Failure, Unit>> retrySpecificOfflineAttendance(
    String pendingKey,
  ) async {
    try {
      final historyRecords = await historyLocalDataSource
          .getAttendanceHistory();
      final historyRecordIndex = historyRecords.indexWhere(
        (e) => e.pendingKey == pendingKey,
      );

      if (historyRecordIndex == -1) {
        return Left(
          ServerFailure(message: 'السجل غير موجود في السجل التاريخي'),
        );
      }

      final historyRecord = historyRecords[historyRecordIndex];
      String studentId = historyRecord.uid;
      String sessionId = historyRecord.sessionId;
      String scanTime = historyRecord.scanTime;
      int? entryKey;

      final lookupKey = '${studentId}_$sessionId';

      final localData = await localDataSource.getOfflineAttendances();
      final targetIndex = localData.indexWhere(
        (e) => '${e.uid}_${e.sessionId}' == lookupKey,
      );

      if (targetIndex != -1) {
        final entry = localData[targetIndex];
        entryKey = entry.key as int?;
      }

      final date = scanTime.split(' ').first;
      final time = scanTime.split(' ').last;

      final payload = {
        "student_id": studentId,
        "session_id": sessionId,
        "date": date,
        "time": time,
      };

      final offline = await isOffline();

      if (offline) {
        if (targetIndex == -1) {
          await localDataSource.saveOfflineAttendance(
            AttendanceModel(
              uid: studentId,
              sessionId: sessionId,
              scanTime: scanTime,
            ),
          );
        }
        return Left(
          ServerFailure(
            message:
                "لا يوجد اتصال بالإنترنت، تم حفظ البيانات وسيتم رفعها تلقائيًا عند عودة الاتصال.",
          ),
        );
      }

      try {
        final result = await remoteDataSource.syncBatch({
          "attendance": [payload],
        });

        final responseData = result['data'] ?? {};
        final invalidResults = responseData['invalid_results'] as List? ?? [];
        final enrollmentResults =
            responseData['enrollment_results'] as List? ?? [];

        final enrollmentMap = <String, bool>{};
        for (var item in enrollmentResults) {
          if (item is Map &&
              item['student_id'] != null &&
              item['session_id'] != null) {
            enrollmentMap['${item['student_id']}_${item['session_id']}'] = true;
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

        if (enrollmentMap.containsKey(lookupKey)) {
          if (entryKey != null) {
            await localDataSource.deleteAttendances([entryKey]);
          }
          await historyLocalDataSource.updateAttendanceHistoryStatus(
            pendingKey,
            'success',
            syncedAt: DateTime.now(),
          );
          return Right(unit);
        } else if (invalidMap.containsKey(lookupKey)) {
          if (entryKey != null) {
            await localDataSource.deleteAttendances([entryKey]);
          }
          await historyLocalDataSource.updateAttendanceHistoryStatus(
            pendingKey,
            'failed',
            error: invalidMap[lookupKey],
            syncedAt: DateTime.now(),
          );
          return Left(ServerFailure(message: invalidMap[lookupKey]!));
        } else {
          // Unconfirmed result - keep in queue, mark history as pending
          await historyLocalDataSource.updateAttendanceHistoryStatus(
            pendingKey,
            'pending',
            error: 'لم تصل استجابة مؤكدة من السيرفر',
          );
          return Left(
            ServerFailure(message: 'لم تصل استجابة مؤكدة من السيرفر'),
          );
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

        if (isNetworkError) {
          if (targetIndex == -1) {
            await localDataSource.saveOfflineAttendance(
              AttendanceModel(
                uid: studentId,
                sessionId: sessionId,
                scanTime: scanTime,
              ),
            );
          }
          // Network Error: leave as pending
          await historyLocalDataSource.updateAttendanceHistoryStatus(
            pendingKey,
            'pending',
            error: errorMessage,
          );
          return Left(ServerFailure(message: errorMessage));
        } else {
          if (entryKey != null) {
            await localDataSource.deleteAttendances([entryKey]);
          }
          await historyLocalDataSource.updateAttendanceHistoryStatus(
            pendingKey,
            'failed',
            error: errorMessage,
            syncedAt: DateTime.now(),
          );
          return Left(ServerFailure(message: errorMessage));
        }
      }
    } catch (e) {
      return Left(
        ServerFailure(message: e is Failure ? e.message : 'حدث خطأ: $e'),
      );
    }
  }

  Future<Either<Failure, Map<String, dynamic>>>
  retryAllOfflineAttendance() async {
    try {
      final historyRecords = await historyLocalDataSource
          .getAttendanceHistory();
      final retryable = historyRecords
          .where((e) => e.syncStatus == 'failed' || e.syncStatus == 'pending')
          .toList();

      if (retryable.isEmpty) return const Right({'success': true});

      final hasInternet = await isOffline() == false;

      if (!hasInternet) {
        final currentPending = await localDataSource.getOfflineAttendances();
        final pendingKeys = currentPending
            .map((e) => '${e.uid}_${e.sessionId}')
            .toSet();

        for (var record in retryable) {
          if (!pendingKeys.contains(record.pendingKey)) {
            final date = record.scanTime.split(' ').first;
            final time = record.scanTime.split(' ').last;
            final model = AttendanceModel(
              uid: record.uid,
              sessionId: record.sessionId,
              scanTime: record.scanTime.contains(' ')
                  ? record.scanTime
                  : '$date $time',
            );
            await localDataSource.saveOfflineAttendance(model);
          }
        }
        return Left(
          ServerFailure(
            message:
                'لا يوجد اتصال بالإنترنت، تم حفظ البيانات وسيتم رفعها تلقائيًا عند عودة الاتصال.',
          ),
        );
      }

      List<Map<String, dynamic>> attendanceList = [];
      final Set<String> uniqueKeys = {};

      for (var record in retryable) {
        if (uniqueKeys.contains(record.pendingKey)) continue;
        uniqueKeys.add(record.pendingKey);

        final dateTimeParts = record.scanTime.split(' ');
        final date = dateTimeParts.isNotEmpty ? dateTimeParts[0] : '';
        final time = dateTimeParts.length > 1 ? dateTimeParts[1] : '';

        attendanceList.add({
          "student_id": record.uid,
          "session_id": record.sessionId,
          "date": date,
          "time": time,
        });
      }

      if (attendanceList.isEmpty) return const Right({'success': true});

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
            enrollmentMap['${item['student_id']}_${item['session_id']}'] = true;
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

        // ignore: unused_local_variable
        bool hasFailed = false;

        final currentPending = await localDataSource.getOfflineAttendances();
        final currentPendingMap = {
          for (var e in currentPending)
            '${e.uid}_${e.sessionId}': e.key as int?,
        };

        for (var record in retryable) {
          final lookupKey = '${record.uid}_${record.sessionId}';

          if (enrollmentMap.containsKey(lookupKey)) {
            await historyLocalDataSource.updateAttendanceHistoryStatus(
              record.pendingKey,
              'success',
              syncedAt: DateTime.now(),
            );
            final keyToDelete = currentPendingMap[lookupKey];
            if (keyToDelete != null) {
              await localDataSource.deleteAttendances([keyToDelete]);
            }
          } else if (invalidMap.containsKey(lookupKey)) {
            hasFailed = true;
            await historyLocalDataSource.updateAttendanceHistoryStatus(
              record.pendingKey,
              'failed',
              error: invalidMap[lookupKey],
              syncedAt: DateTime.now(),
            );
            final keyToDelete = currentPendingMap[lookupKey];
            if (keyToDelete != null) {
              await localDataSource.deleteAttendances([keyToDelete]);
            }
          } else {
            // Unconfirmed result - keep in queue, mark history as pending
            await historyLocalDataSource.updateAttendanceHistoryStatus(
              record.pendingKey,
              'pending',
              error: 'لم تصل استجابة مؤكدة من السيرفر',
            );
          }
        }

        return Right(result);
      } catch (e) {
        return Left(
          ServerFailure(
            message: e is Failure
                ? e.message
                : 'حدث خطأ غير متوقع أثناء المزامنة: $e',
          ),
        );
      }
    } catch (e) {
      return Left(
        ServerFailure(
          message: e is Failure
              ? e.message
              : e.toString().replaceAll('Exception: ', ''),
        ),
      );
    }
  }
}
