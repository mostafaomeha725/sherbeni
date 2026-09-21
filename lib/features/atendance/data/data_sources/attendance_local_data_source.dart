import 'package:hive/hive.dart';
import '../model/attendance_model.dart';
import '../model/student_model.dart';
import '../model/session_model.dart';
import '../model/academic_class_model.dart';
import '../model/pending_quiz_grade_model.dart';

abstract class AttendanceLocalDataSource {
  Future<void> saveOfflineAttendance(AttendanceModel model);
  Future<void> deleteAttendance(int key);
  Future<void> deleteAttendances(List<int> keys);
  Future<List<AttendanceModel>> getOfflineAttendances();
  Future<List<AttendanceModel>> getOfflineAttendancesBySession(
    String sessionId,
  );
  Future<StudentModel?> getStudentByUid(String uid);

  Future<void> saveSessions(String classId, List<SessionModel> sessions);
  Future<List<SessionModel>> getOfflineSessions(String classId);

  Future<void> saveClasses(
    String subjectId,
    String classId,
    List<SessionModel> classes,
  );
  Future<List<SessionModel>?> getOfflineClasses(
    String subjectId,
    String classId,
  );
  Future<void> saveAcademicClasses(List<AcademicClassModel> classes);
  Future<List<AcademicClassModel>> getOfflineAcademicClasses();

  Future<void> saveSessionAttendancesCache(String sessionId, String jsonData);
  Future<String?> getSessionAttendancesCache(String sessionId);

  Future<void> saveSessionTotalCountCache(String sessionId, int totalItems);
  Future<int> getSessionTotalCountCache(String sessionId);

  Future<void> saveSessionQuizzesCache(String sessionId, String jsonData);
  Future<String?> getSessionQuizzesCache(String sessionId);
  Future<void> saveQuizStudentsCache(String key, String jsonData);
  Future<String?> getQuizStudentsCache(String key);

  Future<void> savePendingQuizGrade(PendingQuizGradeModel model);
  Future<List<PendingQuizGradeModel>> getPendingQuizGrades();
  Future<PendingQuizGradeModel?> getPendingQuizGrade(String key);
  Future<void> deletePendingQuizGrade(String key);
  Future<void> markPendingQuizGradeAsFailed(String key, String error);
}

class AttendanceLocalDataSourceImpl implements AttendanceLocalDataSource {
  @override
  Future<void> saveOfflineAttendance(AttendanceModel model) async {
    final box = Hive.box<AttendanceModel>('studentSessions');
    await box.add(model);
  }

  @override
  Future<void> deleteAttendance(int key) async {
    final box = Hive.box<AttendanceModel>('studentSessions');
    await box.delete(key);
  }

  @override
  Future<void> deleteAttendances(List<int> keys) async {
    final box = Hive.box<AttendanceModel>('studentSessions');
    await box.deleteAll(keys);
  }

  @override
  Future<List<AttendanceModel>> getOfflineAttendances() async {
    final box = Hive.box<AttendanceModel>('studentSessions');
    return box.values.toList();
  }

  @override
  Future<List<AttendanceModel>> getOfflineAttendancesBySession(
    String sessionId,
  ) async {
    final box = Hive.box<AttendanceModel>('studentSessions');
    return box.values
        .where((element) => element.sessionId == sessionId)
        .toList();
  }

  @override
  Future<StudentModel?> getStudentByUid(String uid) async {
    final box = Hive.isBoxOpen('students')
        ? Hive.box<StudentModel>('students')
        : await Hive.openBox<StudentModel>('students');

    for (var s in box.values) {
      if (s.id == uid) {
        return s;
      }
    }
    return null;
  }

  @override
  Future<void> savePendingQuizGrade(PendingQuizGradeModel model) async {
    final box = Hive.box<PendingQuizGradeModel>('pendingQuizGrades');
    await box.put(model.pendingKey, model); // Use put to prevent duplicates
  }

  @override
  Future<List<PendingQuizGradeModel>> getPendingQuizGrades() async {
    final box = Hive.box<PendingQuizGradeModel>('pendingQuizGrades');
    return box.values.toList();
  }

  @override
  Future<PendingQuizGradeModel?> getPendingQuizGrade(String key) async {
    final box = Hive.box<PendingQuizGradeModel>('pendingQuizGrades');
    return box.get(key);
  }

  @override
  Future<void> deletePendingQuizGrade(String key) async {
    final box = Hive.box<PendingQuizGradeModel>('pendingQuizGrades');
    await box.delete(key);
  }

  @override
  Future<void> markPendingQuizGradeAsFailed(String key, String error) async {
    final box = Hive.box<PendingQuizGradeModel>('pendingQuizGrades');
    final model = box.get(key);
    if (model != null) {
      model.error = error;
      await model.save(); // HiveObject save
    }
  }

  @override
  Future<void> saveSessions(String classId, List<SessionModel> sessions) async {
    final boxName = 'sessions_$classId';
    final box = Hive.isBoxOpen(boxName)
        ? Hive.box<SessionModel>(boxName)
        : await Hive.openBox<SessionModel>(boxName);

    await box.clear();
    await box.addAll(sessions);
  }

  @override
  Future<List<SessionModel>> getOfflineSessions(String classId) async {
    final boxName = 'sessions_$classId';
    final box = Hive.isBoxOpen(boxName)
        ? Hive.box<SessionModel>(boxName)
        : await Hive.openBox<SessionModel>(boxName);

    return box.values.toList();
  }

  @override
  Future<void> saveClasses(
    String subjectId,
    String classId,
    List<SessionModel> classes,
  ) async {
    final boxName = 'classes_${classId}_$subjectId';
    final box = Hive.isBoxOpen(boxName)
        ? Hive.box<SessionModel>(boxName)
        : await Hive.openBox<SessionModel>(boxName);

    await box.clear();
    await box.addAll(classes);
  }

  @override
  Future<List<SessionModel>?> getOfflineClasses(
    String subjectId,
    String classId,
  ) async {
    final boxName = 'classes_${classId}_$subjectId';
    if (!Hive.isBoxOpen(boxName) && !await Hive.boxExists(boxName)) {
      return null;
    }

    final box = Hive.isBoxOpen(boxName)
        ? Hive.box<SessionModel>(boxName)
        : await Hive.openBox<SessionModel>(boxName);

    return box.values.toList();
  }

  @override
  Future<void> saveSessionTotalCountCache(
    String sessionId,
    int totalItems,
  ) async {
    final box = Hive.isBoxOpen('attendancesTotalCount')
        ? Hive.box<int>('attendancesTotalCount')
        : await Hive.openBox<int>('attendancesTotalCount');
    await box.put(sessionId, totalItems);
  }

  @override
  Future<int> getSessionTotalCountCache(String sessionId) async {
    final box = Hive.isBoxOpen('attendancesTotalCount')
        ? Hive.box<int>('attendancesTotalCount')
        : await Hive.openBox<int>('attendancesTotalCount');
    return box.get(sessionId) ?? 0;
  }

  @override
  Future<void> saveSessionAttendancesCache(
    String sessionId,
    String jsonData,
  ) async {
    final box = Hive.isBoxOpen('attendancesCache')
        ? Hive.box<String>('attendancesCache')
        : await Hive.openBox<String>('attendancesCache');
    await box.put(sessionId, jsonData);
  }

  @override
  Future<String?> getSessionAttendancesCache(String sessionId) async {
    final box = Hive.isBoxOpen('attendancesCache')
        ? Hive.box<String>('attendancesCache')
        : await Hive.openBox<String>('attendancesCache');
    return box.get(sessionId);
  }

  @override
  Future<void> saveQuizStudentsCache(String key, String jsonData) async {
    final boxName = 'quiz_students_cache';
    final box = Hive.isBoxOpen(boxName)
        ? Hive.box<String>(boxName)
        : await Hive.openBox<String>(boxName);
    await box.put(key, jsonData);
  }

  @override
  Future<String?> getQuizStudentsCache(String key) async {
    final boxName = 'quiz_students_cache';
    final box = Hive.isBoxOpen(boxName)
        ? Hive.box<String>(boxName)
        : await Hive.openBox<String>(boxName);
    return box.get(key);
  }

  @override
  Future<void> saveSessionQuizzesCache(
    String sessionId,
    String jsonData,
  ) async {
    final boxName = 'quizzes_$sessionId';
    final box = Hive.isBoxOpen(boxName)
        ? Hive.box<String>(boxName)
        : await Hive.openBox<String>(boxName);

    await box.clear();
    await box.add(jsonData);
  }

  @override
  Future<String?> getSessionQuizzesCache(String sessionId) async {
    final boxName = 'quizzes_$sessionId';
    final box = Hive.isBoxOpen(boxName)
        ? Hive.box<String>(boxName)
        : await Hive.openBox<String>(boxName);

    return box.isNotEmpty ? box.getAt(0) : null;
  }

  @override
  Future<void> saveAcademicClasses(List<AcademicClassModel> classes) async {
    final box = Hive.isBoxOpen('academicClasses')
        ? Hive.box<AcademicClassModel>('academicClasses')
        : await Hive.openBox<AcademicClassModel>('academicClasses');

    await box.clear();
    await box.addAll(classes);
  }

  @override
  Future<List<AcademicClassModel>> getOfflineAcademicClasses() async {
    final box = Hive.isBoxOpen('academicClasses')
        ? Hive.box<AcademicClassModel>('academicClasses')
        : await Hive.openBox<AcademicClassModel>('academicClasses');

    return box.values.toList();
  }
}
