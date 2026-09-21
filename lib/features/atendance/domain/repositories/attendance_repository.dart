import 'package:dartz/dartz.dart';
import 'package:qrattendance/core/error/failure.dart';
import '../entities/session_entity.dart';
import '../entities/academic_class_entity.dart';
import '../entities/student_entity.dart';
import '../entities/session_attendance_entity.dart';

abstract class AttendanceRepository {
  Future<Either<Failure, String>> saveOfflineAttendance({
    required String uid,
    required String sessionId,
    String? scanTime,
  });

  Future<Either<Failure, String>> recordOnlineAttendance({
    required String uid,
    required String sessionId,
  });

  Future<Either<Failure, Map<String, dynamic>>> syncOfflineData();

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
    String studentId,
    num grade,
  );
}
