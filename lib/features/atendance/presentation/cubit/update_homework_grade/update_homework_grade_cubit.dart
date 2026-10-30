import 'package:bloc/bloc.dart';
import 'package:qrattendance/features/atendance/domain/use_cases/update_homework_grade_use_case.dart';

abstract class UpdateHomeworkGradeState {}

class UpdateHomeworkGradeInitial extends UpdateHomeworkGradeState {}

class UpdateHomeworkGradeLoading extends UpdateHomeworkGradeState {}

class UpdateHomeworkGradeSuccess extends UpdateHomeworkGradeState {
  final String message;
  final bool isOffline;
  UpdateHomeworkGradeSuccess(this.message, {this.isOffline = false});
}

class UpdateHomeworkGradeFailure extends UpdateHomeworkGradeState {
  final String message;
  UpdateHomeworkGradeFailure(this.message);
}

class UpdateHomeworkGradeCubit extends Cubit<UpdateHomeworkGradeState> {
  final UpdateHomeworkGradeUseCase useCase;

  UpdateHomeworkGradeCubit(this.useCase) : super(UpdateHomeworkGradeInitial());

  Future<void> submitGrade({
    required String sessionId,
    String? sessionName,
    required String studentId,
    required num grade,
  }) async {
    emit(UpdateHomeworkGradeLoading());
    final result = await useCase.call(sessionId, sessionName, studentId, grade);
    result.fold(
      (failure) => emit(UpdateHomeworkGradeFailure(failure.message)),
      (data) {
        final message = data['message']?.toString() ?? 'تم الحفظ بنجاح';
        final isOffline = message.contains('(Offline)');
        emit(UpdateHomeworkGradeSuccess(message, isOffline: isOffline));
      },
    );
  }
}
