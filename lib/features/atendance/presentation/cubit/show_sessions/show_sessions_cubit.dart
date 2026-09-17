import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:qrattendance/features/atendance/domain/entities/session_entity.dart';
import 'package:qrattendance/features/atendance/domain/use_cases/get_sessions_use_case.dart';

part 'show_sessions_state.dart';

class ShowSessionsCubit extends Cubit<ShowSessionsState> {
  final GetSessionsUseCase getSessionsUseCase;

  ShowSessionsCubit(this.getSessionsUseCase) : super(ShowSessionsInitial());

  Future<void> fetchSessions(String token) async {
    // 1. Check local cache first
    bool hasCache = false;
    final cacheResult = await getSessionsUseCase.getCached();
    cacheResult.fold((_) {}, (sessions) {
      if (sessions.isNotEmpty) {
        hasCache = true;
        emit(ShowSessionsSuccess(sessions));
      }
    });

    // 2. If no cache, emit Loading to show EasyLoading overlay
    if (!hasCache) {
      emit(ShowSessionsLoading());
    }

    // 3. Fetch remote (silently if cache exists)
    final result = await getSessionsUseCase.call(token: token);

    result.fold((failure) {
      // Only show failure if we don't already have cached data on screen
      if (!hasCache) {
        if (failure.message == 'OFFLINE_FALLBACK') {
          emit(ShowSessionsOfflineFallback());
        } else {
          emit(ShowSessionsFailure(failure.message));
        }
      }
    }, (sessions) => emit(ShowSessionsSuccess(sessions)));
  }
}
