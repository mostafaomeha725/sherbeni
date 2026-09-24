import 'package:dartz/dartz.dart';
import 'package:qrattendance/core/error/failure.dart';
import '../../domain/entities/session_entity.dart';
import '../../domain/entities/academic_class_entity.dart';
import '../../domain/entities/student_entity.dart';
import '../../domain/entities/session_attendance_entity.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../data_sources/attendance_local_data_source.dart';
import '../data_sources/attendance_remote_data_source.dart';
import '../model/attendance_model.dart';
import '../model/session_attendance_model.dart';
import '../model/pending_quiz_grade_model.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../../core/utils/validators.dart';

import 'package:qrattendance/core/network/network_service.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  final AttendanceLocalDataSource localDataSource;
  final AttendanceRemoteDataSource remoteDataSource;
  final Connectivity connectivity;

  AttendanceRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.connectivity,
  });

  Future<bool> _isOffline() async {
    final connectivityResult = await connectivity.checkConnectivity();
    final hasInterface =
        connectivityResult.contains(ConnectivityResult.wifi) ||
        connectivityResult.contains(ConnectivityResult.mobile);
    if (!hasInterface) return true;

    final hasInternet = await NetworkService.hasInternetReachability();
    return !hasInternet;
  }

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
          final batchBody = {"attendance": attendanceList};
          try {
            await remoteDataSource.syncBatch(batchBody);
            final keysToDelete = localData
                .where((e) => e.key != null)
                .map((e) => e.key as int)
                .toList();
            if (keysToDelete.isNotEmpty) {
              await localDataSource.deleteAttendances(keysToDelete);
            }
          } catch (e) {
            // Attendance sync failed, continue to quiz grades sync
          }
        }
      }

      // Sync Pending Quiz Grades (Bulk API V2)
      final pendingGrades = await localDataSource.getPendingQuizGrades();

      // Group by session
      final Map<String, List<PendingQuizGradeModel>> sessionGroups = {};
      for (final pending in pendingGrades) {
        // Skip permanently failed requests
        if (pending.error != null) continue;
        sessionGroups.putIfAbsent(pending.sessionId, () => []).add(pending);
      }

      for (final sessionId in sessionGroups.keys) {
        final sessionPendingList = sessionGroups[sessionId]!;
        final List<Map<String, dynamic>> payloadGrades = [];
        final List<PendingQuizGradeModel> validPendingForSync = [];

        for (final pending in sessionPendingList) {
          // UUID Validation
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

        if (payloadGrades.isEmpty) continue;

        try {
          final result = await remoteDataSource.syncBulkQuizGrades(
            sessionId,
            payloadGrades,
          );

          // Success: verify race conditions and update cache
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
              // Grade hasn't changed offline during sync. Update cache from server.
              if (cachedGradesList != null) {
                final studentIndex = cachedGradesList.indexWhere(
                  (s) => s['student_id'] == pending.studentId,
                );
                Map<String, dynamic>? serverStudentData;
                for (final s in responseGrades) {
                  if (s['student_id'] == pending.studentId) {
                    serverStudentData = s as Map<String, dynamic>?;
                    break;
                  }
                }

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

              // Delete ONLY this specific successful pending grade
              await localDataSource.deletePendingQuizGrade(pending.pendingKey);
            } else {
              // User changed the grade while the sync was running. Keep Y pending.
            }
          }

          if (cacheUpdated && dynamicData != null) {
            await localDataSource.saveQuizStudentsCache(
              cacheKey,
              jsonEncode(dynamicData),
            );
          }
        } catch (e) {
          final errorMessage = e is Failure ? e.message : e.toString();
          // Check for 400 validation error (e.g. backend rejects specific payload entirely)
          // If the backend rejects it completely for validation, mark all as failed to unblock.
          if (errorMessage.contains('must be a UUID') ||
              errorMessage.contains('Validation') ||
              errorMessage.contains('400')) {
            for (final pending in validPendingForSync) {
              await localDataSource.markPendingQuizGradeAsFailed(
                pending.pendingKey,
                errorMessage,
              );
            }
          }
          // On other errors (e.g., Network Failure), keep pending (do nothing)
        }
      }

      return Right({"message": "تم المزامنة بنجاح"});
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
    required String classId,
  }) async {
    try {
      final remoteClasses = await remoteDataSource.getClasses(
        subjectId,
        classId,
      );
      final entities = remoteClasses.map((e) => e.toEntity()).toList();
      await localDataSource.saveClasses(subjectId, classId, remoteClasses);
      return Right(entities);
    } catch (remoteError) {
      try {
        final localClasses = await localDataSource.getOfflineClasses(
          subjectId,
          classId,
        );
        if (localClasses != null) {
          final entities = localClasses.map((e) => e.toEntity()).toList();
          return Right(entities);
        } else {
          final isOffline = await _isOffline();
          if (isOffline) {
            return const Left(CacheFailure(message: 'OFFLINE_FALLBACK'));
          }
          if (remoteError is Failure) {
            return Left(remoteError);
          }
          return Left(
            ServerFailure(
              message: remoteError.toString().replaceAll('Exception: ', ''),
            ),
          );
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
  }

  @override
  Future<Either<Failure, List<SessionEntity>>> getCachedClasses({
    required String subjectId,
    required String classId,
  }) async {
    try {
      final localClasses = await localDataSource.getOfflineClasses(
        subjectId,
        classId,
      );
      if (localClasses == null) {
        return const Left(CacheFailure(message: 'NO_CACHE_EXISTS'));
      }
      final entities = localClasses.map((e) => e.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SessionEntity>>> fetchSessions({
    required String token,
    required String classId,
  }) async {
    try {
      final remoteSessions = await remoteDataSource.getSessions(classId);
      await localDataSource.saveSessions(classId, remoteSessions);
      final entities = remoteSessions.map((e) => e.toEntity()).toList();
      return Right(entities);
    } catch (remoteError) {
      try {
        final localSessions = await localDataSource.getOfflineSessions(classId);
        if (localSessions.isNotEmpty) {
          final entities = localSessions.map((e) => e.toEntity()).toList();
          return Right(entities);
        } else {
          final isOffline = await _isOffline();
          if (isOffline) {
            return const Left(CacheFailure(message: 'OFFLINE_FALLBACK'));
          }
          if (remoteError is Failure) {
            return Left(remoteError);
          }
          return Left(
            ServerFailure(
              message: remoteError.toString().replaceAll('Exception: ', ''),
            ),
          );
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
  }

  @override
  Future<Either<Failure, List<AcademicClassEntity>>> fetchAcademicClasses({
    required String token,
  }) async {
    try {
      final remoteClasses = await remoteDataSource.getAcademicClasses(token);
      await localDataSource.saveAcademicClasses(remoteClasses);
      final entities = remoteClasses.map((e) => e.toEntity()).toList();
      return Right(entities);
    } catch (remoteError) {
      try {
        final localClasses = await localDataSource.getOfflineAcademicClasses();
        if (localClasses.isNotEmpty) {
          final entities = localClasses.map((e) => e.toEntity()).toList();
          return Right(entities);
        } else {
          final isOffline = await _isOffline();
          if (isOffline) {
            return const Left(CacheFailure(message: 'OFFLINE_FALLBACK'));
          }
          if (remoteError is Failure) {
            return Left(remoteError);
          }
          return Left(
            ServerFailure(
              message: remoteError.toString().replaceAll('Exception: ', ''),
            ),
          );
        }
      } catch (e) {
        if (e is Failure) {
          return Left(e);
        }
        return Left(CacheFailure(message: e.toString()));
      }
    }
  }

  @override
  Future<Either<Failure, List<AcademicClassEntity>>>
  getCachedAcademicClasses() async {
    try {
      final localClasses = await localDataSource.getOfflineAcademicClasses();
      final entities = localClasses.map((e) => e.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SessionEntity>>> getCachedSessions({
    required String classId,
  }) async {
    try {
      final localSessions = await localDataSource.getOfflineSessions(classId);
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

  @override
  Future<Either<Failure, List<dynamic>>> getSessionQuizzes(
    String sessionId,
  ) async {
    try {
      try {
        final response = await remoteDataSource.getSessionQuizzes(sessionId);

        List<dynamic> quizzesList = [];
        String jsonData = "[]";

        if (response['data'] != null && response['data']['quizzes'] != null) {
          quizzesList = response['data']['quizzes'];
          jsonData = jsonEncode(quizzesList);
        }

        // Save to local cache for offline use
        await localDataSource.saveSessionQuizzesCache(sessionId, jsonData);

        return Right(quizzesList);
      } catch (remoteError) {
        // Fallback to local cache if offline or remote fails
        final cachedJsonString = await localDataSource.getSessionQuizzesCache(
          sessionId,
        );

        if (cachedJsonString != null) {
          final List dynamicList = jsonDecode(cachedJsonString);
          return Right(dynamicList);
        } else {
          final isOffline = await _isOffline();
          if (isOffline) {
            return const Right([]);
          }
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
  Future<Either<Failure, List<dynamic>?>> getCachedSessionQuizzes(
    String sessionId,
  ) async {
    try {
      final cachedJsonString = await localDataSource.getSessionQuizzesCache(
        sessionId,
      );

      if (cachedJsonString != null) {
        final List dynamicList = jsonDecode(cachedJsonString);
        return Right(dynamicList);
      }
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getSessionQuizGrades(
    String sessionId,
    String search,
    String gradingStatus,
  ) async {
    try {
      final isDefaultQuery = search.isEmpty && gradingStatus == 'all';
      final cacheKey = 'quiz_grades_$sessionId';

      try {
        final response = await remoteDataSource.getSessionQuizGrades(
          sessionId,
          search,
          gradingStatus,
        );

        if (isDefaultQuery) {
          final jsonData = jsonEncode(response);
          await localDataSource.saveQuizStudentsCache(cacheKey, jsonData);
        }

        return Right(response);
      } catch (remoteError) {
        final isOffline = await _isOffline();
        if (isOffline) {
          final cachedJsonString = await localDataSource.getQuizStudentsCache(
            cacheKey,
          );

          if (cachedJsonString == null) {
            return const Left(
              CacheFailure(
                message:
                    'عذراً، لا تتوفر بيانات محفوظة محلياً. يرجى التأكد من اتصالك بالإنترنت والمحاولة مجدداً.',
              ),
            );
          }

          final Map<String, dynamic> cachedData = jsonDecode(cachedJsonString);
          if (cachedData['data'] != null &&
              cachedData['data']['grades'] != null) {
            List gradesList = cachedData['data']['grades'];

            if (gradingStatus == 'graded') {
              gradesList = gradesList.where((s) => s['grade'] != null).toList();
            } else if (gradingStatus == 'not_graded') {
              gradesList = gradesList.where((s) => s['grade'] == null).toList();
            }

            if (search.isNotEmpty) {
              final query = search.toLowerCase();
              gradesList = gradesList.where((s) {
                final name = s['name']?.toString().toLowerCase() ?? '';
                final code = s['student_code']?.toString().toLowerCase() ?? '';
                final phone = s['phone_number']?.toString().toLowerCase() ?? '';
                return name.contains(query) ||
                    code.contains(query) ||
                    phone.contains(query);
              }).toList();
            }

            cachedData['data']['grades'] = gradesList;
            return Right(cachedData);
          }
        }

        if (remoteError is Failure) {
          return Left(remoteError);
        }
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

  @override
  Future<Either<Failure, Map<String, dynamic>?>> getCachedSessionQuizGrades(
    String sessionId,
  ) async {
    try {
      final cacheKey = 'quiz_grades_$sessionId';
      final cachedJsonString = await localDataSource.getQuizStudentsCache(
        cacheKey,
      );

      if (cachedJsonString != null) {
        final dynamicData = jsonDecode(cachedJsonString);
        return Right(dynamicData);
      }
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> addOrUpdateQuizGrade(
    String sessionId,
    String studentId,
    num grade,
  ) async {
    try {
      final isOffline = await _isOffline();

      if (!isOffline) {
        try {
          final response = await remoteDataSource.addOrUpdateQuizGrade(
            sessionId,
            studentId,
            grade,
          );

          // Update Local Cache on successful online request
          try {
            final cacheKey = 'quiz_grades_$sessionId';
            final cachedJsonString = await localDataSource.getQuizStudentsCache(
              cacheKey,
            );

            if (cachedJsonString != null) {
              final Map<String, dynamic> dynamicData = jsonDecode(
                cachedJsonString,
              );
              if (dynamicData['data'] != null &&
                  dynamicData['data']['grades'] != null) {
                final List gradesList = dynamicData['data']['grades'];
                final studentIndex = gradesList.indexWhere(
                  (s) => s['student_id'] == studentId,
                );

                if (studentIndex != -1) {
                  gradesList[studentIndex]['grade'] = grade;
                  final updatedJsonData = jsonEncode(dynamicData);
                  await localDataSource.saveQuizStudentsCache(
                    cacheKey,
                    updatedJsonData,
                  );
                }
              }
            }
          } catch (cacheError) {
            // Silently fail cache update
          }
          return Right(response);
        } catch (remoteError) {
          final errorMessage = remoteError.toString();
          // Distinguish between application/backend 400 error and a network/timeout failure
          final isNetworkError =
              errorMessage.contains('Failed host lookup') ||
              errorMessage.contains('Connection refused') ||
              errorMessage.contains('Network is unreachable') ||
              errorMessage.contains('SocketException');

          if (!isNetworkError) {
            // It's a backend response like 400/403/422. Do NOT queue offline.
            if (remoteError is Failure) return Left(remoteError);
            return Left(
              ServerFailure(
                message: errorMessage.replaceAll('Exception: ', ''),
              ),
            );
          }
          // If it IS a network error despite isOffline being false, it will fall through to the offline handler
        }
      }

      // Offline Handler (isOffline == true or Network Exception)
      // Save locally to PendingQueue
      final pendingModel = PendingQuizGradeModel(
        studentId: studentId,
        sessionId: sessionId,
        grade: grade,
      );
      await localDataSource.savePendingQuizGrade(pendingModel);

      // Update Local Cache eagerly
      try {
        final cacheKey = 'quiz_grades_$sessionId';
        final cachedJsonString = await localDataSource.getQuizStudentsCache(
          cacheKey,
        );

        if (cachedJsonString != null) {
          final Map<String, dynamic> dynamicData = jsonDecode(cachedJsonString);
          if (dynamicData['data'] != null &&
              dynamicData['data']['grades'] != null) {
            final List gradesList = dynamicData['data']['grades'];
            final studentIndex = gradesList.indexWhere(
              (s) => s['student_id'] == studentId,
            );

            if (studentIndex != -1) {
              gradesList[studentIndex]['grade'] = grade;
              final updatedJsonData = jsonEncode(dynamicData);
              await localDataSource.saveQuizStudentsCache(
                cacheKey,
                updatedJsonData,
              );
            }
          }
        }
      } catch (cacheError) {
        // Silently fail cache update
      }

      return const Right({
        "status": true,
        "message": "تم حفظ الدرجة محليًا وسيتم مزامنتها عند عودة الإنترنت.",
      });
    } catch (e) {
      if (e is Failure) return Left(e);
      return Left(
        ServerFailure(message: e.toString().replaceAll('Exception: ', '')),
      );
    }
  }
}
