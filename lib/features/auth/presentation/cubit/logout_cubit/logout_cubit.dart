import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qrattendance/features/auth/domain/use_cases/logout_use_case.dart';
import 'logout_state.dart';

class LogoutCubit extends Cubit<LogoutState> {
  final LogoutUseCase logoutUseCase;
  bool _logoutInProgress = false;
  bool _logoutCompleted = false;

  LogoutCubit(this.logoutUseCase) : super(LogoutInitial());

  Future<void> logout() async {
    if (_logoutInProgress || _logoutCompleted) return;
    _logoutInProgress = true;
    emit(LogoutLoading());

    try {
      final result = await logoutUseCase();
      result.fold((failure) => emit(LogoutFailure(failure.message)), (_) {
        _logoutCompleted = true;
        emit(LogoutSuccess());
      });
    } finally {
      _logoutInProgress = false;
    }
  }
}
