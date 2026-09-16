import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qrattendance/core/cache/preferences_storage.dart';
import 'package:qrattendance/core/di/services_locator.dart';
import 'package:qrattendance/features/atendance/presentation/cubit/scan_qr_offline/scan_qr_ofline_cubit.dart';
import 'package:qrattendance/features/atendance/presentation/screen/attendance_screen.dart';
import 'package:qrattendance/features/auth/presentation/screen/login_screen.dart';

class AuthRedirect extends StatelessWidget {
  const AuthRedirect({super.key});

  @override
  Widget build(BuildContext context) {
    // Listen to connectivity changes globally
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) async {
      final hasInternet =
          results.contains(ConnectivityResult.wifi) ||
          results.contains(ConnectivityResult.mobile);
      if (hasInternet) {
        debugPrint("📶 الإنترنت عاد، محاولة رفع البيانات المخزنة...");
        if (context.mounted) {
          context.read<ScanQrOflineCubit>().syncOfflineData();
        }
      }
    });

    final token = sl<PreferencesStorage>().getUserToken();
    if (token != null && token.isNotEmpty) {
      return AttendanceScreen(token: token);
    } else {
      return const LoginScreen();
    }
  }
}
