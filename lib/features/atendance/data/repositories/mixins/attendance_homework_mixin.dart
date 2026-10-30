import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dartz/dartz.dart';
import 'package:qrattendance/core/error/failure.dart';
import 'package:qrattendance/features/atendance/data/data_sources/attendance_local_data_source.dart';
import 'package:qrattendance/features/atendance/data/data_sources/attendance_remote_data_source.dart';
import 'package:qrattendance/features/atendance/data/data_sources/history_local_data_source.dart';
import 'package:qrattendance/features/atendance/data/model/pending_homework_grade_model.dart';
import 'package:qrattendance/features/atendance/data/repositories/mixins/attendance_offline_base_mixin.dart';

mixin AttendanceHomeworkMixin on AttendanceOfflineBaseMixin {
  @override
  AttendanceLocalDataSource get localDataSource;
  @override
  AttendanceRemoteDataSource get remoteDataSource;
  @override
  Connectivity get connectivity;
  @override
  HistoryLocalDataSource get historyLocalDataSource;

  Future<Either<Failure, Map<String, dynamic>>> getSessionHomeworkGrades(
    String sessionId,
    String search,
    String gradingStatus,
  ) async {
    try {
      final isDefaultQuery = search.isEmpty && gradingStatus == 'all';
      final cacheKey = 'homework_grades_$sessionId';

      try {
        final response = await remoteDataSource.getSessionHomeworkGrades(
          sessionId,
          search,
          gradingStatus,
        );

        if (isDefaultQuery) {
          await localDataSource.saveHomeworkStudentsCache(
            cacheKey,
            jsonEncode(response),
          );
        }

        return Right(response);
      } catch (remoteError) {
        final offline = await isOffline();
        if (offline) {
          final cachedJsonString = await localDataSource
              .getHomeworkStudentsCache(cacheKey);

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
          return Right(cachedData);
        }

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

  Future<Either<Failure, Map<String, dynamic>?>> getCachedSessionHomeworkGrades(
    String sessionId,
  ) async {
    try {
      final cacheKey = 'homework_grades_$sessionId';
      final cachedJsonString = await localDataSource.getHomeworkStudentsCache(
        cacheKey,
      );

      if (cachedJsonString != null) {
        final Map<String, dynamic> cachedData = jsonDecode(cachedJsonString);
        return Right(cachedData);
      }
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> addOrUpdateHomeworkGrade(
    String sessionId,
    String? sessionName,
    String studentId,
    num grade,
  ) async {
    try {
      final offline = await isOffline();
      if (offline) {
        final pendingModel = PendingHomeworkGradeModel(
          studentId: studentId,
          sessionId: sessionId,
          grade: grade,
        );
        await localDataSource.savePendingHomeworkGrade(pendingModel);
        print(
          'OFFLINE_HOMEWORK_SAVED:\npendingKey=$studentId\nsessionId=$sessionId\ngrade=$grade',
        );

        final cacheKey = 'homework_grades_$sessionId';
        final cachedJsonString = await localDataSource.getHomeworkStudentsCache(
          cacheKey,
        );
        if (cachedJsonString != null) {
          final Map<String, dynamic> cachedData = jsonDecode(cachedJsonString);
          if (cachedData['data'] != null &&
              cachedData['data']['grades'] != null) {
            List gradesList = cachedData['data']['grades'];
            for (int i = 0; i < gradesList.length; i++) {
              if (gradesList[i]['student_id'] == studentId) {
                gradesList[i]['grade'] = grade;
                gradesList[i]['isOfflineSyncing'] = true;
                break;
              }
            }
            await localDataSource.saveHomeworkStudentsCache(
              cacheKey,
              jsonEncode(cachedData),
            );
          }
        }
        return const Right({
          'success': true,
          'message': 'تم حفظ الدرجة محلياً (Offline)',
        });
      }

      final response = await remoteDataSource.addOrUpdateHomeworkGrade(
        sessionId,
        studentId,
        grade,
      );

      return Right(response);
    } catch (e) {
      if (e is Failure) return Left(e);
      return Left(
        ServerFailure(message: e.toString().replaceAll('Exception: ', '')),
      );
    }
  }
}
