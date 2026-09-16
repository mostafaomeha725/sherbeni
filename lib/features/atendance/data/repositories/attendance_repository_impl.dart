import 'package:dartz/dartz.dart';
import 'package:qrattendance/core/error/failure.dart';
import '../../domain/entities/session_entity.dart';
import '../../domain/entities/student_entity.dart';
import '../../domain/entities/session_attendance_entity.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../data_sources/attendance_local_data_source.dart';
import '../data_sources/attendance_remote_data_source.dart';
import '../model/attendance_model.dart';
import '../model/session_attendance_model.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class AttendanceRepositoryImpl implements AttendanceRepository {
  final AttendanceLocalDataSource localDataSource;
  final AttendanceRemoteDataSource remoteDataSource;

  AttendanceRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, String>> saveOfflineAttendance({
    required String uid,
    required String sessionId,
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

      return Right("success");
    } catch (e) {
      return Left(CacheFailure(message: "فشل في حفظ البيانات: $e"));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> syncOfflineData() async {
    try {
      final localData = await localDataSource.getOfflineAttendances();

      if (localData.isEmpty) {
        return Right({});
      }

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

      final batchBody = {"attendance": attendanceList};

      try {
        final data = await remoteDataSource.syncBatch(batchBody);

        // If successful, clear local data using deleteAll for atomicity
        final keysToDelete = localData
            .where((e) => e.key != null)
            .map((e) => e.key as int)
            .toList();
        if (keysToDelete.isNotEmpty) {
          await localDataSource.deleteAttendances(keysToDelete);
        }

        return Right(data);
      } catch (e) {
        return Left(
          ServerFailure(
            message: e is Failure ? e.message : 'فشل في المزامنة: $e',
          ),
        );
      }
    } catch (e) {
      return Left(
        ServerFailure(
          message: e is Failure
              ? e.message
              : 'حدث خطأ غير متوقع أثناء المزامنة: $e',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, String>> recordOnlineAttendance({
    required String uid,
    required String sessionId,
  }) async {
    try {
      final now = DateTime.now();
      // Force English locale so that dates don't get formatted with Arabic numerals (e.g. ٢٠٢٤)
      final date = DateFormat('yyyy-MM-dd', 'en_US').format(now);
      final time = DateFormat('HH:mm:ss', 'en_US').format(now);

      await remoteDataSource.recordAttendance({
        "student_id": uid,
        "session_id": sessionId,
        "date": date,
        "time": time,
      });

      return Right("success");
    } catch (e) {
      if (e is Failure) {
        return Left(e);
      }
      return Left(
        ServerFailure(message: e.toString().replaceAll('Exception: ', '')),
      );
    }
  }

  @override
  Future<Either<Failure, StudentEntity>> scanOnlineAttendance({
    required String qrCode,
    required String sessionId,
  }) async {
    try {
      final response = await remoteDataSource.scanOnline(qrCode, sessionId);
      final data = response['data'];

      if (data == null) {
        return Left(ServerFailure(message: 'لم يتم العثور على بيانات الطالب'));
      }

      final student = StudentEntity(
        id: data['studentId']?.toString() ?? '',
        studentQrCode: data['studentQrCode']?.toString() ?? '',
        name: data['studentName'] ?? 'طالب مجهول',
        email: data['email'] ?? '',
        studentPhone: data['phone']?.toString() ?? '',
        parentPhone: '',
        studentType: '',
        isApproved:
            data['status'] == 'approved' ||
            data['status'] == 'pending' ||
            data['status'] == true,
        group: GroupEntity(id: 0, name: data['educationalLevel'] ?? ''),
      );

      return Right(student);
    } catch (e) {
      if (e is Failure) {
        return Left(e);
      }
      return Left(
        ServerFailure(message: e.toString().replaceAll('Exception: ', '')),
      );
    }
  }

  @override
  Future<Either<Failure, List<SessionEntity>>> fetchClasses({
    required String subjectId,
  }) async {
    try {
      try {
        final remoteClasses = await remoteDataSource.getClasses(subjectId);

        await localDataSource.saveClasses(subjectId, remoteClasses);

        final entities = remoteClasses.map((e) => e.toEntity()).toList();
        return Right(entities);
      } catch (remoteError) {
        final localClasses = await localDataSource.getOfflineClasses(subjectId);
        if (localClasses.isNotEmpty) {
          final entities = localClasses.map((e) => e.toEntity()).toList();
          return Right(entities);
        } else {
          if (remoteError is Failure) {
            return Left(remoteError);
          }
          return Left(
            ServerFailure(
              message: remoteError.toString().replaceAll('Exception: ', ''),
            ),
          );
        }
      }
    } catch (e) {
      if (e is Failure) {
        return Left(e);
      }
      return Left(
        ServerFailure(message: e.toString().replaceAll('Exception: ', '')),
      );
    }
  }

  @override
  Future<Either<Failure, List<SessionEntity>>> getCachedClasses({
    required String subjectId,
  }) async {
    try {
      final localClasses = await localDataSource.getOfflineClasses(subjectId);
      final entities = localClasses.map((e) => e.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SessionEntity>>> fetchSessions({
    required String token,
  }) async {
    try {
      // 1. Try fetching from remote API
      try {
        final remoteSessions = await remoteDataSource.getSessions();

        // Save to local cache for offline use
        await localDataSource.saveSessions(remoteSessions);

        // Map to domain entities
        final entities = remoteSessions.map((e) => e.toEntity()).toList();
        return Right(entities);
      } catch (remoteError) {
        // 2. If remote fails (e.g. no internet), fallback to local cache
        final localSessions = await localDataSource.getOfflineSessions();
        if (localSessions.isNotEmpty) {
          final entities = localSessions.map((e) => e.toEntity()).toList();
          return Right(entities);
        } else {
          // If no cache either, throw the remote error
          throw remoteError;
        }
      }
    } catch (e) {
      if (e is Failure) {
        return Left(e);
      }
      return Left(
        ServerFailure(message: e.toString().replaceAll('Exception: ', '')),
      );
    }
  }

  @override
  Future<Either<Failure, List<SessionEntity>>> getCachedSessions() async {
    try {
      final localSessions = await localDataSource.getOfflineSessions();
      final entities = localSessions.map((e) => e.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, StudentEntity>> fetchStudentDataLocally({
    required String uid,
  }) async {
    try {
      final studentModel = await localDataSource.getStudentByUid(uid);

      if (studentModel == null) {
        return Right(
          StudentEntity(
            id: uid,
            studentQrCode: uid,
            name: 'بيانات الطالب غير متاحة بدون إنترنت',
            email: '',
            studentPhone: '',
            parentPhone: '',
            studentType: '',
            isApproved: true,
          ),
        );
      }

      final entity = StudentEntity(
        id: studentModel.id,
        studentQrCode: studentModel.id,
        name: studentModel.name,
        email: '',
        studentPhone: '',
        parentPhone: '',
        studentType: '',
        isApproved: true,
      );

      return Right(entity);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
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

      // Cache the first page of attendances and total count
      if (page == 1 &&
          result['data'] != null &&
          result['data']['attendances'] != null) {
        final jsonData = jsonEncode(result['data']['attendances']);
        await localDataSource.saveSessionAttendancesCache(sessionId, jsonData);

        if (result['pagination'] != null &&
            result['pagination']['totalItems'] != null) {
          final int totalItems = result['pagination']['totalItems'] is int
              ? result['pagination']['totalItems']
              : int.tryParse(result['pagination']['totalItems'].toString()) ??
                    0;
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

  @override
  Future<Either<Failure, List<SessionAttendanceEntity>>>
  getOfflineSessionAttendances(String sessionId) async {
    try {
      List<SessionAttendanceEntity> entities = [];

      // 1. Load cached online attendances
      final cachedJsonString = await localDataSource.getSessionAttendancesCache(
        sessionId,
      );
      if (cachedJsonString != null && cachedJsonString.isNotEmpty) {
        final List dynamicList = jsonDecode(cachedJsonString);
        entities.addAll(
          dynamicList.map((e) => SessionAttendanceModel.fromJson(e)).toList(),
        );
      }

      // Add dummy items to match totalItems from server
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

      // 2. Load pending (offline) attendances
      final attendances = await localDataSource.getOfflineAttendancesBySession(
        sessionId,
      );

      for (var entry in attendances) {
        // Prevent duplicate count if student is in both cache and pending (rare but possible)
        if (entities.any((e) => e.studentId == entry.uid)) {
          continue;
        }

        final student = await localDataSource.getStudentByUid(entry.uid);

        final dateTimeParts = entry.scanTime.split(' ');
        final date = dateTimeParts.isNotEmpty ? dateTimeParts[0] : '';
        final time = dateTimeParts.length > 1 ? dateTimeParts[1] : '';

        entities.add(
          SessionAttendanceEntity(
            attendanceId: '',
            studentId: entry.uid,
            name: student?.name ?? 'بيانات غير متاحة',
            phoneNumber: null,
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
