import 'dart:convert';
import 'package:qrattendance/core/error/failure.dart';
import 'package:qrattendance/core/utils/validators.dart';
import 'package:qrattendance/features/atendance/data/data_sources/attendance_local_data_source.dart';
import 'package:qrattendance/features/atendance/data/data_sources/attendance_remote_data_source.dart';
import 'package:qrattendance/features/atendance/data/data_sources/history_local_data_source.dart';
import 'package:qrattendance/features/atendance/data/model/pending_quiz_grade_model.dart';

class AttendanceOfflineQuizSyncHelper {
  final AttendanceLocalDataSource localDataSource;
  final HistoryLocalDataSource historyLocalDataSource;
  final AttendanceRemoteDataSource remoteDataSource;

  AttendanceOfflineQuizSyncHelper({
    required this.localDataSource,
    required this.historyLocalDataSource,
    required this.remoteDataSource,
  });

  Future<void> syncQuizGrades() async {
    final pendingGrades = await localDataSource.getPendingQuizGrades();

    final attendanceHistoryList = await historyLocalDataSource
        .getAttendanceHistory();

    final Map<String, List<PendingQuizGradeModel>> sessionGroups = {};
    for (final pending in pendingGrades) {
      if (pending.error != null) continue;
      sessionGroups.putIfAbsent(pending.sessionId, () => []).add(pending);
    }

    for (final sessionId in sessionGroups.keys) {
      await _syncSessionQuizGrades(
        sessionId,
        sessionGroups[sessionId]!,
        attendanceHistoryList,
      );
    }
  }

  Future<void> _syncSessionQuizGrades(
    String sessionId,
    List<PendingQuizGradeModel> sessionPendingList,
    List<dynamic> attendanceHistoryList,
  ) async {
    final List<Map<String, dynamic>> payloadGrades = [];
    final List<PendingQuizGradeModel> validPendingForSync = [];

    for (final pending in sessionPendingList) {
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
        continue;
      }

      if (!Validators.isValidUuid(pending.studentId)) {
        await localDataSource.markPendingQuizGradeAsFailed(
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

    if (payloadGrades.isEmpty) return;

    try {
      final result = await remoteDataSource.syncBulkQuizGrades(
        sessionId,
        payloadGrades,
      );

      await _handleSyncSuccess(sessionId, result, validPendingForSync);
    } catch (e) {
      await _handleSyncError(e, validPendingForSync);
    }
  }

  Future<void> _handleSyncSuccess(
    String sessionId,
    Map<String, dynamic> result,
    List<PendingQuizGradeModel> validPendingForSync,
  ) async {
    final cacheKey = 'quiz_grades_$sessionId';
    final cachedJsonString = await localDataSource.getQuizStudentsCache(
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
      final currentPending = await localDataSource.getPendingQuizGrade(
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
            if (serverStudentData['approved_by'] != null) {
              cachedGradesList[studentIndex]['approved_by'] =
                  serverStudentData['approved_by'];
            }
            if (serverStudentData['approved_at'] != null) {
              cachedGradesList[studentIndex]['approved_at'] =
                  serverStudentData['approved_at'];
            }
            cacheUpdated = true;
          }
        }

        if (serverStudentData != null) {
          await localDataSource.deletePendingQuizGrade(pending.pendingKey);
          await historyLocalDataSource.updateQuizGradeHistoryStatus(
            pending.pendingKey,
            'success',
            syncedAt: DateTime.now(),
          );
        } else {
          await historyLocalDataSource.updateQuizGradeHistoryStatus(
            pending.pendingKey,
            'pending',
            error: 'لم تصل استجابة مؤكدة من السيرفر',
          );
        }
      }
    }

    if (cacheUpdated && dynamicData != null) {
      await localDataSource.saveQuizStudentsCache(
        cacheKey,
        jsonEncode(dynamicData),
      );
    }
  }

  Future<void> _handleSyncError(
    dynamic e,
    List<PendingQuizGradeModel> validPendingForSync,
  ) async {
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

    for (final pending in validPendingForSync) {
      if (isRetriableError) {
        await historyLocalDataSource.updateQuizGradeHistoryStatus(
          pending.pendingKey,
          'pending',
          error: errorMessage,
        );
      } else {
        if (errorMessage.toLowerCase().contains('attendance') ||
            errorMessage.contains('الحضور')) {
          await historyLocalDataSource.updateQuizGradeHistoryStatus(
            pending.pendingKey,
            'pending',
            error: errorMessage,
          );
        } else {
          await historyLocalDataSource.updateQuizGradeHistoryStatus(
            pending.pendingKey,
            'failed',
            error: errorMessage,
            syncedAt: DateTime.now(),
          );
          await localDataSource.markPendingQuizGradeAsFailed(
            pending.pendingKey,
            errorMessage,
          );
        }
      }
    }
  }
}
