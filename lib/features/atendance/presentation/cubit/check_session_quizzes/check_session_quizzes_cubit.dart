import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qrattendance/features/atendance/domain/entities/session_entity.dart';
import 'package:qrattendance/features/atendance/domain/use_cases/check_session_quizzes_use_case.dart';

part 'check_session_quizzes_state.dart';

class CheckSessionQuizzesCubit extends Cubit<CheckSessionQuizzesState> {
  final CheckSessionQuizzesUseCase checkSessionQuizzesUseCase;

  CheckSessionQuizzesCubit(this.checkSessionQuizzesUseCase)
    : super(CheckSessionQuizzesInitial());

  Future<void> checkQuizzes(SessionEntity session) async {
    // 1. Check local cache first
    bool hasCache = false;
    final cacheResult = await checkSessionQuizzesUseCase.getCached(session.id);

    cacheResult.fold((_) {}, (hasQuizzes) {
      if (hasQuizzes != null) {
        hasCache = true;
        emit(CheckSessionQuizzesSuccess(hasQuizzes, session));
      }
    });

    // 2. If no cache, emit Loading to show EasyLoading overlay
    if (!hasCache) {
      emit(CheckSessionQuizzesLoading());
    }

    // 3. Fetch remote (silently if cache exists to update it for next time)
    final result = await checkSessionQuizzesUseCase(session.id);

    result.fold(
      (failure) {
        // Only show failure if we don't already have cached data
        if (!hasCache) {
          emit(CheckSessionQuizzesFailure(failure.message));
        }
      },
      (hasQuizzes) {
        // Only emit Success if we didn't already navigate using the cache
        // Emitting twice would trigger the BlocListener's navigation twice.
        if (!hasCache) {
          emit(CheckSessionQuizzesSuccess(hasQuizzes, session));
        }
      },
    );
  }
}
