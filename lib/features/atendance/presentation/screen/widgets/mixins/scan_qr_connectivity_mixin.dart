import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:qrattendance/features/atendance/presentation/screen/widgets/scan_qr_screen_body.dart';
import 'scan_qr_base_mixin.dart';

import 'package:qrattendance/core/network/network_service.dart';

mixin ScanQrConnectivityMixin on State<ScanQrScreenBody>, ScanQrBaseMixin {
  bool hasInternet = false;
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

  void disposeConnectivity() {
    connectivitySubscription?.cancel();
  }
}
