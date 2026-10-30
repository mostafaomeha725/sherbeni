import 'package:dartz/dartz.dart';
import 'package:qrattendance/core/error/failure.dart';
import '../repositories/auth_repository.dart';

class LogoutUseCase {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  Future<Either<Failure, void>> call() => repository.logout();
}
