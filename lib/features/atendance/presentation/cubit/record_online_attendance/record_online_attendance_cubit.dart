import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:qrattendance/features/atendance/domain/use_cases/record_online_attendance_use_case.dart';

part 'record_online_attendance_state.dart';

class RecordOnlineAttendanceCubit extends Cubit<RecordOnlineAttendanceState> {
  final RecordOnlineAttendanceUseCase recordOnlineAttendanceUseCase;

  RecordOnlineAttendanceCubit(this.recordOnlineAttendanceUseCase)
    : super(RecordOnlineAttendanceInitial());

  Future<void> record({required String uid, required String sessionId}) async {
    emit(RecordOnlineAttendanceLoading());

    final result = await recordOnlineAttendanceUseCase.call(
      uid: uid,
      sessionId: sessionId,
    );

    result.fold(
      (failure) {
        emit(RecordOnlineAttendanceFailure(failure.message));
      },
      (success) {
        emit(RecordOnlineAttendanceSuccess());
      },
    );
  }
}
