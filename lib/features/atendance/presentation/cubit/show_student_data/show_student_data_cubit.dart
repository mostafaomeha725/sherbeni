import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:qrattendance/features/atendance/domain/entities/student_entity.dart';
import 'package:qrattendance/features/atendance/domain/use_cases/get_student_data_use_case.dart';
import 'package:qrattendance/features/atendance/domain/use_cases/scan_online_attendance_use_case.dart';

part 'show_student_data_state.dart';

class ShowStudentDataCubit extends Cubit<ShowStudentDataState> {
  final GetStudentDataUseCase getStudentDataUseCase;
  final ScanOnlineAttendanceUseCase scanOnlineAttendanceUseCase;

  ShowStudentDataCubit(this.getStudentDataUseCase, this.scanOnlineAttendanceUseCase) : super(ShowStudentDataInitial());

  Future<void> fetchStudentData({
    required String uid,
    required bool isOnline,
    required String sessionId,
  }) async {
    emit(ShowStudentDataLoading());

    if (isOnline) {
      final result = await scanOnlineAttendanceUseCase.call(
        qrCode: uid,
        sessionId: sessionId,
      );
      result.fold(
        (failure) => emit(ShowStudentDataFailure(failure.message)),
        (student) => emit(ShowStudentDataSuccess(student, isOnline: true)),
      );
    } else {
      final result = await getStudentDataUseCase.call(uid: uid);
      result.fold(
        (failure) => emit(ShowStudentDataFailure(failure.message)),
        (student) => emit(ShowStudentDataSuccess(student, isOnline: false)),
      );
    }
  }
}
