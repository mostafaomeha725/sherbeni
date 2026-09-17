import 'package:dartz/dartz.dart';
import 'package:qrattendance/core/error/failure.dart';
import 'package:qrattendance/core/cache/preferences_storage.dart';
import 'package:qrattendance/core/di/services_locator.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../data_sources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

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

      // Save token locally
      await sl<PreferencesStorage>().saveUserToken(userModel.token);

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
