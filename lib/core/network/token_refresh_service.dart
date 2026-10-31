import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:qrattendance/core/cache/preferences_storage.dart';
import 'package:qrattendance/core/constants/strings.dart';
import 'package:qrattendance/core/network/endpoints.dart';

/// Handles token refresh logic using a dedicated Dio instance
/// that has NO interceptors — preventing any infinite retry loops.
class TokenRefreshService {
  final PreferencesStorage _prefs;

  /// A clean Dio instance used exclusively for the refresh call.
  /// It intentionally has no [AuthorizationInterceptor] attached.
  late final Dio _refreshDio;

  TokenRefreshService(this._prefs, {Dio? dio}) {
    _refreshDio =
        dio ??
        Dio(
          BaseOptions(
            baseUrl: AppStrings.baseUrl,
            responseType: ResponseType.json,
            connectTimeout: const Duration(seconds: 30),
            receiveTimeout: const Duration(seconds: 30),
            headers: {'Accept': 'application/json'},
          ),
        );
  }

  /// Attempts to refresh the access token using the stored refresh token.
  ///
  /// Returns the new [accessToken] on success, or `null` on failure.
  /// Also persists the new access token and refresh token to [PreferencesStorage].
  Future<String?> refreshAccessToken() async {
    final storedRefreshToken = _prefs.getRefreshToken();

    if (storedRefreshToken == null || storedRefreshToken.isEmpty) {
      log(
        'No refresh token stored — cannot refresh.',
        name: 'TokenRefreshService',
      );
      return null;
    }

    try {
      final response = await _refreshDio.post(
        EndPoints.refreshToken,
        data: {'refreshToken': storedRefreshToken},
        options: Options(extra: {'auth_refresh_request': true}),
      );

      final responseData = response.data;
      if (responseData == null) return null;

      final Map<String, dynamic>? data = responseData is Map<String, dynamic>
          ? (responseData['data'] is Map<String, dynamic>
              ? responseData['data'] as Map<String, dynamic>
              : responseData)
          : null;
      if (data == null) return null;

      // Refresh response uses 'access_token' (with camelCase and token fallbacks)
      final newAccessToken = data['access_token']?.toString() ??
          data['accessToken']?.toString() ??
          data['token']?.toString();
      final newRefreshToken = data['refresh_token']?.toString() ??
          data['refreshToken']?.toString();

      if (newAccessToken == null || newAccessToken.isEmpty) {
        log(
          'Refresh response missing access_token field.',
          name: 'TokenRefreshService',
        );
        return null;
      }

      // Persist new tokens
      await _prefs.saveUserToken(newAccessToken);
      if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
        await _prefs.saveRefreshToken(newRefreshToken);
      }

      log(
        'Token refreshed successfully; status=${response.statusCode}; '
        'refreshTokenRotated=${newRefreshToken != null && newRefreshToken.isNotEmpty}.',
        name: 'TokenRefreshService',
      );
      return newAccessToken;
    } on DioException catch (e, st) {
      log(
        'Token refresh request failed; status=${e.response?.statusCode}; '
        'type=${e.type}.',
        name: 'TokenRefreshService',
      );
      Error.throwWithStackTrace(e, st);
    } catch (e, st) {
      log(
        'Unexpected token refresh error; type=${e.runtimeType}.',
        name: 'TokenRefreshService',
      );
      Error.throwWithStackTrace(e, st);
    }
  }
}
