import 'package:hive/hive.dart';
import '../model/attendance_history_model.dart';
import '../model/quiz_grade_history_model.dart';

abstract class HistoryLocalDataSource {
  Future<void> saveAttendanceHistory(AttendanceHistoryModel model);
  Future<void> updateAttendanceHistoryStatus(
    String pendingKey,
    String status, {
    String? error,
    DateTime? syncedAt,
  });
  Future<List<AttendanceHistoryModel>> getAttendanceHistory();
  Future<void> deleteAttendanceHistory(String pendingKey);
  Future<void> clearAttendanceHistory();

  Future<void> saveQuizGradeHistory(QuizGradeHistoryModel model);
  Future<void> updateQuizGradeHistoryStatus(
    String pendingKey,
    String status, {
    String? error,
    DateTime? syncedAt,
  });
  Future<List<QuizGradeHistoryModel>> getQuizGradeHistory();
  Future<void> deleteQuizGradeHistory(String pendingKey);
  Future<void> clearQuizGradeHistory();
}

class HistoryLocalDataSourceImpl implements HistoryLocalDataSource {
  static const String _attendanceBox = 'attendanceHistory';
  static const String _quizGradesBox = 'quizGradesHistory';

  Future<Box<AttendanceHistoryModel>> _getAttendanceBox() async {
    return Hive.isBoxOpen(_attendanceBox)
        ? Hive.box<AttendanceHistoryModel>(_attendanceBox)
        : await Hive.openBox<AttendanceHistoryModel>(_attendanceBox);
  }

  Future<Box<QuizGradeHistoryModel>> _getQuizGradesBox() async {
    return Hive.isBoxOpen(_quizGradesBox)
        ? Hive.box<QuizGradeHistoryModel>(_quizGradesBox)
        : await Hive.openBox<QuizGradeHistoryModel>(_quizGradesBox);
  }

  @override
  Future<void> saveAttendanceHistory(AttendanceHistoryModel model) async {
    final box = await _getAttendanceBox();
    await box.put(model.pendingKey, model);
  }

  @override
  Future<void> updateAttendanceHistoryStatus(
    String pendingKey,
    String status, {
    String? error,
    DateTime? syncedAt,
  }) async {
    final box = await _getAttendanceBox();
    var model = box.get(pendingKey);

    if (model == null) {
      final matches = box.values
          .where(
            (e) =>
                e.syncStatus == 'pending' &&
                e.pendingKey.startsWith(pendingKey),
          )
          .toList();
      if (matches.isNotEmpty) {
        matches.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        model = matches.first;
      }
    }

    if (model != null) {
      model.syncStatus = status;
      model.error = error;
      if (syncedAt != null) model.syncedAt = syncedAt;
      await model.save();
    }
  }

  @override
  Future<List<AttendanceHistoryModel>> getAttendanceHistory() async {
    final box = await _getAttendanceBox();
    return box.values.toList();
  }

  @override
  Future<void> deleteAttendanceHistory(String pendingKey) async {
    final box = await _getAttendanceBox();
    await box.delete(pendingKey);
  }

  @override
  Future<void> clearAttendanceHistory() async {
    final box = await _getAttendanceBox();
    await box.clear();
  }

  @override
  Future<void> saveQuizGradeHistory(QuizGradeHistoryModel model) async {
    final box = await _getQuizGradesBox();
    await box.put(model.pendingKey, model);
  }

  @override
  Future<void> updateQuizGradeHistoryStatus(
    String pendingKey,
    String status, {
    String? error,
    DateTime? syncedAt,
  }) async {
    final box = await _getQuizGradesBox();

    // Find all matching pending rows (including legacy ones with timestamps)
    final matches = box.values
        .where(
          (e) =>
              e.pendingKey == pendingKey ||
              e.pendingKey.startsWith('${pendingKey}_'),
        )
        .toList();

    for (var model in matches) {
      if (model.syncStatus == 'pending' || status == 'success') {
        model.syncStatus = status;
        model.error = error;
        if (syncedAt != null) model.syncedAt = syncedAt;
        await model.save();
      }
    }
  }

  @override
  Future<List<QuizGradeHistoryModel>> getQuizGradeHistory() async {
    final box = await _getQuizGradesBox();
    return box.values.toList();
  }

  @override
  Future<void> deleteQuizGradeHistory(String pendingKey) async {
    final box = await _getQuizGradesBox();
    await box.delete(pendingKey);
  }

  @override
  Future<void> clearQuizGradeHistory() async {
    final box = await _getQuizGradesBox();
    await box.clear();
  }
}
