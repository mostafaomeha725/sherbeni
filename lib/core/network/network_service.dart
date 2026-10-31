import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
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

  NetworkService(this.dio, {Dio Function()? retryDioFactory}) {
    dio.options
      ..baseUrl = AppStrings.baseUrl
      ..responseType = ResponseType.json
      ..followRedirects = false
      ..receiveDataWhenStatusError = true
      ..connectTimeout = const Duration(seconds: 30)
      ..receiveTimeout = const Duration(seconds: 30);

    addHeaders();
    addInterceptors(retryDioFactory: retryDioFactory);
  }

  void addInterceptors({Dio Function()? retryDioFactory}) {
    dio.interceptors.add(
      AuthorizationInterceptor(retryDioFactory: retryDioFactory),
    );
    dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: false,
        requestBody: false,
        responseBody: false,
        error: false,
      ),
    );
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

  static Future<bool> Function()? internetCheckerOverride;

  static Future<bool> hasInternetReachability() async {
    if (internetCheckerOverride != null) {
      return await internetCheckerOverride!();
    }
    try {
      final uri = Uri.parse(AppStrings.baseUrl);
      final host = uri.host;
      // Default to 443 for HTTPS, 80 for HTTP if port is not specified
      final port = uri.hasPort ? uri.port : (uri.scheme == 'https' ? 443 : 80);

      final socket = await Socket.connect(
        host,
        port,
        timeout: const Duration(seconds: 3),
      );
      socket.destroy();
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> isInternetAvailable() async {
    if (internetCheckerOverride != null) {
      return await internetCheckerOverride!();
    }

    try {
      if (sl.isRegistered<Connectivity>()) {
        final connectivityResult = await sl<Connectivity>().checkConnectivity();
        final hasInterface =
            connectivityResult.contains(ConnectivityResult.wifi) ||
            connectivityResult.contains(ConnectivityResult.mobile) ||
            connectivityResult.contains(ConnectivityResult.ethernet);
        if (!hasInterface) {
          return false;
        }
      }

      final dnsResult = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 3));
      if (dnsResult.isNotEmpty && dnsResult[0].rawAddress.isNotEmpty) {
        return true;
      }
    } catch (_) {
      try {
        final socket = await Socket.connect(
          '8.8.8.8',
          53,
          timeout: const Duration(seconds: 3),
        );
        socket.destroy();
        return true;
      } catch (_) {
        return false;
      }
    }
    return false;
  }

  Future<Either<Failure, dynamic>> postData({
    required String endPoint,
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    String? token,
    bool isRaw = true,
    int? expectedStatusCode,
    bool skipAuthRefresh = false,
  }) async {
    final isLogoutRequest = endPoint.endsWith(EndPoints.mobileLogout);
    try {
      var response = await dio.post(
        endPoint,
        data: data == null
            ? null
            : isRaw
            ? data
            : FormData.fromMap(data),
        queryParameters: queryParameters,
        options: skipAuthRefresh
            ? Options(extra: {'auth_logout_request': true})
            : null,
      );

      if (isLogoutRequest) {
        final responseData = response.data;
        final bodyStatusCode = responseData is Map
            ? responseData['statusCode']
            : null;
        log(
          'Logout API response: httpStatus=${response.statusCode}; '
          'bodyStatusCode=$bodyStatusCode; '
          'serverMessage=${_safeLogoutServerMessage(responseData)}.',
          name: 'NetworkService',
        );
      }

      if (expectedStatusCode != null &&
          response.statusCode != expectedStatusCode) {
        if (isLogoutRequest) {
          log(
            'Logout API rejected: expectedHttpStatus=$expectedStatusCode; '
            'actualHttpStatus=${response.statusCode}.',
            name: 'NetworkService',
          );
        }
        return Left(Failure('Unexpected HTTP status ${response.statusCode}.'));
      }

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
      if (isLogoutRequest) {
        log(
          'Logout API failed: type=SocketException; '
          'httpStatus=unavailable; serverMessage=unavailable.',
          name: 'NetworkService',
        );
      }
      final isOnline = await isInternetAvailable();
      if (!isOnline) {
        return const Left(
          NetworkFailure(
            message: "لا يوجد اتصال بالإنترنت، تحقق من اتصالك وحاول مرة أخرى.",
          ),
        );
      }
      return const Left(
        ServerFailure(
          message: "تعذر الاتصال بالخادم، يرجى المحاولة لاحقًا.",
        ),
      );
    } on FormatException {
      if (isLogoutRequest) {
        log(
          'Logout API failed: type=FormatException; '
          'httpStatus=unavailable; serverMessage=unavailable.',
          name: 'NetworkService',
        );
      }
      return const Left(Failure("Format Exception"));
    } on DioException catch (e) {
      if (isLogoutRequest) {
        log(
          'Logout API failed: type=${e.type}; '
          'httpStatus=${e.response?.statusCode ?? 'unavailable'}; '
          'serverMessage=${_safeLogoutServerMessage(e.response?.data)}.',
          name: 'NetworkService',
        );
      }
      return await handleDioExceoptions(e);
    } catch (e) {
      if (isLogoutRequest) {
        log(
          'Logout API failed: type=${e.runtimeType}; '
          'httpStatus=unavailable; serverMessage=unavailable.',
          name: 'NetworkService',
        );
      }
      return Left(Failure(e.toString()));
    }
  }

  String _safeLogoutServerMessage(dynamic data) {
    final message = data is Map ? data['message'] ?? data['detail'] : null;
    if (message is! String || message.trim().isEmpty) return 'unavailable';

    var safeMessage = message
        .replaceAll(
          RegExp(r'Bearer\s+[^\s,;]+', caseSensitive: false),
          'Bearer [REDACTED]',
        )
        .replaceAll(
          RegExp(r'\beyJ[A-Za-z0-9_-]*\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\b'),
          '[REDACTED]',
        )
        .replaceAll(
          RegExp(
            r'(access[_-]?token|refresh[_-]?token|token)\s*[:=]\s*[^\s,;]+',
            caseSensitive: false,
          ),
          'credential=[REDACTED]',
        )
        .replaceAll(RegExp(r'\b[A-Za-z0-9._~-]{32,}\b'), '[REDACTED]')
        .trim();
    if (safeMessage.length > 200) {
      safeMessage = '${safeMessage.substring(0, 200)}…';
    }
    return safeMessage;
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

    try {
      var response = await dio.post(
        endPoint,
        data: data == null
            ? null
            : isRaw
            ? data
            : FormData.fromMap(data),
        queryParameters: queryParameters,
        options: Options(headers: {'X-Signature': encodedSignature}),
      );

      if (response.statusCode! >= 200 && response.statusCode! <= 299) {
        return Right(response.data);
      } else {
        return Left(Failure(response.data['message'].toString()));
      }
    } on SocketException {
      final isOnline = await isInternetAvailable();
      if (!isOnline) {
        return const Left(
          NetworkFailure(
            message: "لا يوجد اتصال بالإنترنت، تحقق من اتصالك وحاول مرة أخرى.",
          ),
        );
      }
      return const Left(
        ServerFailure(
          message: "تعذر الاتصال بالخادم، يرجى المحاولة لاحقًا.",
        ),
      );
    } on FormatException {
      return const Left(Failure("Format Exception"));
    } on DioException catch (e) {
      return await handleDioExceoptions(e);
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
      final isOnline = await isInternetAvailable();
      if (!isOnline) {
        return const Left(
          NetworkFailure(
            message: "لا يوجد اتصال بالإنترنت، تحقق من اتصالك وحاول مرة أخرى.",
          ),
        );
      }
      return const Left(
        ServerFailure(
          message: "تعذر الاتصال بالخادم، يرجى المحاولة لاحقًا.",
        ),
      );
    } on FormatException {
      return const Left(Failure("Format Exception"));
    } on DioException catch (e) {
      return await handleDioExceoptions(e);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  Future<Either<String, dynamic>> downloadFile({
    required String fileUrl,
    required String savePath,
    Map<String, dynamic>? queryParameters,
    String? token,
    ProgressCallback? onReceiveProgress,
    CancelToken? cancelToken,
    bool deleteOnError = true,
  }) async {
    try {
      var response = await dio.download(
        fileUrl,
        savePath,
        queryParameters: queryParameters,
        options: Options(headers: {"Accept": "*/*"}),
        cancelToken: cancelToken,
        deleteOnError: deleteOnError,
        onReceiveProgress: onReceiveProgress,
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
      final isOnline = await isInternetAvailable();
      if (!isOnline) {
        return const Left(
          NetworkFailure(
            message: "لا يوجد اتصال بالإنترنت، تحقق من اتصالك وحاول مرة أخرى.",
          ),
        );
      }
      return const Left(
        ServerFailure(
          message: "تعذر الاتصال بالخادم، يرجى المحاولة لاحقًا.",
        ),
      );
    } on FormatException {
      return const Left(Failure("Format Exception"));
    } on DioException catch (e) {
      return await handleDioExceoptions(e);
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
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.connectionError) {
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
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.connectionError) {
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
      final isOnline = await isInternetAvailable();
      if (!isOnline) {
        return const Left(
          NetworkFailure(
            message: "لا يوجد اتصال بالإنترنت، تحقق من اتصالك وحاول مرة أخرى.",
          ),
        );
      }
      return const Left(
        ServerFailure(
          message: "تعذر الاتصال بالخادم، يرجى المحاولة لاحقًا.",
        ),
      );
    } on FormatException {
      return const Left(Failure("Format Exception"));
    } on DioException catch (e) {
      return await handleDioExceoptions(e);
    } catch (e) {
      return Left(Failure(e.toString()));
    }
  }

  Future<Left<Failure, dynamic>> handleDioExceoptions(DioException e) async {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const Left(
          TimeoutFailure(
            message: "انتهت مهلة الاتصال بالخادم، يرجى المحاولة مرة أخرى.",
          ),
        );

      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final data = e.response?.data;
        String? serverMessage;

        if (data is Map<String, dynamic>) {
          if (data['errors'] is Map) {
            final errors = data['errors'] as Map;
            for (final fieldErrors in errors.values) {
              if (fieldErrors is List && fieldErrors.isNotEmpty) {
                serverMessage = fieldErrors.first.toString();
                break;
              }
            }
          }
          if (serverMessage == null &&
              data['errors'] is List &&
              (data['errors'] as List).isNotEmpty) {
            final firstError = (data['errors'] as List).first;
            if (firstError is Map<String, dynamic>) {
              final desc = firstError['description']?.toString();
              if (firstError['code'] == 'EMAIL_NOT_VERIFIED') {
                return Left(
                  EmailNotVerifiedFailure(
                    message: desc ?? 'Email is not verified',
                  ),
                );
              }
              serverMessage = desc;
            }
          }
          serverMessage ??= data['detail']?.toString() ??
              data['message']?.toString() ??
              data['title']?.toString();
        }

        if (statusCode == 401) {
          return Left(
            AuthFailure(
              message:
                  serverMessage ??
                  "انتهت صلاحية الجلسة، يرجى إعادة تسجيل الدخول.",
            ),
          );
        } else if (statusCode == 419) {
          return Left(
            AuthFailure(
              message:
                  serverMessage ?? "انتهت صلاحية الجلسة، يرجى إعادة المحاولة.",
            ),
          );
        } else if (statusCode != null && statusCode >= 500) {
          return Left(
            ServerFailure(
              message:
                  serverMessage ??
                  "حدث خطأ في الخادم ($statusCode)، يرجى المحاولة لاحقًا.",
            ),
          );
        } else {
          return Left(
            ServerFailure(
              message:
                  serverMessage ?? e.message ?? "تعذر إكمال الطلب.",
            ),
          );
        }

      case DioExceptionType.connectionError:
        final isOnline = await isInternetAvailable();
        if (!isOnline) {
          return const Left(
            NetworkFailure(
              message:
                  "لا يوجد اتصال بالإنترنت، تحقق من اتصالك وحاول مرة أخرى.",
            ),
          );
        } else {
          return const Left(
            ServerFailure(
              message: "تعذر الاتصال بالخادم، يرجى المحاولة لاحقًا.",
            ),
          );
        }

      case DioExceptionType.cancel:
        return const Left(UserCancelledFailure());

      case DioExceptionType.badCertificate:
        return const Left(
          ServerFailure(message: "خطأ في شهادة أمان الخادم."),
        );

      case DioExceptionType.unknown:
      default:
        if (e.error is SocketException) {
          final isOnline = await isInternetAvailable();
          if (!isOnline) {
            return const Left(
              NetworkFailure(
                message:
                    "لا يوجد اتصال بالإنترنت، تحقق من اتصالك وحاول مرة أخرى.",
              ),
            );
          }
          return const Left(
            ServerFailure(
              message: "تعذر الاتصال بالخادم، يرجى المحاولة لاحقًا.",
            ),
          );
        }
        return Left(Failure(e.message ?? "حدث خطأ غير متوقع."));
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
