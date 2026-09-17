import 'dart:convert';
import 'dart:io';

import 'package:chucker_flutter/chucker_flutter.dart';
import 'package:crypto/crypto.dart';
import 'package:dartz/dartz.dart';
import 'package:qrattendance/core/cache/preferences_storage.dart';
import 'package:qrattendance/core/constants/strings.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '/core/di/services_locator.dart';
import '/core/error/failure.dart';
import '/core/network/endpoints.dart';
import 'authorization_interceptor.dart';

class NetworkService {
  final Dio dio;

  NetworkService(this.dio) {
    dio.options
      ..baseUrl = AppStrings.baseUrl
      ..responseType = ResponseType.json
      ..followRedirects = false
      ..receiveDataWhenStatusError = true
      ..connectTimeout = const Duration(seconds: 30)
      ..receiveTimeout = const Duration(seconds: 30);

    addHeaders();
    addInterceptors();
  }

  void addInterceptors() {
    dio.interceptors.add(AuthorizationInterceptor());

    // if (isDevEnviroment()) {
    dio.interceptors.add(ChuckerDioInterceptor());
    dio.interceptors.add(
      PrettyDioLogger(requestBody: true, requestHeader: true),
    );
    // }
  }

  void addHeaders() {
    final prefs = sl<PreferencesStorage>();

    final token = prefs.getUserToken();

    dio.options.headers = {
      "Accept": "application/json",
      "Accept-Encoding": "gzip, deflate, br",

      if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
    };
  }

  void addToken(String token) {
    dio.options.headers['Authorization'] = "Bearer $token";
  }

  void removeToken() {
    dio.options.headers.remove('Authorization');
  }

  Future<Either<Failure, dynamic>> postData({
    required String endPoint,
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    String? token,
    bool isRaw = true,
  }) async {
    try {
      var response = await dio.post(
        endPoint,
        data: data == null
            ? null
            : isRaw
            ? data
            : FormData.fromMap(data),
        queryParameters: queryParameters,
      );

      if (response.statusCode! >= 200 && response.statusCode! <= 299) {
        final body = response.data;
        if (body is Map<String, dynamic> && body['status'] == false) {
          return Left(Failure(body['message']?.toString() ?? 'Request failed'));
        }
        return Right(body);
      } else {
        final body = response.data;
        String? msg;
        if (body is Map<String, dynamic>) {
          // errors as List: {"errors": [{"description": "..."}]}
          if (body['errors'] is List && (body['errors'] as List).isNotEmpty) {
            final first = (body['errors'] as List).first;
            if (first is Map<String, dynamic>) {
              msg = first['description']?.toString();
            }
          }
          // errors as Map: {"errors": {"Field": ["..."]}}
          if (msg == null && body['errors'] is Map) {
            for (final fieldErrors in (body['errors'] as Map).values) {
              if (fieldErrors is List && fieldErrors.isNotEmpty) {
                msg = fieldErrors.first.toString();
                break;
              }
            }
          }
          // top-level detail field (e.g. FluentValidation 500 errors)
          if (msg == null && body['detail'] != null) {
            msg = body['detail'].toString();
          }
          msg ??= body['message']?.toString() ?? body['title']?.toString();
        }

        // Handle specific error codes if available
        if (body is Map<String, dynamic> &&
            body['errors'] is List &&
            (body['errors'] as List).isNotEmpty) {
          final first = (body['errors'] as List).first;
          if (first is Map<String, dynamic> &&
              first['code'] == 'EMAIL_NOT_VERIFIED') {
            return Left(
              EmailNotVerifiedFailure(message: msg ?? 'Email is not verified'),
            );
          }
        }

        return Left(Failure(msg ?? 'Error ${response.statusCode}'));
      }
    } on SocketException {
      return const Left(Failure("لا يوجد اتصال بالإنترنت، يرجى التحقق من الشبكة"));
    } on FormatException {
      return const Left(Failure("Format Exception"));
    } on DioException catch (e) {
      return handleDioExceoptions(e);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, dynamic>> postEncryptedData({
    required String endPoint,
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    String? token,
    bool isRaw = true,
  }) async {
    // Convert payload to JSON string
    String jsonPayload = jsonEncode(data);

    // Calculate HMAC SHA256 signature
    String signature = hmacSha256(jsonPayload);

    // Encode the signature as Base64
    String encodedSignature = base64.encode(utf8.encode(signature));

    dio.options.headers['X-Signature'] = encodedSignature;

    try {
      var response = await dio.post(
        endPoint,
        data: data == null
            ? null
            : isRaw
            ? data
            : FormData.fromMap(data),
        queryParameters: queryParameters,
      );

      if (response.statusCode! >= 200 && response.statusCode! <= 299) {
        return Right(response.data);
      } else {
        return Left(Failure(response.data['message'].toString()));
      }
    } on SocketException {
      return const Left(Failure("لا يوجد اتصال بالإنترنت، يرجى التحقق من الشبكة"));
    } on FormatException {
      return const Left(Failure("Format Exception"));
    } on DioException catch (e) {
      return handleDioExceoptions(e);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<Failure, dynamic>> uploadFile({
    required String endPoint,
    required FormData formData,
    Map<String, dynamic>? queryParameters,
    String? token,
  }) async {
    try {
      var response = await dio.post(
        endPoint,
        data: formData,
        queryParameters: queryParameters,
      );
      return Right(response.data);
    } on SocketException {
      return const Left(Failure("لا يوجد اتصال بالإنترنت، يرجى التحقق من الشبكة"));
    } on FormatException {
      return const Left(Failure("Format Exception"));
    } on DioException catch (e) {
      return handleDioExceoptions(e);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<String, dynamic>> downloadFile({
    required String fileUrl,
    required String savePath,
    Map<String, dynamic>? queryParameters,
    String? token,
  }) async {
    dio.options.headers = {"Accept": "*/*"};

    try {
      var response = await dio.download(
        fileUrl,
        savePath,
        queryParameters: queryParameters,
        onReceiveProgress: (received, total) {
          // You can use these values to show download progress
          // safePrint(
          //     'downloadFile =>Received: ${received.toString()}, Total: ${total.toString()}');

          if (total != -1) {
            // Calculate download progress percentage
            // double progress = (received / total * 100);
            // safePrint('downloadFile => progress: ${progress.toString()}}');
          }
        },
      );
      return Right(response);
    } catch (e) {
      debugPrint(e.toString());
      return Left(e.toString());
    }
  }

  Future<Either<Failure, dynamic>> putData({
    required String endPoint,
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    String? token,
  }) async {
    try {
      var response = await dio.put(
        endPoint,
        data: data,
        queryParameters: queryParameters,
      );
      return Right(response.data);
    } on SocketException {
      return const Left(Failure("لا يوجد اتصال بالإنترنت، يرجى التحقق من الشبكة"));
    } on FormatException {
      return const Left(Failure("Format Exception"));
    } on DioException catch (e) {
      return handleDioExceoptions(e);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<String, dynamic>> patchData({
    required String endPoint,
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    String? token,
    bool isRaw = true,
  }) async {
    try {
      var response = await dio.patch(
        endPoint,
        queryParameters: queryParameters,
        data: data == null
            ? null
            : isRaw
            ? data
            : FormData.fromMap(data),
      );
      return Right(response.data);
    } on SocketException {
      return const Left("لا يوجد اتصال بالإنترنت، يرجى التحقق من الشبكة");
    } on FormatException {
      return const Left("Format Exception");
    } on DioException catch (e) {
      if (e.type == DioExceptionType.badResponse) {
        final message = _extractErrorMessage(
          e.response?.data,
          fallback: e.message ?? 'Bad response',
        );
        return Left(message);
      } else if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.connectionError) {
        // safePrint('check your connection');
        return const Left("لا يوجد اتصال بالإنترنت، يرجى التحقق من الشبكة");
      } else if (e.type == DioExceptionType.receiveTimeout) {
        // safePrint('unable to connect to the server');
        return const Left("Unable to connect to the server");
      } else {
        return Left(e.message ?? "");
      }
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, dynamic>> deleteData({
    required String endPoint,
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    String? token,
  }) async {
    try {
      var response = await dio.delete(
        endPoint,
        data: data,
        queryParameters: queryParameters,
      );
      return Right(response.data);
    } on SocketException {
      return const Left("لا يوجد اتصال بالإنترنت، يرجى التحقق من الشبكة");
    } on FormatException {
      return const Left("Format Exception");
    } on DioException catch (e) {
      if (e.type == DioExceptionType.badResponse) {
        final message = _extractErrorMessage(
          e.response?.data,
          fallback: e.message ?? 'Bad response',
        );
        return Left(message);
      } else if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.connectionError) {
        // safePrint('check your connection');
        return const Left("لا يوجد اتصال بالإنترنت، يرجى التحقق من الشبكة");
      } else if (e.type == DioExceptionType.receiveTimeout) {
        // safePrint('unable to connect to the server');
        return const Left("Unable to connect to the server");
      } else {
        return Left(e.message ?? "");
      }
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<Failure, dynamic>> getData({
    required String endPoint,
    Map<String, dynamic>? queryParameters,
    String? token,
  }) async {
    try {
      var response = await dio.get(endPoint, queryParameters: queryParameters);
      if (response.statusCode! >= 200 && response.statusCode! <= 299) {
        return Right(response.data);
      } else {
        final message = _extractErrorMessage(
          response.data,
          fallback: 'Error ${response.statusCode}',
        );
        return Left(Failure(message));
      }
    } on SocketException {
      return const Left(Failure("لا يوجد اتصال بالإنترنت، يرجى التحقق من الشبكة"));
    } on FormatException {
      return const Left(Failure("Format Exception"));
    } on DioException catch (e) {
      if (e.type == DioExceptionType.badResponse) {
        final message = _extractErrorMessage(
          e.response?.data,
          fallback: e.message ?? 'Bad response',
        );
        return Left(Failure(message));
        // return Left(_l)(e.message);
      } else if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.connectionError) {
        // safePrint('check your connection');
        return const Left(Failure("لا يوجد اتصال بالإنترنت، يرجى التحقق من الشبكة"));
      } else if (e.type == DioExceptionType.receiveTimeout) {
        return const Left(Failure("تعذر الاتصال بالخادم"));
      } else {
        return Left(Failure(e.message ?? ""));
        // return const Left("Check internet connection");
      }
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  Left<Failure, dynamic> handleDioExceoptions(DioException e) {
    if (e.type == DioExceptionType.badResponse) {
      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        // Handle validation errors as Map: { "errors": { "Email": ["..."], "PhoneNumber": ["..."] } }
        if (data['errors'] is Map) {
          final errors = data['errors'] as Map;
          for (final fieldErrors in errors.values) {
            if (fieldErrors is List && fieldErrors.isNotEmpty) {
              return Left(Failure(fieldErrors.first.toString()));
            }
          }
        }
        // Handle errors as List: { "errors": [{"description": "..."}] }
        if (data['errors'] is List && (data['errors'] as List).isNotEmpty) {
          final firstError = (data['errors'] as List).first;
          if (firstError is Map<String, dynamic>) {
            final desc =
                firstError['description']?.toString() ?? 'Unknown error';
            if (firstError['code'] == 'EMAIL_NOT_VERIFIED') {
              return Left(EmailNotVerifiedFailure(message: desc));
            }
            return Left(Failure(desc));
          }
        }
        // Handle top-level detail field (e.g. FluentValidation 500 errors)
        if (data['detail'] != null) {
          return Left(Failure(data['detail'].toString()));
        }
        // Handle message field format
        if (data['message'] != null) {
          return Left(Failure(data['message'].toString()));
        }
        // Fallback to title
        if (data['title'] != null) {
          return Left(Failure(data['title'].toString()));
        }
      }
      return Left(Failure(e.message ?? 'Something went wrong'));
    } else if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.connectionError) {
      return const Left(Failure("لا يوجد اتصال بالإنترنت، يرجى التحقق من الشبكة"));
    } else if (e.type == DioExceptionType.receiveTimeout) {
      return const Left(Failure("تعذر الاتصال بالخادم"));
    } else {
      return Left(Failure(e.message ?? ""));
    }
  }

  String _extractErrorMessage(dynamic data, {required String fallback}) {
    if (data is Map<String, dynamic>) {
      final errors = data['errors'];

      if (errors is List && errors.isNotEmpty) {
        final first = errors.first;
        if (first is Map<String, dynamic>) {
          final description = first['description'];
          if (description is String && description.isNotEmpty) {
            return description;
          }
          final message = first['message'];
          if (message is String && message.isNotEmpty) {
            return message;
          }
        }
        if (first is String && first.isNotEmpty) {
          return first;
        }
      }

      if (errors is Map) {
        for (final value in errors.values) {
          if (value is List && value.isNotEmpty) {
            final first = value.first;
            if (first is String && first.isNotEmpty) {
              return first;
            }
          }
          if (value is String && value.isNotEmpty) {
            return value;
          }
        }
      }

      final message = data['message'];
      if (message is String && message.isNotEmpty) {
        return message;
      }

      final title = data['title'];
      if (title is String && title.isNotEmpty) {
        return title;
      }
    }

    return fallback;
  }

  String hmacSha256(String data) {
    var hmacSha256 = Hmac(
      sha256,
      utf8.encode(EndPoints.apiSecret),
    ); // HMAC-SHA256
    var digest = hmacSha256.convert(utf8.encode(data));
    return digest.toString();
  }
}
