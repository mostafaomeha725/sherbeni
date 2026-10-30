import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:qrattendance/features/atendance/data/model/attendance_model.dart';
import 'package:qrattendance/features/atendance/data/model/pending_quiz_grade_model.dart';
import 'package:qrattendance/features/atendance/data/model/pending_homework_grade_model.dart';

class GlobalSyncWatcher with WidgetsBindingObserver {
  final Connectivity connectivity;
  final void Function() onTriggerSync;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  StreamSubscription<BoxEvent>? _hiveAttendanceSubscription;
  StreamSubscription<BoxEvent>? _hiveGradesSubscription;
  StreamSubscription<BoxEvent>? _hiveHomeworkSubscription;

  GlobalSyncWatcher({
    required this.connectivity,
    required this.onTriggerSync,
  });

  void startWatching() {
    WidgetsBinding.instance.addObserver(this);

    // Listen to global connectivity changes
    _connectivitySubscription = connectivity.onConnectivityChanged.listen((
      result,
    ) {
      final isConnected =
          result.contains(ConnectivityResult.wifi) ||
          result.contains(ConnectivityResult.mobile);
      if (isConnected) onTriggerSync();
    });

    // Listen to Hive box changes (new offline scans)
    if (Hive.isBoxOpen('studentSessions')) {
      _hiveAttendanceSubscription = Hive.box<AttendanceModel>('studentSessions')
          .watch()
          .listen((_) => onTriggerSync());
    }

    if (Hive.isBoxOpen('pendingQuizGrades')) {
      _hiveGradesSubscription =
          Hive.box<PendingQuizGradeModel>('pendingQuizGrades')
              .watch()
              .listen((_) => onTriggerSync());
    }

    if (Hive.isBoxOpen('pendingHomeworkGrades')) {
      _hiveHomeworkSubscription =
          Hive.box<PendingHomeworkGradeModel>('pendingHomeworkGrades')
              .watch()
              .listen((_) => onTriggerSync());
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      onTriggerSync();
    }
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _connectivitySubscription?.cancel();
    _hiveAttendanceSubscription?.cancel();
    _hiveGradesSubscription?.cancel();
    _hiveHomeworkSubscription?.cancel();
  }
}
