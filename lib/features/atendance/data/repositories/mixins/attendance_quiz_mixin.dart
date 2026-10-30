import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dartz/dartz.dart';
import 'package:qrattendance/core/error/failure.dart';
import 'package:qrattendance/features/atendance/data/data_sources/attendance_local_data_source.dart';
import 'package:qrattendance/features/atendance/data/data_sources/attendance_remote_data_source.dart';
import 'package:qrattendance/features/atendance/data/data_sources/history_local_data_source.dart';
import 'package:qrattendance/features/atendance/data/model/pending_quiz_grade_model.dart';
import 'package:qrattendance/features/atendance/data/model/quiz_grade_history_model.dart';
import 'package:qrattendance/features/atendance/data/repositories/mixins/attendance_offline_base_mixin.dart';

mixin AttendanceQuizMixin on AttendanceOfflineBaseMixin {
  @override
  AttendanceLocalDataSource get localDataSource;
  @override
  AttendanceRemoteDataSource get remoteDataSource;
  @override
  Connectivity get connectivity;
  @override
  HistoryLocalDataSource get historyLocalDataSource;

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

        await localDataSource.saveSessionQuizzesCache(sessionId, jsonData);
        return Right(quizzesList);
      } catch (remoteError) {
        final cachedJsonString = await localDataSource.getSessionQuizzesCache(
          sessionId,
        );

        if (cachedJsonString != null) {
          final List dynamicList = jsonDecode(cachedJsonString);
          return Right(dynamicList);
        } else {
          final offline = await isOffline();
          if (offline) return const Right([]);
          if (remoteError is Failure) return Left(remoteError);
          return Left(
            ServerFailure(
              message: remoteError.toString().replaceAll('Exception: ', ''),
            ),
          );
        }
      }
    } catch (e) {
      if (e is Failure) return Left(e);
      return Left(
        ServerFailure(message: e.toString().replaceAll('Exception: ', '')),
      );
    }
  }

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
          await localDataSource.saveQuizStudentsCache(
            cacheKey,
            jsonEncode(response),
          );
        }

        return Right(response);
      } catch (remoteError) {
        final offline = await isOffline();
        if (offline) {
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

  Future<Either<Failure, Map<String, dynamic>?>> getCachedSessionQuizGrades(
    String sessionId,
  ) async {
    try {
      final cacheKey = 'quiz_grades_$sessionId';
      final cachedJsonString = await localDataSource.getQuizStudentsCache(
        cacheKey,
      );

      if (cachedJsonString != null) {
        return Right(jsonDecode(cachedJsonString));
      }
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, Map<String, dynamic>>> addOrUpdateQuizGrade(
    String sessionId,
    String? sessionName,
    String studentId,
    num grade,
  ) async {
    try {
      final offline = await isOffline();

      if (!offline) {
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
                  await localDataSource.saveQuizStudentsCache(
                    cacheKey,
                    jsonEncode(dynamicData),
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
          final isNetworkError =
              errorMessage.contains('Failed host lookup') ||
              errorMessage.contains('Connection refused') ||
              errorMessage.contains('Network is unreachable') ||
              errorMessage.contains('SocketException');

          if (!isNetworkError) {
            if (remoteError is Failure) return Left(remoteError);
            return Left(
              ServerFailure(
                message: errorMessage.replaceAll('Exception: ', ''),
              ),
            );
          }
        }
      }

      // Offline Handler
      final pendingModel = PendingQuizGradeModel(
        studentId: studentId,
        sessionId: sessionId,
        grade: grade,
      );
      await localDataSource.savePendingQuizGrade(pendingModel);

      // Save to History
      try {
        final cacheKey = 'quiz_grades_$sessionId';
        final cachedJsonString = await localDataSource.getQuizStudentsCache(
          cacheKey,
        );
        String studentName = 'بيانات غير متاحة';
        String? quizName;
        num? maxScore;

        if (cachedJsonString != null) {
          final Map<String, dynamic> dynamicData = jsonDecode(cachedJsonString);
          if (dynamicData['data'] != null) {
            quizName = dynamicData['data']['quiz_name'];
            maxScore = dynamicData['data']['max_score'];

            if (dynamicData['data']['grades'] != null) {
              final List gradesList = dynamicData['data']['grades'];
              final studentIndex = gradesList.indexWhere(
                (s) => s['student_id'] == studentId,
              );
              if (studentIndex != -1) {
                studentName = gradesList[studentIndex]['name'] ?? studentName;
              }
            }
          }
        }

        await historyLocalDataSource.saveQuizGradeHistory(
          QuizGradeHistoryModel(
            pendingKey: pendingModel.pendingKey,
            studentId: studentId,
            sessionId: sessionId,
            studentName: studentName,
            quizName: quizName,
            grade: grade,
            maxScore: maxScore,
            syncStatus: 'pending',
            createdAt: DateTime.now(),
            sessionName: sessionName,
          ),
        );
      } catch (e) {
        await historyLocalDataSource.saveQuizGradeHistory(
          QuizGradeHistoryModel(
            pendingKey: pendingModel.pendingKey,
            studentId: studentId,
            sessionId: sessionId,
            studentName: 'بيانات غير متاحة',
            grade: grade,
            syncStatus: 'pending',
            createdAt: DateTime.now(),
            sessionName: sessionName,
          ),
        );
      }

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
              await localDataSource.saveQuizStudentsCache(
                cacheKey,
                jsonEncode(dynamicData),
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
