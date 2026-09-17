import 'package:dartz/dartz.dart';
import 'package:qrattendance/core/error/failure.dart';
import '../entities/session_entity.dart';
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
  });

  Future<Either<Failure, List<SessionEntity>>> getCachedSessions();

  Future<Either<Failure, List<SessionEntity>>> fetchClasses({
    required String subjectId,
  });

  Future<Either<Failure, List<SessionEntity>>> getCachedClasses({
    required String subjectId,
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

  Future<Either<Failure, Map<String, dynamic>>> getQuizStudents(
    String sessionId,
    String quizTemplateId,
    int page,
    int limit,
    String search,
    String gradingStatus,
  );

  Future<Either<Failure, Map<String, dynamic>?>> getCachedQuizStudents(
    String sessionId,
    String quizTemplateId,
  );

  Future<Either<Failure, Map<String, dynamic>>> updateQuizGrade(
    String quizAttemptId,
    num grade,
    String sessionId,
    String quizTemplateId,
  );
}
