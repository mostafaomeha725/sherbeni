import 'package:dartz/dartz.dart';
import 'package:qrattendance/core/error/failure.dart';
import '../entities/session_entity.dart';
import '../entities/academic_class_entity.dart';
import '../entities/student_entity.dart';
import '../entities/session_attendance_entity.dart';
import '../entities/manual_search_student_entity.dart';

abstract class AttendanceRepository {
  Future<Either<Failure, String>> saveOfflineAttendance({
    required String uid,
    required String sessionId,
    String? sessionName,
    String? scanTime,
  });

  Future<Either<Failure, String>> saveOfflineSearch({
    required String query,
    required String sessionId,
    required String sessionName,
  });

  Future<Either<Failure, String>> recordOnlineAttendance({
    required String uid,
    required String sessionId,
  });

  Future<Either<Failure, Map<String, dynamic>>> syncOfflineData();

  Future<Either<Failure, Unit>> retrySpecificOfflineAttendance(
    String pendingKey,
  );

  Future<Either<Failure, Map<String, dynamic>>> retryAllOfflineAttendance();

  Future<Either<Failure, StudentEntity>> scanOnlineAttendance({
    required String qrCode,
    required String sessionId,
  });

  Future<Either<Failure, List<SessionEntity>>> fetchSessions({
    required String token,
    required String classId,
  });

  Future<Either<Failure, List<AcademicClassEntity>>> fetchAcademicClasses({
    required String token,
  });

  Future<Either<Failure, List<AcademicClassEntity>>> getCachedAcademicClasses();

  Future<Either<Failure, List<SessionEntity>>> getCachedSessions({
    required String classId,
  });

  Future<Either<Failure, List<SessionEntity>>> fetchClasses({
    required String subjectId,
    required String classId,
  });

  Future<Either<Failure, List<SessionEntity>>> getCachedClasses({
    required String subjectId,
    required String classId,
  });

  Future<Either<Failure, StudentEntity>> fetchStudentDataLocally({
    required String uid,
  });

  Future<Either<Failure, Map<String, dynamic>>> getSessionAttendances(
    String sessionId,
    int page,
    int limit,
  );
  Future<Either<Failure, String>> deleteSessionAttendance({
    required String sessionId,
    required String attendanceId,
  });
  Future<Either<Failure, List<SessionAttendanceEntity>>>
  getOfflineSessionAttendances(String sessionId);
  Future<Either<Failure, List<dynamic>>> getSessionQuizzes(String sessionId);
  Future<Either<Failure, List<dynamic>?>> getCachedSessionQuizzes(
    String sessionId,
  );

  Future<Either<Failure, Map<String, dynamic>>> getSessionQuizGrades(
    String sessionId,
    String search,
    String gradingStatus,
  );

  Future<Either<Failure, Map<String, dynamic>?>> getCachedSessionQuizGrades(
    String sessionId,
  );

  Future<Either<Failure, Map<String, dynamic>>> addOrUpdateQuizGrade(
    String sessionId,
    String? sessionName,
    String studentId,
    num grade,
  );

  Future<Either<Failure, Map<String, dynamic>>> getSessionHomeworkGrades(
    String sessionId,
    String search,
    String gradingStatus,
  );

  Future<Either<Failure, Map<String, dynamic>?>> getCachedSessionHomeworkGrades(
    String sessionId,
  );

  Future<Either<Failure, Map<String, dynamic>>> addOrUpdateHomeworkGrade(
    String sessionId,
    String? sessionName,
    String studentId,
    num grade,
  );

  Future<Either<Failure, ManualSearchStudentEntity?>> searchStudent(
    String query,
  );

  Future<Either<Failure, List<ManualSearchStudentEntity>>> bulkSearchStudents(
    List<String> queries,
  );
}
