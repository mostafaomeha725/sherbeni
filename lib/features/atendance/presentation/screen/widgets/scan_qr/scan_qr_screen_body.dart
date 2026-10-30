import 'package:flutter/material.dart';

import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:qrattendance/features/atendance/domain/entities/session_entity.dart';
import 'package:qrattendance/features/atendance/presentation/screen/widgets/dialogs/dialog_message.dart';
import 'package:qrattendance/features/atendance/presentation/screen/widgets/dialogs/manual_attendance_dialog.dart';
import 'package:qrattendance/features/atendance/presentation/screen/widgets/scan_qr/scanner_overlay_controls.dart';
import 'package:qrattendance/features/atendance/presentation/screen/widgets/scan_qr/scan_qr_listeners.dart';
import 'package:qrattendance/features/atendance/presentation/screen/widgets/scan_qr/scan_qr_manual_attendance_button.dart';

import 'package:qrattendance/features/atendance/presentation/screen/widgets/mixins/scan_qr_base_mixin.dart';
import 'package:qrattendance/features/atendance/presentation/screen/widgets/mixins/scan_qr_camera_mixin.dart';
import 'package:qrattendance/features/atendance/presentation/screen/widgets/mixins/scan_qr_connectivity_mixin.dart';
import 'package:qrattendance/features/atendance/presentation/screen/widgets/mixins/scan_qr_handler_mixin.dart';

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
  bool _showManualSection = false;

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

  void _toggleManualSection() {
    setState(() {
      _showManualSection = !_showManualSection;
    });
    if (_showManualSection) {
      cameraController.stop();
    } else {
      cameraController.start();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScanQrListeners(
      handleStudentDataSuccess: handleStudentDataSuccess,
      showMessage: showMessage,
      resetScanner: resetScanner,
      handleRecordOnlineSuccess: handleRecordOnlineSuccess,
      handleRecordOfflineSuccess: handleRecordOfflineSuccess,
      handleRecordOnlineFailure: handleRecordOnlineFailure,
      setLastShownSyncError: (val) => _ScanQrScreenBodyState.lastShownSyncError = val,
      lastShownSyncError: _ScanQrScreenBodyState.lastShownSyncError,
      child: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: (capture) {
              if (capture.barcodes.isEmpty) return;
              final code = capture.barcodes.first.rawValue ?? "";
              handleScan(code);
            },
          ),
          ScannerOverlayControls(
            flashOn: flashOn,
            onToggleFlash: toggleFlash,
            onPickImage: pickImageFromGallery,
            onRestartScanner: () => cameraController.start(),
          ),
          ScanQrManualAttendanceButton(
            onTap: _toggleManualSection,
          ),

        if (_showManualSection)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.6),
              alignment: Alignment.center,
              child: ManualAttendanceDialog(
                session: widget.session,
                hasInternet: hasInternet,
                onClose: _toggleManualSection,
              ),
            ),
          ),

        if (statusMessage != null)
          Positioned(
            top: 70,
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
      ],
      ),
    );
  }
}
