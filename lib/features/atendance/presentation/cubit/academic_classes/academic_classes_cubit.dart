import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:qrattendance/features/atendance/domain/entities/academic_class_entity.dart';
import 'package:qrattendance/features/atendance/domain/use_cases/get_academic_classes_use_case.dart';

part 'academic_classes_state.dart';

class AcademicClassesCubit extends Cubit<AcademicClassesState> {
  final GetAcademicClassesUseCase getAcademicClassesUseCase;

  AcademicClassesCubit(this.getAcademicClassesUseCase)
    : super(AcademicClassesInitial());

  Future<void> fetchAcademicClasses(String token) async {
    bool hasCache = false;
    final cacheResult = await getAcademicClassesUseCase.getCached();
    cacheResult.fold((_) {}, (classes) {
      if (classes.isNotEmpty) {
        hasCache = true;
        emit(AcademicClassesSuccess(classes));
      }
    });

    if (!hasCache) {
      emit(AcademicClassesLoading());
    }

    final result = await getAcademicClassesUseCase.call(token: token);

    result.fold((failure) {
      if (!hasCache) {
        if (failure.message == 'OFFLINE_FALLBACK') {
          emit(AcademicClassesOfflineFallback());
        } else {
          emit(AcademicClassesFailure(failure.message));
        }
      }
    }, (classes) => emit(AcademicClassesSuccess(classes)));
  }
}
