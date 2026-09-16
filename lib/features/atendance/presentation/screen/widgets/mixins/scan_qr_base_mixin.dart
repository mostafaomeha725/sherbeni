import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qrattendance/features/atendance/presentation/screen/widgets/scan_qr_screen_body.dart';

import 'package:qrattendance/features/atendance/presentation/screen/widgets/dialog_message.dart';
export 'package:qrattendance/features/atendance/presentation/screen/widgets/dialog_message.dart'
    show DialogType;

mixin ScanQrBaseMixin on State<ScanQrScreenBody> {
  MobileScannerController get cameraController;
  void showMessage(String message, DialogType type);
  void handleScan(String code);
}
