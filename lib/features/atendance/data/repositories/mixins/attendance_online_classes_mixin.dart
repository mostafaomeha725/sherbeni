import 'package:dartz/dartz.dart';
import 'package:qrattendance/core/error/failure.dart';
import 'package:qrattendance/features/atendance/domain/entities/academic_class_entity.dart';
import 'package:qrattendance/features/atendance/domain/entities/session_entity.dart';
import 'package:qrattendance/features/atendance/data/repositories/mixins/attendance_offline_base_mixin.dart';

mixin AttendanceOnlineClassesMixin on AttendanceOfflineBaseMixin {
  Future<Either<Failure, List<SessionEntity>>> fetchClasses({
    required String subjectId,
    required String classId,
  }) async {
    try {
      final remoteClasses = await remoteDataSource.getClasses(
        subjectId,
        classId,
      );
      final entities = remoteClasses.map((e) => e.toEntity()).toList();
      await localDataSource.saveClasses(subjectId, classId, remoteClasses);
      return Right(entities);
    } catch (remoteError) {
      try {
        final localClasses = await localDataSource.getOfflineClasses(
          subjectId,
          classId,
        );
        if (localClasses != null) {
          return Right(localClasses.map((e) => e.toEntity()).toList());
        } else {
          final offline = await isOffline();
          if (offline) return const Left(CacheFailure(message: 'OFFLINE_FALLBACK'));
          if (remoteError is Failure) return Left(remoteError);
          return Left(
            ServerFailure(
              message: remoteError.toString().replaceAll('Exception: ', ''),
            ),
          );
        }
      } catch (e) {
        if (e is Failure) return Left(e);
        return Left(
          ServerFailure(message: e.toString().replaceAll('Exception: ', '')),
        );
      }
    }
  }

  Future<Either<Failure, List<SessionEntity>>> getCachedClasses({
    required String subjectId,
    required String classId,
  }) async {
    try {
      final localClasses = await localDataSource.getOfflineClasses(
        subjectId,
        classId,
      );
      if (localClasses == null) {
        return const Left(CacheFailure(message: 'NO_CACHE_EXISTS'));
      }
      return Right(localClasses.map((e) => e.toEntity()).toList());
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  Future<Either<Failure, List<AcademicClassEntity>>> fetchAcademicClasses({
    required String token,
  }) async {
    try {
      final remoteClasses = await remoteDataSource.getAcademicClasses(token);
      await localDataSource.saveAcademicClasses(remoteClasses);
      return Right(remoteClasses.map((e) => e.toEntity()).toList());
    } catch (remoteError) {
      try {
        final localClasses = await localDataSource.getOfflineAcademicClasses();
        if (localClasses.isNotEmpty) {
          return Right(localClasses.map((e) => e.toEntity()).toList());
        } else {
          final offline = await isOffline();
          if (offline) return const Left(CacheFailure(message: 'OFFLINE_FALLBACK'));
          if (remoteError is Failure) return Left(remoteError);
          return Left(
            ServerFailure(
              message: remoteError.toString().replaceAll('Exception: ', ''),
            ),
          );
        }
      } catch (e) {
        if (e is Failure) return Left(e);
        return Left(CacheFailure(message: e.toString()));
      }
    }
  }

  Future<Either<Failure, List<AcademicClassEntity>>>
  getCachedAcademicClasses() async {
    try {
      final localClasses = await localDataSource.getOfflineAcademicClasses();
      return Right(localClasses.map((e) => e.toEntity()).toList());
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }
}
