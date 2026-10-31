import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';
import 'package:qrattendance/core/cache/preferences_storage.dart';
import 'package:qrattendance/core/constants/strings.dart';
import 'package:qrattendance/core/network/endpoints.dart';
import 'package:qrattendance/core/network/token_refresh_service.dart';
import 'package:qrattendance/core/routes/app_routes.dart';
import 'package:qrattendance/core/routes/route_paths.dart';

import '/core/di/services_locator.dart';
import 'package:qrattendance/core/network/network_service.dart';

/// Dio interceptor that:
///
/// 1. Attaches the Bearer token to every outgoing request.
/// 2. On HTTP **419** (token expired): silently refreshes the access token
///    using [TokenRefreshService], retries the original request once with the
///    new token, and if refresh fails — clears auth tokens and redirects to login.
/// 3. On HTTP **401** (unauthorised): clears auth tokens and redirects to login.
///
/// Concurrent 419 errors share one refresh future via [_ongoingRefresh] so we
/// never fire more than one refresh request at a time.
class AuthorizationInterceptor extends Interceptor {
  AuthorizationInterceptor({
    Dio Function()? retryDioFactory,
    Future<void> Function()? onSessionExpired,
  }) : _retryDioFactory = retryDioFactory ?? _defaultRetryDio,
       _onSessionExpired = onSessionExpired;

  static const _retryMarker = 'auth_refresh_retry';
  static const _refreshMarker = 'auth_refresh_request';
  static const _logoutMarker = 'auth_logout_request';

  final Dio Function() _retryDioFactory;
  final Future<void> Function()? _onSessionExpired;
  Future<String?>? _ongoingRefresh;
  Future<void>? _sessionCleanup;
  bool _sessionCleanupInProgress = false;

  static Dio _defaultRetryDio() => Dio(
    BaseOptions(
      baseUrl: AppStrings.baseUrl,
      responseType: ResponseType.json,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Accept': 'application/json'},
    ),
  );

  // ---------------------------------------------------------------------------
  // onRequest — attach stored access token
  // ---------------------------------------------------------------------------

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final preferencesStorage = sl<PreferencesStorage>();
    final token = preferencesStorage.getUserToken();
    if (token != null && token.isNotEmpty) {
      if (_sessionCleanup != null && !_sessionCleanupInProgress) {
        _sessionCleanup = null;
      }
      options.headers['Authorization'] = 'Bearer $token';
    } else {
      options.headers.removeWhere(
        (key, _) => key.toLowerCase() == 'authorization',
      );
    }
    handler.next(options);
  }

  // ---------------------------------------------------------------------------
  // onError — handle 419 (token expired) and 401 (unauthorised)
  // ---------------------------------------------------------------------------

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final statusCode = err.response?.statusCode;

    if (_isRefreshRequest(err.requestOptions)) {
      handler.next(err);
    } else if (statusCode == 419) {
      await _handle419(err, handler);
    } else if (statusCode == 401) {
      if (_isLogoutRequest(err.requestOptions)) {
        log(
          '401 Unauthorised on logout request — preserving local credentials.',
          name: 'AuthInterceptor',
        );
      } else {
        log('401 Unauthorised — redirecting to login.', name: 'AuthInterceptor');
        await _clearSessionAndRedirect();
      }
      handler.next(err);
    } else {
      handler.next(err);
    }
  }

  // ---------------------------------------------------------------------------
  // Internal helpers
  // ---------------------------------------------------------------------------

  Future<void> _handle419(
    DioException originalErr,
    ErrorInterceptorHandler handler,
  ) async {
    final requestOptions = originalErr.requestOptions;
    if (requestOptions.extra[_retryMarker] == true) {
      handler.next(originalErr);
      return;
    }

    final preferencesStorage = sl<PreferencesStorage>();
    final requestToken = _tokenFromRequest(requestOptions);
    final currentToken = preferencesStorage.getUserToken();
    String? newToken;

    if (currentToken != null &&
        currentToken.isNotEmpty &&
        currentToken != requestToken) {
      newToken = currentToken;
      log(
        'Access token changed before handling 419; retrying with current token.',
        name: 'AuthInterceptor',
      );
    } else {
      log(
        '419 received; status=${originalErr.response?.statusCode}; '
        'starting or joining refresh.',
        name: 'AuthInterceptor',
      );
      try {
        _ongoingRefresh ??= sl<TokenRefreshService>()
            .refreshAccessToken()
            .whenComplete(() => _ongoingRefresh = null);
        newToken = await _ongoingRefresh;
      } on DioException catch (refreshError) {
        final refreshStatus = refreshError.response?.statusCode;
        log(
          'Refresh request failed; status=$refreshStatus; '
          'type=${refreshError.type}.',
          name: 'AuthInterceptor',
        );
        if (refreshStatus == 401 || refreshStatus == 403) {
          if (_isLogoutRequest(requestOptions)) {
            log(
              'Logout refresh rejected; no local cleanup performed.',
              name: 'AuthInterceptor',
            );
          } else {
            await _clearSessionAndRedirect();
          }
          handler.next(originalErr);
        } else {
          handler.next(refreshError);
        }
        return;
      } catch (error) {
        log(
          'Refresh failed with an unclassified error; '
          'type=${error.runtimeType}. No session cleanup performed.',
          name: 'AuthInterceptor',
        );
        handler.next(
          DioException(requestOptions: requestOptions, error: error),
        );
        return;
      }
    }

    if (newToken == null || newToken.isEmpty) {
      log(
        'Refresh returned no access token; status=unknown. '
        'No session cleanup performed.',
        name: 'AuthInterceptor',
      );
      handler.next(originalErr);
      return;
    }

    if (sl.isRegistered<NetworkService>()) {
      sl<NetworkService>().addToken(newToken);
    }

    requestOptions.extra[_retryMarker] = true;
    try {
      final retryResponse = await _retryRequest(requestOptions, newToken);
      log(
        'Retry succeeded; status=${retryResponse.statusCode}; '
        'tokenChanged=${newToken != requestToken}.',
        name: 'AuthInterceptor',
      );
      handler.resolve(retryResponse);
    } on DioException catch (retryError) {
      log(
        'Retry failed; status=${retryError.response?.statusCode}; '
        'type=${retryError.type}. No logout performed.',
        name: 'AuthInterceptor',
      );
      handler.next(retryError);
    } catch (error) {
      log(
        'Retry failed with an unclassified error; '
        'type=${error.runtimeType}. No logout performed.',
        name: 'AuthInterceptor',
      );
      handler.next(DioException(requestOptions: requestOptions, error: error));
    }
  }

  /// Retries [requestOptions] with [newToken] using a clean Dio instance
  /// (no interceptors) to avoid triggering another 419 intercept cycle.
  Future<Response<dynamic>> _retryRequest(
    RequestOptions requestOptions,
    String newToken,
  ) async {
    final retryDio = _retryDioFactory();

    // Check for non-repeatable bodies: raw streams cannot be read twice
    if (requestOptions.data is Stream) {
      log(
        'Request data is an unrepeatable Stream; cannot retry safely.',
        name: 'AuthInterceptor',
      );
      throw DioException(
        requestOptions: requestOptions,
        error: 'Stream request body cannot be replayed after token refresh.',
        type: DioExceptionType.unknown,
      );
    }

    // Replay safety: FormData streams are consumed during transmission,
    // clone to create fresh streams for the retry attempt.
    if (requestOptions.data is FormData) {
      try {
        requestOptions.data = (requestOptions.data as FormData).clone();
      } catch (e) {
        log(
          'Failed to clone FormData for retry: $e',
          name: 'AuthInterceptor',
        );
        throw DioException(
          requestOptions: requestOptions,
          error: 'FormData cannot be cloned for retry: $e',
          type: DioExceptionType.unknown,
        );
      }
    }

    requestOptions.headers.removeWhere(
      (key, _) => key.toLowerCase() == 'authorization',
    );
    requestOptions.headers['Authorization'] = 'Bearer $newToken';
    return retryDio.fetch(requestOptions);
  }

  static String? _tokenFromRequest(RequestOptions options) {
    final authorization = options.headers.entries
        .where((entry) => entry.key.toLowerCase() == 'authorization')
        .map((entry) => entry.value)
        .firstOrNull;
    if (authorization == null) return null;
    final authStr = authorization.toString().trim();
    if (!authStr.toLowerCase().startsWith('bearer ')) {
      return null;
    }
    return authStr.substring(7).trim();
  }

  static bool _isRefreshRequest(RequestOptions options) {
    final path = Uri.tryParse(options.path)?.path ?? options.path;
    return options.extra[_refreshMarker] == true ||
        path.endsWith(EndPoints.refreshToken);
  }

  static bool _isLogoutRequest(RequestOptions options) {
    final path = Uri.tryParse(options.path)?.path ?? options.path;
    return options.extra[_logoutMarker] == true ||
        path.endsWith(EndPoints.mobileLogout);
  }

  Future<void> _clearSessionAndRedirect() {
    if (_sessionCleanup != null) return _sessionCleanup!;
    final preferencesStorage = sl<PreferencesStorage>();
    _sessionCleanupInProgress = true;
    _sessionCleanup = _performSessionCleanup(preferencesStorage);
    return _sessionCleanup!;
  }

  Future<void> _performSessionCleanup(
    PreferencesStorage preferencesStorage,
  ) async {
    try {
      await preferencesStorage.deleteUserToken();
      await preferencesStorage.deleteRefreshToken();
      if (sl.isRegistered<NetworkService>()) {
        sl<NetworkService>().removeToken();
      }
      final onSessionExpired = _onSessionExpired;
      if (onSessionExpired != null) {
        await onSessionExpired();
        return;
      }
      final ctx = navigatorKey.currentContext;
      if (ctx == null) return;
      // ignore: use_build_context_synchronously
      GoRouter.of(ctx).go(Routes.loginScreen);
    } finally {
      _sessionCleanupInProgress = false;
    }
  }
}
