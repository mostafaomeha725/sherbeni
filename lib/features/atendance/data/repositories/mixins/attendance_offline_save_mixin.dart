import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:intl/intl.dart';
import 'package:qrattendance/core/error/failure.dart';
import 'package:qrattendance/features/atendance/data/model/attendance_history_model.dart';
import 'package:qrattendance/features/atendance/data/model/attendance_model.dart';
import 'package:qrattendance/features/atendance/data/model/pending_search_model.dart';
import 'attendance_offline_base_mixin.dart';

mixin AttendanceOfflineSaveMixin on AttendanceOfflineBaseMixin {
  Future<Either<Failure, String>> saveOfflineAttendance({
    required String uid,
    required String sessionId,
    String? sessionName,
    String? scanTime,
  }) async {
    try {
      final cleanedUid = uid.trim();

      if (sessionId.isEmpty) {
        return Left(CacheFailure(message: "معرف الحصة غير صالح"));
      }

      // Check if already scanned offline
      final allEntries = await localDataSource.getOfflineAttendances();
      final existsOffline = allEntries.any(
        (e) => e.uid == cleanedUid && e.sessionId == sessionId,
      );

      if (existsOffline) {
        return Left(
          CacheFailure(message: "تم تسجيل الحضور لهذا الطالب مسبقًا (أوفلاين)"),
        );
      }

      // Check if already scanned online (cached)
      final cachedJsonString = await localDataSource.getSessionAttendancesCache(
        sessionId,
      );
      if (cachedJsonString != null && cachedJsonString.isNotEmpty) {
        final List dynamicList = jsonDecode(cachedJsonString);
        final existsOnline = dynamicList.any(
          (e) =>
              e['student_id']?.toString() == cleanedUid ||
              e['studentId']?.toString() == cleanedUid,
        );
        if (existsOnline) {
          return Left(
            CacheFailure(
              message: "تم تسجيل الحضور لهذا الطالب مسبقًا (موجود على السيرفر)",
            ),
          );
        }
      }

      final attendanceModel = AttendanceModel(
        uid: cleanedUid,
        sessionId: sessionId,
        scanTime:
            scanTime ??
            DateFormat('yyyy-MM-dd HH:mm:ss', 'en_US').format(DateTime.now()),
      );

      await localDataSource.saveOfflineAttendance(attendanceModel);

      try {
        final student = await localDataSource.getStudentByUid(cleanedUid);
        final pendingKey =
            '${attendanceModel.uid}_${attendanceModel.sessionId}_${DateTime.now().millisecondsSinceEpoch}';
        final historyModel = AttendanceHistoryModel(
          pendingKey: pendingKey,
          uid: cleanedUid,
          sessionId: sessionId,
          studentName: student?.name ?? 'بيانات غير متاحة',
          scanTime: attendanceModel.scanTime,
          syncStatus: 'pending',
          createdAt: DateTime.now(),
          studentQrCode: student?.studentQrCode,
          educationalLevel: student?.studentType,
          email: student?.email,
          phone: student?.studentPhone,
          parentPhoneNumber: student?.parentPhone,
          sessionName: sessionName,
        );
        await historyLocalDataSource.saveAttendanceHistory(historyModel);
      } catch (e) {
        // Silently fail history save
      }

      return Right("success");
    } catch (e) {
      return Left(CacheFailure(message: "فشل في حفظ البيانات: $e"));
    }
  }

  Future<Either<Failure, String>> saveOfflineSearch({
    required String query,
    required String sessionId,
    required String sessionName,
  }) async {
    try {
      print('OFFLINE_SEARCH_SAVE: search=$query');
      final now = DateTime.now();
      final pendingKey = '${query}_${sessionId}_${now.millisecondsSinceEpoch}';
      
      final model = PendingSearchModel(
        pendingKey: pendingKey,
        searchValue: query,
        sessionId: sessionId,
        sessionName: sessionName,
        status: 'pending',
        createdAt: now,
      );
      
      await localDataSource.savePendingSearch(model);
      final allPending = await localDataSource.getPendingSearches();
      print('OFFLINE_SEARCH_SAVED: count=${allPending.length}');
      return Right(pendingKey);
    } catch (e) {
      return Left(CacheFailure(message: "فشل في حفظ البحث: $e"));
    }
  }
}
