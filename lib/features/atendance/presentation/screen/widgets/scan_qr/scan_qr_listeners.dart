import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qrattendance/features/atendance/presentation/cubit/record_online_attendance/record_online_attendance_cubit.dart';
import 'package:qrattendance/features/atendance/presentation/cubit/scan_qr_offline/scan_qr_ofline_cubit.dart';
import 'package:qrattendance/features/atendance/presentation/cubit/show_student_data/show_student_data_cubit.dart';
import 'package:qrattendance/features/atendance/presentation/screen/widgets/dialogs/dialog_message.dart';

import 'package:qrattendance/features/atendance/domain/entities/student_entity.dart';

class ScanQrListeners extends StatelessWidget {
  final Widget child;
  final Function(StudentEntity) handleStudentDataSuccess;
  final Function(String, DialogType) showMessage;
  final VoidCallback resetScanner;
  final VoidCallback handleRecordOnlineSuccess;
  final VoidCallback handleRecordOfflineSuccess;
  final Function(String) handleRecordOnlineFailure;
  final Function(String?) setLastShownSyncError;
  final String? lastShownSyncError;

  const ScanQrListeners({
    super.key,
    required this.child,
    required this.handleStudentDataSuccess,
    required this.showMessage,
    required this.resetScanner,
    required this.handleRecordOnlineSuccess,
    required this.handleRecordOfflineSuccess,
    required this.handleRecordOnlineFailure,
    required this.setLastShownSyncError,
    required this.lastShownSyncError,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<ShowStudentDataCubit, ShowStudentDataState>(
          listener: (context, state) {
            if (state is ShowStudentDataSuccess) {
              handleStudentDataSuccess(state.student);
            } else if (state is ShowStudentDataFailure) {
              showMessage(state.message, DialogType.error);
              resetScanner();
            }
          },
        ),
        BlocListener<RecordOnlineAttendanceCubit, RecordOnlineAttendanceState>(
          listener: (context, state) {
            if (state is RecordOnlineAttendanceSuccess) {
              handleRecordOnlineSuccess();
            } else if (state is RecordOnlineAttendanceFailure) {
              handleRecordOnlineFailure(state.message);
            }
          },
        ),
        BlocListener<ScanQrOflineCubit, ScanQrOflineState>(
          listener: (context, state) {
            if (state is ScanQrOflineSuccess) {
              setLastShownSyncError(null);
              if (!state.isSync &&
                  state.message != "لا توجد بيانات مخزنة للمزامنة" &&
                  state.message != "لا توجد بيانات فريدة للمزامنة") {
                showMessage(state.message, DialogType.success);
                handleRecordOfflineSuccess();
              }
            } else if (state is ScanQrOflineFailure) {
              if (lastShownSyncError != state.errorMessage) {
                setLastShownSyncError(state.errorMessage);
                showMessage(state.errorMessage, DialogType.error);
              }
            } else if (state is ScanQrOflineDuplicate) {
              showMessage(state.message, DialogType.warning);
            }
          },
        ),
      ],
      child: child,
    );
  }
}
