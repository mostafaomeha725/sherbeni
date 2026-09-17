import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:qrattendance/features/atendance/domain/entities/session_entity.dart';
import 'package:qrattendance/features/atendance/presentation/cubit/scan_qr_offline/scan_qr_ofline_cubit.dart';
import 'package:qrattendance/features/atendance/presentation/cubit/show_student_data/show_student_data_cubit.dart';
import 'package:qrattendance/features/atendance/presentation/screen/widgets/dialog_message.dart';
import 'package:qrattendance/features/atendance/presentation/screen/widgets/scanner_overlay_controls.dart';
import 'package:qrattendance/features/atendance/presentation/cubit/record_online_attendance/record_online_attendance_cubit.dart';

import 'mixins/scan_qr_base_mixin.dart';
import 'mixins/scan_qr_camera_mixin.dart';
import 'mixins/scan_qr_connectivity_mixin.dart';
import 'mixins/scan_qr_handler_mixin.dart';

class ScanQrScreenBody extends StatefulWidget {
  const ScanQrScreenBody({super.key, required this.session});
  final SessionEntity session;

  @override
  State<ScanQrScreenBody> createState() => _ScanQrScreenBodyState();
}

class _ScanQrScreenBodyState extends State<ScanQrScreenBody>
    with
        WidgetsBindingObserver,
        ScanQrBaseMixin,
        ScanQrConnectivityMixin,
        ScanQrCameraMixin,
        ScanQrHandlerMixin {
  static String? lastShownSyncError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initConnectivity();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    disposeConnectivity();
    disposeCamera();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        cameraController.stop();
        break;
      case AppLifecycleState.resumed:
        if (!isPickingImage) {
          cameraController.start();
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        MobileScanner(
          controller: cameraController,
          onDetect: (capture) {
            if (capture.barcodes.isEmpty) return;
            final code = capture.barcodes.first.rawValue ?? "";
            handleScan(code);
          },
        ),
        BlocListener<ShowStudentDataCubit, ShowStudentDataState>(
          listener: (context, state) {
            if (state is ShowStudentDataSuccess) {
              handleStudentDataSuccess(state.student);
            } else if (state is ShowStudentDataFailure) {
              showMessage(state.message, DialogType.error);
              resetScanner();
            }
          },
          child: const SizedBox.shrink(),
        ),
        BlocListener<RecordOnlineAttendanceCubit, RecordOnlineAttendanceState>(
          listener: (context, state) {
            if (state is RecordOnlineAttendanceSuccess) {
              handleRecordOnlineSuccess();
            } else if (state is RecordOnlineAttendanceFailure) {
              handleRecordOnlineFailure(state.message);
            }
          },
          child: const SizedBox.shrink(),
        ),
        BlocListener<ScanQrOflineCubit, ScanQrOflineState>(
          listener: (context, state) {
            if (state is ScanQrOflineSuccess) {
              _ScanQrScreenBodyState.lastShownSyncError = null;
              if (!state.isSync &&
                  state.message != "لا توجد بيانات مخزنة للمزامنة" &&
                  state.message != "لا توجد بيانات فريدة للمزامنة") {
                showMessage(state.message, DialogType.success);
              }
            } else if (state is ScanQrOflineFailure) {
              if (_ScanQrScreenBodyState.lastShownSyncError !=
                  state.errorMessage) {
                _ScanQrScreenBodyState.lastShownSyncError = state.errorMessage;
                showMessage(state.errorMessage, DialogType.error);
              }
            } else if (state is ScanQrOflineDuplicate) {
              showMessage(state.message, DialogType.warning);
            }
          },
          child: const SizedBox.shrink(),
        ),
        if (statusMessage != null)
          Positioned(
            top: 60,
            left: 16,
            right: 16,
            child: Dialogmessage(
              type: messageType ?? DialogType.success,
              title: messageType == DialogType.success
                  ? "تم بنجاح"
                  : messageType == DialogType.error
                  ? "خطأ"
                  : "مسجل مسبقاً",
              subtitle: statusMessage!,
            ),
          ),
        ScannerOverlayControls(
          flashOn: flashOn,
          onToggleFlash: toggleFlash,
          onPickImage: pickImageFromGallery,
          onRestartScanner: () => cameraController.start(),
        ),
      ],
    );
  }
}
