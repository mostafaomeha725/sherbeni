import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qrattendance/features/atendance/domain/entities/session_entity.dart';
import 'package:qrattendance/features/atendance/domain/repositories/attendance_repository.dart';

part 'show_classes_state.dart';

class ShowClassesCubit extends Cubit<ShowClassesState> {
  final AttendanceRepository attendanceRepository;

  ShowClassesCubit(this.attendanceRepository) : super(ShowClassesInitial());

  Future<void> fetchClasses(String subjectId, String classId) async {
    // 1. Check local cache first
    bool hasCache = false;
    final cacheResult = await attendanceRepository.getCachedClasses(
      subjectId: subjectId,
      classId: classId,
    );
    cacheResult.fold(
      (failure) {
        // No valid cache (e.g. NO_CACHE_EXISTS)
      },
      (classes) {
        if (isClosed) return;
        // Cache exists! It might be empty, but that's a valid state
        hasCache = true;
        emit(ShowClassesSuccess(classes));
      },
    );

    // 2. If no cache, emit Loading to show EasyLoading overlay
    if (!hasCache) {
      emit(ShowClassesLoading());
    }

    // 3. Fetch remote (silently if cache exists)
    final result = await attendanceRepository.fetchClasses(
      subjectId: subjectId,
      classId: classId,
    );

    result.fold(
      (failure) {
        if (isClosed) return;
        if (!hasCache) {
          if (failure.message == 'OFFLINE_FALLBACK') {
            emit(ShowClassesOfflineFallback());
          } else {
            emit(ShowClassesFailure(failure.message));
          }
        }
      },
      (classes) {
        if (isClosed) return;
        emit(ShowClassesSuccess(classes));
      },
    );
  }
}
