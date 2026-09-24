import 'package:flutter/material.dart';
import 'package:qrattendance/core/cache/preferences_storage.dart';
import 'package:qrattendance/core/di/services_locator.dart';
import 'package:qrattendance/features/atendance/presentation/screen/academic_classes_screen.dart';
import 'package:qrattendance/features/auth/presentation/screen/login_screen.dart';

class AuthRedirect extends StatelessWidget {
  const AuthRedirect({super.key});

  @override
  Widget build(BuildContext context) {
    final token = sl<PreferencesStorage>().getUserToken();
    if (token != null && token.isNotEmpty) {
      return AcademicClassesScreen(token: token);
    } else {
      return const LoginScreen();
    }
  }
}
