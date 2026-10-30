import 'package:dartz/dartz.dart';
import 'package:qrattendance/core/error/failure.dart';
import '../../domain/repositories/history_repository.dart';
import '../data_sources/history_local_data_source.dart';
import '../model/attendance_history_model.dart';
import '../model/quiz_grade_history_model.dart';
import '../model/session_model.dart';
import '../model/academic_class_model.dart';
import 'package:hive/hive.dart';

class HistoryRepositoryImpl implements HistoryRepository {
  final HistoryLocalDataSource localDataSource;

  HistoryRepositoryImpl({required this.localDataSource});

  @override
  Future<Map<String, String>> _buildSessionNameMap() async {
    final Map<String, String> sessionNames = {};
    try {
      const boxName = 'academicClasses';
      if (Hive.isBoxOpen(boxName) || await Hive.boxExists(boxName)) {
        final classBox = Hive.isBoxOpen(boxName)
            ? Hive.box<AcademicClassModel>(boxName)
            : await Hive.openBox<AcademicClassModel>(boxName);

        for (var c in classBox.values) {
          final sBoxName = 'sessions_${c.id}';
          if (Hive.isBoxOpen(sBoxName) || await Hive.boxExists(sBoxName)) {
            final sBox = Hive.isBoxOpen(sBoxName)
                ? Hive.box<SessionModel>(sBoxName)
                : await Hive.openBox<SessionModel>(sBoxName);
            for (var s in sBox.values) {
              sessionNames[s.id] = "${s.courseTitle} - ${s.title}";
            }
          }
        }
      }
    } catch (_) {}
    return sessionNames;
  }

  @override
  Future<Either<Failure, List<AttendanceHistoryModel>>>
  getAttendanceHistory() async {
    try {
      await cleanupOldHistory();
      final data = await localDataSource.getAttendanceHistory();
      final sessionNames = await _buildSessionNameMap();

      for (var a in data) {
        if (a.sessionName == null ||
            a.sessionName!.isEmpty ||
            a.sessionName == 'بيانات غير متاحة' ||
            (a.sessionName!.length == 36 &&
                a.sessionName!.split('-').length == 5)) {
          final realName = sessionNames[a.sessionId];
          if (realName != null) {
            a.sessionName = realName;
          }
        }
      }

      // Sort by descending createdAt
      data.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return Right(data);
    } catch (e) {
      return Left(CacheFailure(message: "فشل في جلب سجلات الحضور: $e"));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAttendanceHistory(
    String pendingKey,
  ) async {
    try {
      await localDataSource.deleteAttendanceHistory(pendingKey);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: "فشل في حذف السجل: $e"));
    }
  }

  @override
  Future<Either<Failure, void>> clearAttendanceHistory() async {
    try {
      await localDataSource.clearAttendanceHistory();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: "فشل في مسح السجلات: $e"));
    }
  }

  @override
  Future<Either<Failure, List<QuizGradeHistoryModel>>>
  getQuizGradeHistory() async {
    try {
      await cleanupOldHistory();
      final data = await localDataSource.getQuizGradeHistory();
      final sessionNames = await _buildSessionNameMap();

      for (var a in data) {
        if (a.sessionName == null ||
            a.sessionName!.isEmpty ||
            a.sessionName == 'بيانات غير متاحة' ||
            (a.sessionName!.length == 36 &&
                a.sessionName!.split('-').length == 5)) {
          final realName = sessionNames[a.sessionId];
          if (realName != null) {
            a.sessionName = realName;
          }
        }
      }

      data.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return Right(data);
    } catch (e) {
      return Left(CacheFailure(message: "فشل في جلب سجلات الكويز: $e"));
    }
  }

  @override
  Future<Either<Failure, void>> deleteQuizGradeHistory(
    String pendingKey,
  ) async {
    try {
      await localDataSource.deleteQuizGradeHistory(pendingKey);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: "فشل في حذف السجل: $e"));
    }
  }

  @override
  Future<Either<Failure, void>> clearQuizGradeHistory() async {
    try {
      await localDataSource.clearQuizGradeHistory();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: "فشل في مسح السجلات: $e"));
    }
  }

  @override
  Future<Either<Failure, void>> cleanupOldHistory() async {
    try {
      final now = DateTime.now();
      final retentionDuration = const Duration(days: 1);

      final attendance = await localDataSource.getAttendanceHistory();
      for (final a in attendance) {
        final referenceTime = a.syncedAt ?? a.createdAt;
        if (now.difference(referenceTime) > retentionDuration) {
          if (a.syncStatus == 'success' || a.syncStatus == 'failed') {
            await localDataSource.deleteAttendanceHistory(a.pendingKey);
          }
        }
      }

      final grades = await localDataSource.getQuizGradeHistory();
      for (final g in grades) {
        final referenceTime = g.syncedAt ?? g.createdAt;
        if (now.difference(referenceTime) > retentionDuration) {
          if (g.syncStatus == 'success' || g.syncStatus == 'failed') {
            await localDataSource.deleteQuizGradeHistory(g.pendingKey);
          }
        }
      }

      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: "فشل في تنظيف السجلات القديمة: $e"));
    }
  }
}
