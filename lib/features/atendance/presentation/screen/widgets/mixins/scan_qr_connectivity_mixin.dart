import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qrattendance/features/atendance/presentation/cubit/scan_qr_offline/scan_qr_ofline_cubit.dart';
import 'package:qrattendance/features/atendance/presentation/screen/widgets/scan_qr_screen_body.dart';
import 'scan_qr_base_mixin.dart';

import 'package:qrattendance/core/network/network_service.dart';

mixin ScanQrConnectivityMixin on State<ScanQrScreenBody>, ScanQrBaseMixin {
  bool hasInternet = false;
  bool isSyncing = false;
  StreamSubscription<List<ConnectivityResult>>? connectivitySubscription;

  void initConnectivity() {
    _checkConnectivity();
    _subscribeToConnectivityChanges();
  }

  Future<void> _checkConnectivity() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      bool isConnected =
          connectivityResult.contains(ConnectivityResult.wifi) ||
          connectivityResult.contains(ConnectivityResult.mobile);

      if (isConnected) {
        isConnected = await NetworkService.hasInternetReachability();
      }

      setState(() {
        hasInternet = isConnected;
      });
    } catch (e) {
      debugPrint("Error checking connectivity: $e");
    }
  }

  void _subscribeToConnectivityChanges() {
    connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> result,
    ) async {
      bool newHasInternet =
          result.contains(ConnectivityResult.wifi) ||
          result.contains(ConnectivityResult.mobile);

      if (newHasInternet) {
        newHasInternet = await NetworkService.hasInternetReachability();
      }

      if (newHasInternet != hasInternet) {
        if (mounted) {
          setState(() {
            hasInternet = newHasInternet;
          });
        }
      }
    });
  }

  Future<void> syncOfflineData() async {
    if (isSyncing) return;
    setState(() {
      isSyncing = true;
    });
    try {
      await context.read<ScanQrOflineCubit>().syncOfflineData();
    } catch (e) {
      showMessage("Failed to sync data: $e", DialogType.error);
    } finally {
      if (mounted) {
        setState(() {
          isSyncing = false;
        });
      }
    }
  }

  void disposeConnectivity() {
    connectivitySubscription?.cancel();
  }
}
