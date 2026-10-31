import 'package:dartz/dartz.dart';
import 'package:qrattendance/core/error/failure.dart';
import 'package:qrattendance/core/cache/preferences_storage.dart';
import 'package:qrattendance/core/di/services_locator.dart';
import 'package:qrattendance/core/network/network_service.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../data_sources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final Future<bool> Function()? checkInternet;

  AuthRepositoryImpl(this.remoteDataSource, {this.checkInternet});

  @override
  Future<Either<Failure, void>> logout() async {
    final preferencesStorage = sl<PreferencesStorage>();
    final networkService = sl<NetworkService>();
    final accessToken = preferencesStorage.getUserToken();

    if (accessToken == null || accessToken.trim().isEmpty) {
      return _clearLocalAuth(preferencesStorage, networkService);
    }

    final isOnline = checkInternet != null
        ? await checkInternet!()
        : await NetworkService.isInternetAvailable();

    if (!isOnline) {
      return const Left(
        NetworkFailure(
          message: 'لا يوجد اتصال بالإنترنت، تحقق من اتصالك وحاول مرة أخرى.',
        ),
      );
    }

    try {
      await remoteDataSource.logout();
    } catch (e) {
      if (e is Failure) {
        return Left(e);
      }
      return const Left(
        ServerFailure(
          message:
              'تعذر تأكيد تسجيل الخروج من الخادم. لم يتم إنهاء الجلسة محليًا.',
        ),
      );
    }

    return _clearLocalAuth(preferencesStorage, networkService);
  }

  Future<Either<Failure, void>> _clearLocalAuth(
    PreferencesStorage preferencesStorage,
    NetworkService networkService,
  ) async {
    try {
      await preferencesStorage.clearAuthData();
    } catch (_) {
      networkService.removeToken();
      return const Left(
        CacheFailure(
          message:
              'تم تأكيد الخروج من الخادم، لكن تعذر تنظيف بيانات الجلسة محليًا.',
        ),
      );
    }
    networkService.removeToken();
    return const Right(null);
  }

  @override
  Future<Either<Failure, UserEntity>> login({
    required String username,
    required String password,
    required String deviceId,
  }) async {
    try {
      final userModel = await remoteDataSource.login(
        username: username,
        password: password,
        deviceId: deviceId,
      );

      final prefs = sl<PreferencesStorage>();

      // Persist access token
      await prefs.saveUserToken(userModel.token);

      // Persist refresh token (new field from API)
      if (userModel.refreshToken != null &&
          userModel.refreshToken!.isNotEmpty) {
        await prefs.saveRefreshToken(userModel.refreshToken!);
      }

      return Right(userModel.toEntity());
    } catch (e) {
      if (e is Failure) {
        return Left(e);
      }
      return Left(
        ServerFailure(message: 'حدث خطأ غير متوقع أثناء تسجيل الدخول: $e'),
      );
    }
  }
}
