import 'package:qrattendance/core/network/network_service.dart';
import 'package:qrattendance/core/network/endpoints.dart';
import 'package:qrattendance/features/atendance/data/model/session_model.dart';
import 'package:qrattendance/features/atendance/data/model/academic_class_model.dart';
import 'package:qrattendance/features/atendance/data/model/manual_search_student_model.dart';

abstract class AttendanceRemoteDataSource {
  Future<Map<String, dynamic>> syncBatch(Map<String, dynamic> data);
  Future<Map<String, dynamic>> scanOnline(String qrCode, String sessionId);
  Future<Map<String, dynamic>> recordAttendance(Map<String, dynamic> data);
  Future<List<SessionModel>> getSessions(String classId);
  Future<List<SessionModel>> getClasses(String subjectId, String classId);
  Future<List<AcademicClassModel>> getAcademicClasses(String token);
  Future<Map<String, dynamic>> getSessionAttendances(
    String sessionId,
    int page,
    int limit,
  );
  Future<Map<String, dynamic>> deleteSessionAttendance(
    String sessionId,
    String attendanceId,
  );
  Future<Map<String, dynamic>> getSessionQuizzes(String sessionId);
  Future<Map<String, dynamic>> getSessionQuizGrades(
    String sessionId,
    String search,
    String gradingStatus,
  );

  Future<Map<String, dynamic>> addOrUpdateQuizGrade(
    String sessionId,
    String studentId,
    num grade,
  );

  Future<Map<String, dynamic>> syncBulkQuizGrades(
    String sessionId,
    List<Map<String, dynamic>> grades,
  );

  Future<Map<String, dynamic>> getSessionHomeworkGrades(
    String sessionId,
    String search,
    String gradingStatus,
  );

  Future<Map<String, dynamic>> addOrUpdateHomeworkGrade(
    String sessionId,
    String studentId,
    num grade,
  );

  Future<Map<String, dynamic>> syncBulkHomeworkGrades(
    String sessionId,
    List<Map<String, dynamic>> grades,
  );

  Future<ManualSearchStudentModel?> searchStudent(String query);
  Future<List<Map<String, dynamic>>> bulkSearchStudents(List<String> queries);
}

class AttendanceRemoteDataSourceImpl implements AttendanceRemoteDataSource {
  final NetworkService networkService;

  AttendanceRemoteDataSourceImpl(this.networkService);

  @override
  Future<Map<String, dynamic>> scanOnline(
    String qrCode,
    String sessionId,
  ) async {
    final resultEither = await networkService.postData(
      endPoint: EndPoints.onlineScan,
      data: {'qr_code': qrCode},
    );

    return resultEither.fold((failure) => throw failure, (response) {
      if (response['statusCode'] == 201 || response['statusCode'] == 200) {
        return response;
      } else {
        throw Exception(response['message'] ?? 'خطأ غير معروف من الخادم');
      }
    });
  }

  @override
  Future<Map<String, dynamic>> recordAttendance(
    Map<String, dynamic> data,
  ) async {
    final resultEither = await networkService.postData(
      endPoint: EndPoints.recordAttendance,
      data: data,
    );

    return resultEither.fold((failure) => throw failure, (response) {
      if (response['success'] == true ||
          response['statusCode'] == 200 ||
          response['statusCode'] == 201) {
        return response;
      } else {
        throw Exception(response['message'] ?? 'خطأ غير معروف من الخادم');
      }
    });
  }

  @override
  Future<Map<String, dynamic>> syncBatch(Map<String, dynamic> data) async {
    final resultEither = await networkService.postData(
      endPoint: EndPoints.offlineBulkRecord,
      data: data,
    );

    return resultEither.fold((failure) => throw failure, (response) {
      if (response['success'] == true || response['status'] == true) {
        return response;
      } else {
        throw Exception(response['message'] ?? 'خطأ غير معروف من الخادم');
      }
    });
  }

  @override
  Future<List<SessionModel>> getSessions(String classId) async {
    final resultEither = await networkService.getData(
      endPoint: EndPoints.mobileSubjects,
      queryParameters: {'class_id': classId},
    );

    return resultEither.fold((failure) => throw failure, (response) {
      if (response['success'] == true || response['statusCode'] == 200) {
        final data = response['data'] as List?;
        if (data != null) {
          return data.map((e) => SessionModel.fromJson(e)).toList();
        }
        return [];
      } else {
        throw Exception(response['message'] ?? 'فشل في جلب المواد');
      }
    });
  }

  @override
  Future<List<SessionModel>> getClasses(
    String subjectId,
    String classId,
  ) async {
    final resultEither = await networkService.getData(
      endPoint: EndPoints.mobileSessions,
      queryParameters: {'subject_id': subjectId, 'class_id': classId},
    );

    return resultEither.fold((failure) => throw failure, (response) {
      if (response['success'] == true || response['statusCode'] == 200) {
        final data = response['data'] as List?;
        if (data != null) {
          return data.map((e) => SessionModel.fromJson(e)).toList();
        }
        return [];
      } else {
        throw Exception(response['message'] ?? 'فشل في جلب الجلسات');
      }
    });
  }

  @override
  Future<Map<String, dynamic>> getSessionAttendances(
    String sessionId,
    int page,
    int limit,
  ) async {
    final resultEither = await networkService.getData(
      endPoint: EndPoints.getSessionAttendances(sessionId),
      queryParameters: {'page': page, 'limit': limit},
    );

    return resultEither.fold((failure) => throw failure, (response) {
      if (response['status'] == true || response['statusCode'] == 200) {
        return response;
      } else {
        throw Exception(response['message'] ?? 'فشل في جلب الحضور');
      }
    });
  }

  @override
  Future<Map<String, dynamic>> deleteSessionAttendance(
    String sessionId,
    String attendanceId,
  ) async {
    final resultEither = await networkService.deleteData(
      endPoint: EndPoints.deleteSessionAttendance(sessionId, attendanceId),
    );

    return resultEither.fold(
      (failureMsg) => throw Exception(failureMsg),
      (response) {
        if (response is Map<String, dynamic> &&
            (response['statusCode'] == 200 ||
                response['status'] == true ||
                response['statusCode'] == 204)) {
          return response;
        } else if (response is Map<String, dynamic>) {
          return response;
        } else {
          throw Exception('فشل في حذف الحضور');
        }
      },
    );
  }

  @override
  Future<Map<String, dynamic>> getSessionQuizzes(String sessionId) async {
    final resultEither = await networkService.getData(
      endPoint: EndPoints.getSessionQuizzes(sessionId),
    );

    return resultEither.fold((failure) => throw failure, (response) {
      if (response['status'] == true || response['statusCode'] == 200) {
        return response;
      } else {
        throw Exception(response['message'] ?? 'فشل في جلب الكويزات');
      }
    });
  }

  @override
  Future<Map<String, dynamic>> getSessionQuizGrades(
    String sessionId,
    String search,
    String gradingStatus,
  ) async {
    final resultEither = await networkService.getData(
      endPoint: EndPoints.getSessionQuizGrades(sessionId),
      queryParameters: {
        if (search.isNotEmpty) 'search': search,
        if (gradingStatus.isNotEmpty) 'status': gradingStatus,
      },
    );

    return resultEither.fold((failure) => throw failure, (response) {
      if (response['status'] == true || response['statusCode'] == 200) {
        return response;
      } else {
        throw Exception(response['message'] ?? 'فشل في جلب درجات الكويز');
      }
    });
  }

  @override
  Future<Map<String, dynamic>> addOrUpdateQuizGrade(
    String sessionId,
    String studentId,
    num grade,
  ) async {
    final resultEither = await networkService.postData(
      endPoint: EndPoints.addOrUpdateQuizGrade(sessionId),
      data: {'student_id': studentId, 'grade': grade},
    );

    return resultEither.fold((failure) => throw failure, (response) {
      if (response['status'] == true ||
          response['statusCode'] == 200 ||
          response['statusCode'] == 201) {
        return response;
      } else {
        throw Exception(response['message'] ?? 'فشل تحديث الدرجة');
      }
    });
  }

  @override
  Future<Map<String, dynamic>> syncBulkQuizGrades(
    String sessionId,
    List<Map<String, dynamic>> grades,
  ) async {
    final resultEither = await networkService.postData(
      endPoint: EndPoints.syncBulkQuizGrades(sessionId),
      data: {'grades': grades},
    );

    return resultEither.fold((failure) => throw failure, (response) {
      if (response['status'] == true ||
          response['statusCode'] == 200 ||
          response['statusCode'] == 201) {
        return response;
      } else {
        throw Exception(response['message'] ?? 'فشل مزامنة الدرجات');
      }
    });
  }

  @override
  Future<Map<String, dynamic>> syncBulkHomeworkGrades(
    String sessionId,
    List<Map<String, dynamic>> grades,
  ) async {
    final resultEither = await networkService.postData(
      endPoint: EndPoints.syncBulkHomeworkGrades(sessionId),
      data: {'grades': grades},
    );

    return resultEither.fold((failure) => throw failure, (response) {
      if (response['status'] == true ||
          response['statusCode'] == 200 ||
          response['statusCode'] == 201) {
        return response;
      } else {
        final code = response['statusCode'] ?? 400;
        throw Exception(
          '[$code] ${response['message'] ?? 'فشل مزامنة درجات الواجب'}',
        );
      }
    });
  }

  @override
  Future<List<AcademicClassModel>> getAcademicClasses(String token) async {
    final resultEither = await networkService.getData(
      endPoint: EndPoints.mobileClassesDropdownList,
    );

    return resultEither.fold((failure) => throw failure, (response) {
      if (response['success'] == true || response['statusCode'] == 200) {
        final data = response['data'] as List?;
        if (data != null) {
          return data.map((e) => AcademicClassModel.fromJson(e)).toList();
        }
        return [];
      } else {
        throw Exception(response['message'] ?? 'فشل في جلب الصفوف الدراسية');
      }
    });
  }

  @override
  Future<Map<String, dynamic>> getSessionHomeworkGrades(
    String sessionId,
    String search,
    String gradingStatus,
  ) async {
    final Map<String, dynamic> queryParams = {};
    if (search.isNotEmpty) queryParams['search'] = search;
    if (gradingStatus != 'all') queryParams['status'] = gradingStatus;

    final resultEither = await networkService.getData(
      endPoint: EndPoints.getSessionHomeworkGrades(sessionId),
      queryParameters: queryParams,
    );

    return resultEither.fold((failure) => throw failure, (response) {
      if (response['success'] == true || response['statusCode'] == 200) {
        return response;
      } else {
        throw Exception(response['message'] ?? 'فشل في جلب درجات الواجب');
      }
    });
  }

  @override
  Future<Map<String, dynamic>> addOrUpdateHomeworkGrade(
    String sessionId,
    String studentId,
    num grade,
  ) async {
    final resultEither = await networkService.postData(
      endPoint: EndPoints.addOrUpdateHomeworkGrade(sessionId),
      data: {'student_id': studentId, 'grade': grade},
    );

    return resultEither.fold((failure) => throw failure, (response) {
      if (response['success'] == true ||
          response['statusCode'] == 200 ||
          response['statusCode'] == 201) {
        return response;
      } else {
        throw Exception(response['message'] ?? 'فشل في حفظ درجة الواجب');
      }
    });
  }

  @override
  Future<ManualSearchStudentModel?> searchStudent(String query) async {
    final resultEither = await networkService.postData(
      endPoint: EndPoints.studentSearch,
      data: {'search': query},
    );

    return resultEither.fold((failure) => throw failure, (response) {
      if (response['status'] == true || response['statusCode'] == 200) {
        final data = response['data'];
        if (data == null || data is! Map<String, dynamic>) return null;
        return ManualSearchStudentModel.fromJson(data);
      } else {
        throw Exception(response['message'] ?? 'Student not found');
      }
    });
  }

  @override
  Future<List<Map<String, dynamic>>> bulkSearchStudents(
    List<String> queries,
  ) async {
    final resultEither = await networkService.postData(
      endPoint: EndPoints.studentSearchBulk,
      data: {'search': queries},
    );

    return resultEither.fold((failure) => throw failure, (response) {
      if (response['status'] == true || response['statusCode'] == 200) {
        final data = response['data'];
        if (data == null || data is! List) return [];
        return List<Map<String, dynamic>>.from(data);
      } else {
        throw Exception(response['message'] ?? 'Students not found');
      }
    });
  }
}
