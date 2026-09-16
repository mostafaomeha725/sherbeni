import 'package:equatable/equatable.dart';

class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure({required String message}) : super(message);

  @override
  List<Object> get props => [message];
}

class EmailNotVerifiedFailure extends Failure {
  const EmailNotVerifiedFailure({required String message}) : super(message);

  @override
  List<Object> get props => [message];
}

class CacheFailure extends Failure {
  const CacheFailure({required String message}) : super(message);

  @override
  List<Object> get props => [message];
}

class UserCancelledFailure extends Failure {
  const UserCancelledFailure() : super('');

  @override
  List<Object> get props => [];
}

// String mapFailureToMessage(Failure failure) {
//   switch (failure.runtimeType) {
//     case ServerFailure:
//       return AppStrings.serverError.tr();
//     default:
//       return AppStrings.error.tr();
//   }
// }
