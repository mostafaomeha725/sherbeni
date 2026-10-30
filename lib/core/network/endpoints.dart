class EndPoints {
  static const String apiSecret = 'kJ5kHX2vCfiy0zc2mWulKgZy0TFo6pTF';

  static const String mobileLogin = 'api/v1/mobile/login';
  static const String mobileLogout = 'api/v1/mobile/logout';
  static const String refreshToken = 'api/v1/auth/refresh';
  static const String mobileSubjects = 'api/v1/mobile/subjects';
  static const String mobileClassesDropdownList =
      'api/v1/mobile/classes/dropdown/list';
  static const String mobileSessions = 'api/v1/mobile/sessions';
  static String getSessionQuizzes(String sessionId) =>
      'api/v1/mobile/sessions/$sessionId/quizzes';
  static String getSessionQuizGrades(String sessionId) =>
      'api/v1/mobile/sessions/$sessionId/quiz-grades';
  static String addOrUpdateQuizGrade(String sessionId) =>
      'api/v1/mobile/sessions/$sessionId/quiz-grades';
  static String syncBulkQuizGrades(String sessionId) =>
      'api/v1/mobile/sessions/$sessionId/quiz-grades/bulk';
  static String getSessionHomeworkGrades(String sessionId) =>
      'api/v1/mobile/sessions/$sessionId/homework-grades';
  static String addOrUpdateHomeworkGrade(String sessionId) =>
      'api/v1/mobile/sessions/$sessionId/homework-grades';
  static String syncBulkHomeworkGrades(String sessionId) =>
      'api/v1/mobile/sessions/$sessionId/homework-grades/bulk';
  static const String onlineScan = 'api/v1/mobile/attendance/scan';
  static String getSessionAttendances(String sessionId) =>
      'api/v1/mobile/sessions/$sessionId/attendances';
  static String deleteSessionAttendance(
    String sessionId,
    String attendanceId,
  ) => 'api/v1/mobile/sessions/$sessionId/attendances/$attendanceId';
  static const String recordAttendance = 'mobile/attendance';
  static const String offlineBulkRecord = 'mobile/attendance/bulk';
  static const String studentSearch = 'api/v1/mobile/attendance/student/search';
  static const String studentSearchBulk =
      'api/v1/mobile/attendance/student/search/bulk';
}
