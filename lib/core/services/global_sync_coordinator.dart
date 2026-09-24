import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:qrattendance/core/network/network_service.dart';
import 'package:qrattendance/features/atendance/domain/use_cases/sync_offline_data_use_case.dart';

class GlobalSyncCoordinator {
  final SyncOfflineDataUseCase syncOfflineDataUseCase;
  final Connectivity connectivity;
  bool _isSyncing = false;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  GlobalSyncCoordinator({
    required this.syncOfflineDataUseCase,
    required this.connectivity,
  });

  void init() {
    // Listen to global connectivity changes
    _connectivitySubscription = connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> result,
    ) async {
      final isConnected =
          result.contains(ConnectivityResult.wifi) ||
          result.contains(ConnectivityResult.mobile);

      if (isConnected) {
        await _attemptSync();
      }
    });

    // Attempt sync immediately on startup if connected
    _attemptInitialSync();
  }

  Future<void> _attemptInitialSync() async {
    final connectivityResult = await connectivity.checkConnectivity();
    final isConnected =
        connectivityResult.contains(ConnectivityResult.wifi) ||
        connectivityResult.contains(ConnectivityResult.mobile);
    if (isConnected) {
      await _attemptSync();
    }
  }

  Future<void> _attemptSync() async {
    if (_isSyncing) return;

    try {
      _isSyncing = true;
      final hasActualInternet = await NetworkService.hasInternetReachability();

      if (hasActualInternet) {
        // We do not modify the offline logic or use case. We just call it.
        // It's safe to call because the implementation of syncOfflineData
        // already fetches local data and does nothing if it's empty.
        await syncOfflineDataUseCase.call();
      }
    } catch (e) {
      debugPrint("GlobalSyncCoordinator error: $e");
    } finally {
      _isSyncing = false;
    }
  }

  void dispose() {
    _connectivitySubscription?.cancel();
  }
}
