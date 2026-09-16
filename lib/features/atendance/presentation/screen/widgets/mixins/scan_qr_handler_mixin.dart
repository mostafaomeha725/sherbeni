import 'dart:async';
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:qrattendance/core/utils/audio_helper.dart';
import 'package:qrattendance/features/atendance/domain/entities/student_entity.dart';
import 'package:qrattendance/features/atendance/presentation/cubit/scan_qr_offline/scan_qr_ofline_cubit.dart';
import 'package:qrattendance/features/atendance/presentation/cubit/show_student_data/show_student_data_cubit.dart';
import 'package:qrattendance/features/atendance/presentation/screen/widgets/scan_qr_screen_body.dart';
import 'package:qrattendance/features/atendance/presentation/cubit/record_online_attendance/record_online_attendance_cubit.dart';
import 'package:qrattendance/features/atendance/presentation/screen/widgets/student_data_bottom_sheet.dart';
import 'scan_qr_base_mixin.dart';
import 'scan_qr_connectivity_mixin.dart';

mixin ScanQrHandlerMixin
    on State<ScanQrScreenBody>, ScanQrBaseMixin, ScanQrConnectivityMixin {
  String? statusMessage;
  DialogType? messageType;
  String? scannedCode;
  Timer? _messageTimer;

  final Map<String, DateTime> _scannedCodesMap = {};
  final Set<String> _processingCodes = {};
  final Queue<String> _scanQueue = Queue<String>();
  bool _isProcessingQueue = false;

  @override
  void showMessage(String message, DialogType type) {
    debugPrint("ShowMessage: message=$message, type=$type");
    setState(() {
      statusMessage = message;
      messageType = type;
    });

    switch (type) {
      case DialogType.success:
        AudioHelper.playSuccess();
        break;
      case DialogType.warning:
        AudioHelper.playDuplicate();
        break;
      case DialogType.error:
        AudioHelper.playError();
        break;
    }

    _messageTimer?.cancel();
    _messageTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          statusMessage = null;
        });
      }
    });
  }

  @override
  void handleScan(String code) async {
    final cleanedCode = code.trim();
    final now = DateTime.now();

    // Clean up old entries to prevent memory leaks over time
    _scannedCodesMap.removeWhere(
      (key, time) => now.difference(time).inSeconds >= 3,
    );

    // Prevent scanning if this exact QR is currently being processed or in queue
    if (_processingCodes.contains(cleanedCode) ||
        _scanQueue.contains(cleanedCode)) {
      return;
    }

    // Prevent scanning the exact same code if it was processed within the last 3 seconds
    if (_scannedCodesMap.containsKey(cleanedCode)) {
      return;
    }

    // Add to queue and trigger processing
    _scanQueue.add(cleanedCode);
    _processNextInQueue();
  }

  void _processNextInQueue() async {
    if (_isProcessingQueue || _scanQueue.isEmpty) return;

    _isProcessingQueue = true;
    final codeToProcess = _scanQueue.removeFirst();

    scannedCode = codeToProcess;
    _processingCodes.add(codeToProcess);

    try {
      if (!mounted) return;
      await context.read<ShowStudentDataCubit>().fetchStudentData(
        uid: codeToProcess,
        isOnline: hasInternet,
        sessionId: widget.session.id.toString(),
      );
    } catch (e) {
      if (scannedCode != null) {
        _processingCodes.remove(scannedCode);
      }
      showMessage("Error while scanning code: $e", DialogType.error);
      resetScanner();
    }
  }

  StudentEntity? currentStudent;

  Future<void> handleStudentDataSuccess(StudentEntity student) async {
    try {
      final scanTime = DateFormat(
        'yyyy-MM-dd HH:mm:ss',
        'en_US',
      ).format(DateTime.now());
      currentStudent = student;

      if (hasInternet) {
        if (!mounted) return;
        // Don't await and show sheet here. Let the BlocListener handle the result.
        context.read<RecordOnlineAttendanceCubit>().record(
          uid: student.id,
          sessionId: widget.session.id.toString(),
        );
      } else {
        await submitAttendanceOffline(student.id, scanTime);
      }
    } catch (e) {
      // In case of any synchronous error
      showMessage(e.toString(), DialogType.error);
    }
  }

  void handleRecordOnlineSuccess() async {
    AudioHelper.playSuccess();
    if (mounted && currentStudent != null) {
      bool isSheetOpen = true;

      StudentDataBottomSheet.show(context, currentStudent!).then((_) {
        isSheetOpen = false;
        resetScanner();
      });
      // Removed auto-close so the sheet stays open until "Continue" is pressed.
    } else {
      resetScanner();
    }
  }

  void handleRecordOnlineFailure(String errorMessage) async {
    AudioHelper.playError();
    showMessage(errorMessage, DialogType.error);
    resetScanner();
  }

  void resetScanner() {
    if (scannedCode != null) {
      _processingCodes.remove(scannedCode);
      _scannedCodesMap[scannedCode!] = DateTime.now();
    }

    scannedCode = null;

    _isProcessingQueue = false;
    _processNextInQueue();
  }

  Future<void> submitAttendanceOffline(String uid, String scanTime) async {
    try {
      if (!mounted) return;
      await context.read<ScanQrOflineCubit>().saveOffline(
        uid: uid,
        sessionId: widget.session.id.toString(),
        scanTime: scanTime,
      );
      // Success sound and message are handled by the BlocListener in ScanQrScreenBody
    } catch (e) {
      showMessage("Failed to save data offline: $e", DialogType.error);
    } finally {
      resetScanner();
    }
  }
}
