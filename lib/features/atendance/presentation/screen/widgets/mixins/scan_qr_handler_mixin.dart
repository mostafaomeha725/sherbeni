import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:qrattendance/core/utils/audio_helper.dart';
import 'package:qrattendance/features/atendance/domain/entities/student_entity.dart';
import 'package:qrattendance/features/atendance/presentation/cubit/scan_qr_offline/scan_qr_ofline_cubit.dart';
import 'package:qrattendance/features/atendance/presentation/cubit/show_student_data/show_student_data_cubit.dart';
import 'package:qrattendance/features/atendance/presentation/screen/widgets/scan_qr/scan_qr_screen_body.dart';
import 'package:qrattendance/features/atendance/presentation/cubit/record_online_attendance/record_online_attendance_cubit.dart';
import 'package:qrattendance/features/atendance/presentation/screen/widgets/student_data_bottom_sheet/student_data_bottom_sheet.dart';
import 'scan_qr_queue_manager.dart';
import 'scan_qr_base_mixin.dart';
import 'scan_qr_connectivity_mixin.dart';

mixin ScanQrHandlerMixin
    on State<ScanQrScreenBody>, ScanQrBaseMixin, ScanQrConnectivityMixin {
  String? statusMessage;
  DialogType? messageType;
  Timer? _messageTimer;

  final ScanQrQueueManager _queueManager = ScanQrQueueManager();

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

    if (!hasInternet && cleanedCode.length > 36) {
      showMessage(
        "The ID exceeds the maximum allowed length of 36 characters.",
        DialogType.error,
      );
      return;
    }

    // Clean up old entries to prevent memory leaks over time
    _queueManager.cleanUpOldEntries(now, 3);

    // Prevent scanning if this exact QR is currently being processed or in queue or recent
    if (!_queueManager.canAdd(cleanedCode)) {
      return;
    }

    // Add to queue and trigger processing
    _queueManager.addToQueue(cleanedCode);
    _processNextInQueue();
  }

  void _processNextInQueue() async {
    final codeToProcess = _queueManager.getNextToProcess();
    if (codeToProcess == null) return;

    try {
      if (!mounted) return;
      await context.read<ShowStudentDataCubit>().fetchStudentData(
        uid: codeToProcess,
        isOnline: hasInternet,
        sessionId: widget.session.id.toString(),
      );
    } catch (e) {
      _queueManager.removeProcessingCode(_queueManager.currentScannedCode);
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
      // In
      //
      //y synchronous error
      showMessage(e.toString(), DialogType.error);
    }
  }

  void handleRecordOnlineSuccess() async {
    AudioHelper.playSuccess();
    if (mounted && currentStudent != null) {
      bool isSheetOpen = true;
      StudentDataBottomSheet.show(
        context,
        currentStudent!,
        session: widget.session,
      ).then((_) {
        isSheetOpen = false;
        resetScanner();
      });
    } else {
      resetScanner();
    }
  }

  void handleRecordOfflineSuccess() async {
    if (mounted && currentStudent != null && widget.session.hasHomework) {
      bool isSheetOpen = true;
      StudentDataBottomSheet.show(
        context,
        currentStudent!,
        session: widget.session,
        forceHomework: true,
        isOffline: true,
      ).then((_) {
        isSheetOpen = false;
        resetScanner();
      });
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
    _queueManager.finishProcessingCurrent();
    _processNextInQueue();
  }

  Future<void> submitAttendanceOffline(String uid, String scanTime) async {
    try {
      if (!mounted) return;
      final result = await context.read<ScanQrOflineCubit>().saveOffline(
        uid: uid,
        sessionId: widget.session.id.toString(),
        sessionName: "${widget.session.courseTitle} - ${widget.session.title}",
        scanTime: scanTime,
      );
      // Success sound and message are handled by the BlocListener in ScanQrScreenBody
      // We do NOT resetScanner() here for success because we might need to show the Homework sheet in handleRecordOfflineSuccess.
      if (result == "duplicate" ||
          result == "error" ||
          result == "invalid_uid") {
        resetScanner();
      }
    } catch (e) {
      showMessage("Failed to save data offline: $e", DialogType.error);
      resetScanner();
    }
  }
}
