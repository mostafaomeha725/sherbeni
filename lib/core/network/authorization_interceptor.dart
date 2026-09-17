import 'package:qrattendance/core/cache/preferences_storage.dart';
import 'package:dio/dio.dart';
import '/core/di/services_locator.dart';

import 'package:go_router/go_router.dart';
import 'package:qrattendance/core/routes/app_routes.dart';
import 'package:qrattendance/core/routes/route_paths.dart';

class AuthorizationInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final prefs = sl<PreferencesStorage>();

    final token = prefs.getUserToken();

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = "Bearer $token";
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      print("Unauthenticated → redirect to login");

      // Clear all cached data (like token)
      final prefs = sl<PreferencesStorage>();
      await prefs.clear();

      // Navigate to login screen
      if (navigatorKey.currentContext != null) {
        GoRouter.of(navigatorKey.currentContext!).go(Routes.loginScreen);
      }
    }
    handler.next(err);
  }
}
