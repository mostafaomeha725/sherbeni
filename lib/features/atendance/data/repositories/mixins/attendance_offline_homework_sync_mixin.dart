import 'dart:convert';
import 'package:qrattendance/core/error/failure.dart';
import 'package:qrattendance/core/utils/validators.dart';
import 'package:qrattendance/features/atendance/data/model/pending_homework_grade_model.dart';
import 'attendance_offline_base_mixin.dart';

mixin AttendanceOfflineHomeworkSyncMixin on AttendanceOfflineBaseMixin {
  Future<void> syncHomeworkGrades() async {
    final pendingHomework = await localDataSource.getPendingHomeworkGrades();

    // Fetch attendance history to verify if there's any pending or failed attendance for a student.
    // We must not sync their homework grade if their attendance hasn't successfully synced.
    final attendanceHistoryList = await historyLocalDataSource
        .getAttendanceHistory();

    // Group by session
    final Map<String, List<PendingHomeworkGradeModel>> sessionGroups = {};
    for (final pending in pendingHomework) {
      if (pending.error != null) continue;
      sessionGroups.putIfAbsent(pending.sessionId, () => []).add(pending);
    }

    for (final sessionId in sessionGroups.keys) {
      final sessionPendingList = sessionGroups[sessionId]!;
      final List<Map<String, dynamic>> payloadGrades = [];
      final List<PendingHomeworkGradeModel> validPendingForSync = [];

      for (final pending in sessionPendingList) {
        // Check if this student still has a pending or failed attendance for this session.
        bool shouldSkip = false;
        for (final attHistory in attendanceHistoryList) {
          if (attHistory.uid == pending.studentId &&
              attHistory.sessionId == sessionId) {
            if (attHistory.syncStatus == 'pending' ||
                attHistory.syncStatus == 'failed') {
              shouldSkip = true;
              break;
            }
          }
        }

        if (shouldSkip) {
          print(
            'BULK_HOMEWORK_SKIPPED:\nsessionId=$sessionId\nreason=Student ${pending.studentId} has pending or failed attendance history',
          );
          continue;
        }

        if (!Validators.isValidUuid(pending.studentId)) {
          await localDataSource.markPendingHomeworkGradeAsFailed(
            pending.pendingKey,
            "Invalid student_id UUID format",
          );
          continue;
        }

        payloadGrades.add({
          "student_id": pending.studentId,
          "grade": pending.grade,
        });
        validPendingForSync.add(pending);
      }

      if (payloadGrades.isEmpty) {
        print(
          'BULK_HOMEWORK_SKIPPED:\nsessionId=$sessionId\nreason=No valid grades to sync',
        );
        continue;
      }

      print(
        'BULK_HOMEWORK_SESSION:\nsessionId=$sessionId\ncount=${payloadGrades.length}',
      );

      try {
        final result = await remoteDataSource.syncBulkHomeworkGrades(
          sessionId,
          payloadGrades,
        );
        print('BULK_HOMEWORK_RESULT:\nsuccess=yes\nfailed=no');

        final cacheKey = 'homework_grades_$sessionId';
        final cachedJsonString = await localDataSource.getHomeworkStudentsCache(
          cacheKey,
        );
        Map<String, dynamic>? dynamicData;
        List? cachedGradesList;

        if (cachedJsonString != null) {
          dynamicData = jsonDecode(cachedJsonString);
          if (dynamicData != null &&
              dynamicData['data'] != null &&
              dynamicData['data']['grades'] != null) {
            cachedGradesList = dynamicData['data']['grades'];
          }
        }

        final responseGrades = result['data']?['grades'] as List? ?? [];
        bool cacheUpdated = false;

        for (final pending in validPendingForSync) {
          final currentPending = await localDataSource.getPendingHomeworkGrade(
            pending.pendingKey,
          );

          if (currentPending == null) continue;

          if (currentPending.grade == pending.grade) {
            Map<String, dynamic>? serverStudentData;
            for (final s in responseGrades) {
              if (s['student_id'] == pending.studentId) {
                serverStudentData = s as Map<String, dynamic>?;
                break;
              }
            }

            if (cachedGradesList != null) {
              final studentIndex = cachedGradesList.indexWhere(
                (s) => s['student_id'] == pending.studentId,
              );

              if (studentIndex != -1 && serverStudentData != null) {
                cachedGradesList[studentIndex]['grade'] =
                    serverStudentData['grade'];
                cachedGradesList[studentIndex].remove('isOfflineSyncing');
                cacheUpdated = true;
              }
            }

            if (serverStudentData != null) {
              await localDataSource.deletePendingHomeworkGrade(
                pending.pendingKey,
              );
            }
          }
        }

        if (cacheUpdated && dynamicData != null) {
          await localDataSource.saveHomeworkStudentsCache(
            cacheKey,
            jsonEncode(dynamicData),
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

        for (final pending in validPendingForSync) {
          if (!isNetworkError) {
            if (errorMessage.contains('must be a UUID') ||
                errorMessage.contains('Validation') ||
                errorMessage.contains('400') ||
                errorMessage.contains('attendance') ||
                errorMessage.contains('not have valid')) {
              await localDataSource.markPendingHomeworkGradeAsFailed(
                pending.pendingKey,
                errorMessage,
              );
            }
          }
        }
      }
    }
  }
}
