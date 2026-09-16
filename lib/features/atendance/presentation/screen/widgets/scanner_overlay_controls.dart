import 'package:flutter/material.dart';

class ScannerOverlayControls extends StatelessWidget {
  final bool flashOn;
  final VoidCallback onToggleFlash;
  final VoidCallback onPickImage;
  final VoidCallback onRestartScanner;

  const ScannerOverlayControls({
    super.key,
    required this.flashOn,
    required this.onToggleFlash,
    required this.onPickImage,
    required this.onRestartScanner,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          bottom: 100,
          left: 30,
          child: IconButton(
            onPressed: onToggleFlash,
            icon: Icon(
              flashOn ? Icons.flash_on : Icons.flash_off,
              color: Colors.white,
            ),
          ),
        ),
        Positioned(
          bottom: 100,
          left: MediaQuery.of(context).size.width / 2 - 30,
          child: GestureDetector(
            onTap: onRestartScanner,
            child: const CircleAvatar(
              radius: 30,
              backgroundColor: Colors.white,
              child: Icon(Icons.qr_code_scanner, size: 32, color: Colors.black),
            ),
          ),
        ),
        Positioned(
          bottom: 100,
          right: 30,
          child: IconButton(
            onPressed: onPickImage,
            icon: const Icon(Icons.image, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
