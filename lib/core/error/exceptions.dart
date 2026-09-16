import 'package:equatable/equatable.dart';

class ServerException extends Equatable implements Exception {
  final String message;

  const ServerException(this.message);

  @override
  String toString() {
    return message;
  }

  @override
  List<Object?> get props => [message];
}

class FetchDataException extends ServerException {
  const FetchDataException(super.message);
}

class EmailNotVerifiedException extends ServerException {
  const EmailNotVerifiedException(super.message);
}

class BadRequestException extends ServerException {
  const BadRequestException(super.message);
}

class UnauthorizedException extends ServerException {
  const UnauthorizedException(super.message);
}

class NotFoundException extends ServerException {
  const NotFoundException(super.message);
}

class UserCancelledException implements Exception {
  const UserCancelledException();
}

class ConflictException extends ServerException {
  const ConflictException(super.message);
}

class InternalServerErrorException extends ServerException {
  const InternalServerErrorException(super.message);
}

class NoInternetConnectionException extends ServerException {
  const NoInternetConnectionException(super.message);
}

class CacheException implements Exception {}
