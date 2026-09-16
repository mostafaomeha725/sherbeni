import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:qrattendance/features/atendance/domain/use_cases/save_offline_attendance_use_case.dart';
import 'package:qrattendance/features/atendance/domain/use_cases/sync_offline_data_use_case.dart';

part 'scan_qr_ofline_state.dart';

class ScanQrOflineCubit extends Cubit<ScanQrOflineState> {
  final SaveOfflineAttendanceUseCase saveOfflineAttendanceUseCase;
  final SyncOfflineDataUseCase syncOfflineDataUseCase;

  ScanQrOflineCubit(this.saveOfflineAttendanceUseCase, this.syncOfflineDataUseCase) : super(ScanQrOflineInitial());

  Future<String> saveOffline({
    required String uid,
    required String sessionId,
    String? scanTime,
  }) async {
    emit(ScanQrOflineLoading());

    final result = await saveOfflineAttendanceUseCase.call(
      uid: uid,
      sessionId: sessionId,
      scanTime: scanTime,
    );

    return result.fold(
      (failure) {
        if (failure.message.contains("مسبقًا")) {
          emit(ScanQrOflineDuplicate(message: failure.message));
          return "duplicate";
        }
        emit(ScanQrOflineFailure(failure.message));
        return failure.message.contains("غير صالح") ? "invalid_uid" : "error";
      },
      (successMsg) {
        emit(
          ScanQrOflineSuccess(
            message: "تم حفظ البيانات بنجاح في وضع عدم الاتصال",
            stats: const {},
            isSync: false,
          ),
        );
        return successMsg;
      },
    );
  }

  Future<void> syncOfflineData() async {
    emit(ScanQrOflineLoading());

    final result = await syncOfflineDataUseCase.call();

    result.fold(
      (failure) {
        emit(ScanQrOflineFailure(failure.message));
      },
      (stats) {
        if (stats.isEmpty) {
          emit(
            ScanQrOflineSuccess(
              message: "لا توجد بيانات مخزنة للمزامنة",
              stats: const {},
              isSync: true,
            ),
          );
        } else {
          emit(
            ScanQrOflineSuccess(
              message: "تمت مزامنة جميع البيانات بنجاح",
              stats: stats,
              isSync: true,
            ),
          );
        }
      },
    );
  }
}
