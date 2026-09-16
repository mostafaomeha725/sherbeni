import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qrattendance/features/atendance/presentation/screen/widgets/scan_qr_screen_body.dart';
import 'scan_qr_base_mixin.dart';

mixin ScanQrCameraMixin on State<ScanQrScreenBody>, ScanQrBaseMixin {
  final MobileScannerController _cameraController = MobileScannerController();
  final ImagePicker _picker = ImagePicker();

  bool flashOn = false;
  bool isPickingImage = false;

  @override
  MobileScannerController get cameraController => _cameraController;

  void toggleFlash() {
    flashOn = !flashOn;
    _cameraController.toggleTorch();
    setState(() {});
  }

  Future<void> pickImageFromGallery() async {
    if (isPickingImage) return;
    isPickingImage = true;

    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final result = await _cameraController.analyzeImage(image.path);
        if (result != null && result.barcodes.isNotEmpty) {
          final code = result.barcodes.first.rawValue ?? '';
          await _cameraController.stop();
          handleScan(code);
        } else {
          showMessage("No QR code found in the image", DialogType.error);
        }
      }
    } catch (e) {
      showMessage("Failed to pick image", DialogType.error);
    } finally {
      isPickingImage = false;
      await _cameraController.start();
    }
  }

  void disposeCamera() {
    _cameraController.dispose();
  }
}
