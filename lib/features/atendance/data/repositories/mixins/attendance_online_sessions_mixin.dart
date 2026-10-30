import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:qrattendance/core/error/failure.dart';
import 'package:qrattendance/features/atendance/data/model/session_attendance_model.dart';
import 'package:qrattendance/features/atendance/domain/entities/session_attendance_entity.dart';
import 'package:qrattendance/features/atendance/domain/entities/session_entity.dart';
import 'package:qrattendance/features/atendance/data/repositories/mixins/attendance_offline_base_mixin.dart';

mixin AttendanceOnlineSessionsMixin on AttendanceOfflineBaseMixin {
  Future<Either<Failure, List<SessionEntity>>> fetchSessions({
    required String token,
    required String classId,
  }) async {
    try {
      final remoteSessions = await remoteDataSource.getSessions(classId);
      await localDataSource.saveSessions(classId, remoteSessions);
      return Right(remoteSessions.map((e) => e.toEntity()).toList());
    } catch (remoteError) {
      try {
        final localSessions = await localDataSource.getOfflineSessions(classId);
        if (localSessions.isNotEmpty) {
          return Right(localSessions.map((e) => e.toEntity()).toList());
        } else {
          final offline = await isOffline();
          if (offline) return const Left(CacheFailure(message: 'OFFLINE_FALLBACK'));
          if (remoteError is Failure) return Left(remoteError);
          return Left(
            ServerFailure(
              message: remoteError.toString().replaceAll('Exception: ', ''),
            ),
          );
        }
      } catch (e) {
        if (e is Failure) return Left(e);
        return Left(
          ServerFailure(message: e.toString().replaceAll('Exception: ', '')),
        );
      }
    }
  }

  Future<Either<Failure, List<SessionEntity>>> getCachedSessions({
    required String classId,
  }) async {
    try {
      final localSessions = await localDataSource.getOfflineSessions(classId);
      return Right(localSessions.map((e) => e.toEntity()).toList());
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> getSessionAttendances(
    String sessionId,
    int page,
    int limit,
  ) async {
    try {
      final result = await remoteDataSource.getSessionAttendances(
        sessionId,
        page,
        limit,
      );

      if (page == 1 &&
          result['data'] != null &&
          result['data']['attendances'] != null) {
        final jsonData = jsonEncode(result['data']['attendances']);
        await localDataSource.saveSessionAttendancesCache(sessionId, jsonData);

        if (result['pagination'] != null &&
            result['pagination']['totalItems'] != null) {
          final int totalItems = result['pagination']['totalItems'] is int
              ? result['pagination']['totalItems']
              : int.tryParse(result['pagination']['totalItems'].toString()) ?? 0;
          await localDataSource.saveSessionTotalCountCache(
            sessionId,
            totalItems,
          );
        }
      }

      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, String>> deleteSessionAttendance({
    required String sessionId,
    required String attendanceId,
  }) async {
    try {
      final result = await remoteDataSource.deleteSessionAttendance(
        sessionId,
        attendanceId,
      );
      final message = result['message']?.toString() ?? 'تم حذف الحضور بنجاح';

      // Update local cache if present
      try {
        final cachedJsonString =
            await localDataSource.getSessionAttendancesCache(sessionId);
        if (cachedJsonString != null && cachedJsonString.isNotEmpty) {
          final List dynamicList = jsonDecode(cachedJsonString);
          dynamicList.removeWhere(
            (e) =>
                (e['attendance_id']?.toString() == attendanceId) ||
                (e['id']?.toString() == attendanceId),
          );
          await localDataSource.saveSessionAttendancesCache(
            sessionId,
            jsonEncode(dynamicList),
          );
        }
        final totalCount =
            await localDataSource.getSessionTotalCountCache(sessionId);
        if (totalCount > 0) {
          await localDataSource.saveSessionTotalCountCache(
            sessionId,
            totalCount - 1,
          );
        }
      } catch (_) {}

      return Right(message);
    } catch (e) {
      if (e is Failure) return Left(e);
      return Left(
        ServerFailure(message: e.toString().replaceAll('Exception: ', '')),
      );
    }
  }

  Future<Either<Failure, List<SessionAttendanceEntity>>>
  getOfflineSessionAttendances(String sessionId) async {
    try {
      List<SessionAttendanceEntity> entities = [];

      final cachedJsonString = await localDataSource.getSessionAttendancesCache(
        sessionId,
      );
      if (cachedJsonString != null && cachedJsonString.isNotEmpty) {
        final List dynamicList = jsonDecode(cachedJsonString);
        entities.addAll(
          dynamicList.map((e) => SessionAttendanceModel.fromJson(e)).toList(),
        );
      }

      final int totalItems = await localDataSource.getSessionTotalCountCache(
        sessionId,
      );
      if (totalItems > entities.length) {
        int missing = totalItems - entities.length;
        for (int i = 0; i < missing; i++) {
          entities.add(
            const SessionAttendanceEntity(
              attendanceId: 'dummy',
              studentId: 'dummy',
              name: 'dummy',
              date: '',
              time: '',
              sessionDate: null,
              sessionTime: null,
              isLate: false,
            ),
          );
        }
      }

      final attendances = await localDataSource.getOfflineAttendancesBySession(
        sessionId,
      );

      for (var entry in attendances) {
        if (entities.any((e) => e.studentId == entry.uid)) continue;

        final student = await localDataSource.getStudentByUid(entry.uid);

        final dateTimeParts = entry.scanTime.split(' ');
        final date = dateTimeParts.isNotEmpty ? dateTimeParts[0] : '';
        final time = dateTimeParts.length > 1 ? dateTimeParts[1] : '';

        entities.add(
          SessionAttendanceEntity(
            attendanceId: '',
            studentId: entry.uid,
            name: student?.name ?? 'بيانات غير متاحة',
            phoneNumber: student?.studentPhone,
            parentPhoneNumber: student?.parentPhone,
            picture: null,
            date: date,
            time: time,
            sessionDate: null,
            sessionTime: null,
            isLate: false,
          ),
        );
      }
      return Right(entities);
    } catch (e) {
      return Left(CacheFailure(message: "فشل في جلب الحضور المحلي"));
    }
  }
}
