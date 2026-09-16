import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qrattendance/features/atendance/domain/entities/session_entity.dart';
import 'package:qrattendance/features/atendance/domain/repositories/attendance_repository.dart';

part 'show_classes_state.dart';

class ShowClassesCubit extends Cubit<ShowClassesState> {
  final AttendanceRepository attendanceRepository;

  ShowClassesCubit(this.attendanceRepository) : super(ShowClassesInitial());

  Future<void> fetchClasses(String subjectId) async {
    // 1. Check local cache first
    bool hasCache = false;
    final cacheResult = await attendanceRepository.getCachedClasses(subjectId: subjectId);
    cacheResult.fold(
      (_) {},
      (classes) {
        if (classes.isNotEmpty) {
          hasCache = true;
          emit(ShowClassesSuccess(classes));
        }
      },
    );

    // 2. If no cache, emit Loading to show EasyLoading overlay
    if (!hasCache) {
      emit(ShowClassesLoading());
    }

    // 3. Fetch remote (silently if cache exists)
    final result = await attendanceRepository.fetchClasses(subjectId: subjectId);

    result.fold(
      (failure) {
        if (!hasCache) {
          emit(ShowClassesFailure(failure.message));
        }
      },
      (classes) => emit(ShowClassesSuccess(classes)),
    );
  }
}
