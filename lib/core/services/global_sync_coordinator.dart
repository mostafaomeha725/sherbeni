import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:qrattendance/core/network/network_service.dart';
import 'package:qrattendance/features/atendance/data/data_sources/attendance_local_data_source.dart';
import 'package:qrattendance/features/atendance/domain/use_cases/sync_offline_data_use_case.dart';

import 'global_sync_backoff_timer.dart';
import 'global_sync_watcher.dart';

class GlobalSyncCoordinator {
  final SyncOfflineDataUseCase syncOfflineDataUseCase;
  final AttendanceLocalDataSource localDataSource;
  final Connectivity connectivity;

  bool _isSyncing = false;
  bool _isChecking = false;

  late final GlobalSyncWatcher _watcher;
  final GlobalSyncBackoffTimer _backoffTimer = GlobalSyncBackoffTimer();

  GlobalSyncCoordinator({
    required this.syncOfflineDataUseCase,
    required this.localDataSource,
    required this.connectivity,
  }) {
    _watcher = GlobalSyncWatcher(
      connectivity: connectivity,
      onTriggerSync: () => _triggerCheck(resetBackoff: true),
    );
  }

  void init() {
    _watcher.startWatching();
    // Attempt sync immediately on startup
    _triggerCheck(resetBackoff: true);
  }

  Future<void> _triggerCheck({bool resetBackoff = false}) async {
    if (resetBackoff) {
      _backoffTimer.reset();
    }

    // Single-flight lock
    if (_isSyncing || _isChecking) return;

    // Stop any scheduled retry
    _backoffTimer.cancel();

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
        print('OFFLINE_SEARCH_SYNC_TRIGGERED');
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
          final hasPending = await _hasPendingData();
          if (hasPending) {
            _scheduleRetry();
          } else {
            // All valid pending data synced successfully
            _backoffTimer.reset();
            _backoffTimer.cancel();
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
    _backoffTimer.scheduleRetry(() {
      _triggerCheck(resetBackoff: false);
    });
  }

  Future<bool> _hasPendingData() async {
    try {
      final attendances = await localDataSource.getOfflineAttendances();
      final pendingGrades = await localDataSource.getPendingQuizGrades();
      final pendingHomework = await localDataSource.getPendingHomeworkGrades();
      final pendingSearches = await localDataSource.getPendingSearches();

      if (attendances.isNotEmpty) return true;
      if (pendingSearches.isNotEmpty) return true;

      // For grades, check if any is NOT permanently failed
      for (final grade in pendingGrades) {
        if (grade.error == null) return true;
      }

      for (final hw in pendingHomework) {
        if (hw.error == null) return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  void dispose() {
    _watcher.dispose();
    _backoffTimer.cancel();
  }
}
