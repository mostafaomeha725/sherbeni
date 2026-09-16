import 'package:qrattendance/core/network/network_service.dart';
import 'package:qrattendance/core/network/endpoints.dart';
import 'package:qrattendance/features/atendance/data/model/session_model.dart';

abstract class AttendanceRemoteDataSource {
  Future<Map<String, dynamic>> syncBatch(Map<String, dynamic> data);
  Future<Map<String, dynamic>> scanOnline(String qrCode, String sessionId);
  Future<Map<String, dynamic>> recordAttendance(Map<String, dynamic> data);
  Future<List<SessionModel>> getSessions();
  Future<List<SessionModel>> getClasses(String subjectId);
  Future<Map<String, dynamic>> getSessionAttendances(String sessionId, int page, int limit);
}

class AttendanceRemoteDataSourceImpl implements AttendanceRemoteDataSource {
  final NetworkService networkService;

  AttendanceRemoteDataSourceImpl(this.networkService);

  @override
  Future<Map<String, dynamic>> scanOnline(String qrCode, String sessionId) async {
    final resultEither = await networkService.postData(
      endPoint: EndPoints.onlineScan,
      data: {
        'qr_code': qrCode,
      },
    );

    return resultEither.fold(
      (failure) => throw failure,
      (response) {
        if (response['statusCode'] == 201 || response['statusCode'] == 200) {
          return response;
        } else {
          throw Exception(response['message'] ?? 'خطأ غير معروف من الخادم');
        }
      },
    );
  }

  @override
  Future<Map<String, dynamic>> recordAttendance(Map<String, dynamic> data) async {
    final resultEither = await networkService.postData(
      endPoint: EndPoints.recordAttendance,
      data: data,
    );

    return resultEither.fold(
      (failure) => throw failure,
      (response) {
        if (response['success'] == true || response['statusCode'] == 200 || response['statusCode'] == 201) {
          return response;
        } else {
          throw Exception(response['message'] ?? 'خطأ غير معروف من الخادم');
        }
      },
    );
  }

  @override
  Future<Map<String, dynamic>> syncBatch(Map<String, dynamic> data) async {
    final resultEither = await networkService.postData(
      endPoint: EndPoints.offlineBulkRecord,
      data: data,
    );

    return resultEither.fold(
      (failure) => throw failure,
      (response) {
        if (response['success'] == true || response['status'] == true) {
          return response;
        } else {
          throw Exception(response['message'] ?? 'خطأ غير معروف من الخادم');
        }
      },
    );
  }

  @override
  Future<List<SessionModel>> getSessions() async {
    final resultEither = await networkService.getData(
      endPoint: EndPoints.mobileSubjects,
    );

    return resultEither.fold(
      (failure) => throw failure,
      (response) {
        if (response['success'] == true || response['statusCode'] == 200) {
          final data = response['data'] as List?;
          if (data != null) {
            return data.map((e) => SessionModel.fromJson(e)).toList();
          }
          return [];
        } else {
          throw Exception(response['message'] ?? 'فشل في جلب المواد');
        }
      },
    );
  }

  @override
  Future<List<SessionModel>> getClasses(String subjectId) async {
    final resultEither = await networkService.getData(
      endPoint: EndPoints.mobileSessions,
      queryParameters: {'subject_id': subjectId},
    );

    return resultEither.fold(
      (failure) => throw failure,
      (response) {
        if (response['success'] == true || response['statusCode'] == 200) {
          final data = response['data'] as List?;
          if (data != null) {
            return data.map((e) => SessionModel.fromJson(e)).toList();
          }
          return [];
        } else {
          throw Exception(response['message'] ?? 'فشل في جلب الجلسات');
        }
      },
    );
  }

  @override
  Future<Map<String, dynamic>> getSessionAttendances(String sessionId, int page, int limit) async {
    final resultEither = await networkService.getData(
      endPoint: EndPoints.getSessionAttendances(sessionId),
      queryParameters: {
        'page': page,
        'limit': limit,
      },
    );

    return resultEither.fold(
      (failure) => throw failure,
      (response) {
        if (response['status'] == true || response['statusCode'] == 200) {
          return response;
        } else {
          throw Exception(response['message'] ?? 'فشل في جلب الحضور');
        }
      },
    );
  }
}
