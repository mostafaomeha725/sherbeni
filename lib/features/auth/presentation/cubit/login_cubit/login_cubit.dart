import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meta/meta.dart';
import 'package:qrattendance/features/auth/domain/entities/user_entity.dart';
import 'package:qrattendance/features/auth/domain/use_cases/login_use_case.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final LoginUseCase loginUseCase;

  LoginCubit(this.loginUseCase) : super(LoginInitial());

  Future<void> signIn({
    required String username,
    required String password,
    required String deviceId,
  }) async {
    emit(LoginLoading());

    final result = await loginUseCase.call(
      username: username,
      password: password,
      deviceId: deviceId,
    );

    result.fold(
      (failure) => emit(LoginFailure(failure.message)),
      (user) => emit(LoginSuccess(user: user, token: user.token)),
    );
  }
}
