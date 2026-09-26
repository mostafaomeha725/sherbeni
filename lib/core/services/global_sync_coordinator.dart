import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/widgets.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:qrattendance/core/network/network_service.dart';
import 'package:qrattendance/features/atendance/data/data_sources/attendance_local_data_source.dart';
import 'package:qrattendance/features/atendance/data/model/attendance_model.dart';
import 'package:qrattendance/features/atendance/data/model/pending_quiz_grade_model.dart';
import 'package:qrattendance/features/atendance/domain/use_cases/sync_offline_data_use_case.dart';

class GlobalSyncCoordinator with WidgetsBindingObserver {
  final SyncOfflineDataUseCase syncOfflineDataUseCase;
  final AttendanceLocalDataSource localDataSource;
  final Connectivity connectivity;

  bool _isSyncing = false;
  bool _isChecking = false;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  StreamSubscription<BoxEvent>? _hiveAttendanceSubscription;
  StreamSubscription<BoxEvent>? _hiveGradesSubscription;

  Timer? _retryTimer;
  int _currentBackoffSeconds = 5;
  static const int _maxBackoffSeconds = 60;

  GlobalSyncCoordinator({
    required this.syncOfflineDataUseCase,
    required this.localDataSource,
    required this.connectivity,
  });

  void init() {
    WidgetsBinding.instance.addObserver(this);

    // Listen to global connectivity changes
    _connectivitySubscription = connectivity.onConnectivityChanged.listen((
      result,
    ) {
      final isConnected =
          result.contains(ConnectivityResult.wifi) ||
          result.contains(ConnectivityResult.mobile);
      if (isConnected) _triggerCheck(resetBackoff: true);
    });

    // Listen to Hive box changes (new offline scans)
    if (Hive.isBoxOpen('studentSessions')) {
      _hiveAttendanceSubscription = Hive.box<AttendanceModel>('studentSessions')
          .watch()
          .listen((_) {
            _triggerCheck(resetBackoff: true);
          });
    }

    if (Hive.isBoxOpen('pendingQuizGrades')) {
      _hiveGradesSubscription =
          Hive.box<PendingQuizGradeModel>('pendingQuizGrades').watch().listen((
            _,
          ) {
            _triggerCheck(resetBackoff: true);
          });
    }

    // Attempt sync immediately on startup
    _triggerCheck(resetBackoff: true);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _triggerCheck(resetBackoff: true);
    }
  }

  Future<void> _triggerCheck({bool resetBackoff = false}) async {
    if (resetBackoff) {
      _currentBackoffSeconds = 5;
    }

    // Single-flight lock
    if (_isSyncing || _isChecking) return;

    // Stop any scheduled retry
    _retryTimer?.cancel();

    try {
      _isChecking = true;

      final hasPending = await _hasPendingData();
      if (!hasPending) {
        _isChecking = false;
        return; // No pending data, do nothing, no retries
      }

      final hasActualInternet = await NetworkService.hasInternetReachability();
      _isChecking = false;

      if (hasActualInternet) {
        await _executeSync();
      } else {
        // Wi-Fi connected but NO actual Internet (or disconnected).
        // Pending data exists, so we schedule a backoff retry.
        _scheduleRetry();
      }
    } catch (e) {
      _isChecking = false;
      _scheduleRetry();
    }
  }

  Future<void> _executeSync() async {
    if (_isSyncing) return;
    try {
      _isSyncing = true;

      final result = await syncOfflineDataUseCase.call();

      result.fold(
        (failure) {
          // Sync failed (e.g. backend error or network drop)
          // Keep pending records and retry according to backoff
          _scheduleRetry();
        },
        (successData) async {
          // Sync successful.
          // Verify if any pending data still remains (e.g. permanently failed ones)
          // Wait, permanently failed ones have error != null, so _hasPendingData() will ignore them.
          final hasPending = await _hasPendingData();
          if (hasPending) {
            _scheduleRetry();
          } else {
            // All valid pending data synced successfully
            _currentBackoffSeconds = 5;
            _retryTimer?.cancel();
          }
        },
      );
    } catch (e) {
      _scheduleRetry();
    } finally {
      _isSyncing = false;
    }
  }

  void _scheduleRetry() {
    _retryTimer?.cancel();
    _retryTimer = Timer(Duration(seconds: _currentBackoffSeconds), () {
      _triggerCheck(resetBackoff: false);
    });

    // Exponential backoff
    _currentBackoffSeconds *= 2;
    if (_currentBackoffSeconds > _maxBackoffSeconds) {
      _currentBackoffSeconds = _maxBackoffSeconds;
    }
  }

  Future<bool> _hasPendingData() async {
    try {
      final attendances = await localDataSource.getOfflineAttendances();
      final pendingGrades = await localDataSource.getPendingQuizGrades();

      if (attendances.isNotEmpty) return true;

      // For grades, check if any is NOT permanently failed
      for (final grade in pendingGrades) {
        if (grade.error == null) return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _connectivitySubscription?.cancel();
    _hiveAttendanceSubscription?.cancel();
    _hiveGradesSubscription?.cancel();
    _retryTimer?.cancel();
  }
}
