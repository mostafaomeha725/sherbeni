part of 'login_cubit.dart';

@immutable
sealed class LoginState {}

final class LoginInitial extends LoginState {}

final class LoginLoading extends LoginState {}

final class LoginSuccess extends LoginState {
  final UserEntity user;
  final String token;

  LoginSuccess({required this.user, required this.token});
}

final class LoginFailure extends LoginState {
  final String message;

  LoginFailure(this.message);
}
