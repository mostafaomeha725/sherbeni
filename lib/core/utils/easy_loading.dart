import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

/// ===============================
/// CONFIGURATION
/// ===============================
void configureEasyLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(seconds: 2)
    ..indicatorType = EasyLoadingIndicatorType.circle
    ..loadingStyle = EasyLoadingStyle.custom
    ..indicatorSize = 40
    ..radius = 14
    ..progressColor = Colors.white
    ..backgroundColor = Colors.black.withOpacity(0.85)
    ..indicatorColor = Colors.white
    ..textColor = Colors.white
    ..maskColor = Colors.black.withOpacity(0.4)
    ..userInteractions = false
    ..dismissOnTap = true
    ..boxShadow = [];
}

/// ===============================
/// LOADING
/// ===============================
void showLoading({String? status}) {
  EasyLoading.show(
    status: status ?? "Loading...",
    maskType: EasyLoadingMaskType.black,
  );
}

void hideLoading() {
  if (EasyLoading.isShow) {
    EasyLoading.dismiss(animation: true);
  }
}

/// ===============================
/// ERROR
/// ===============================
void showError(String message) {
  hideLoading();

  EasyLoading.showError(
    message,
    duration: const Duration(seconds: 2),
    dismissOnTap: true,
    maskType: EasyLoadingMaskType.black,
  );
}

/// ===============================
/// SUCCESS
/// ===============================
void showSuccess(String message) {
  hideLoading();

  EasyLoading.showSuccess(
    message,
    duration: const Duration(seconds: 2),
    dismissOnTap: true,
    maskType: EasyLoadingMaskType.black,
  );
}

/// ===============================
/// INFO
/// ===============================
void showInfo(String message) {
  hideLoading();

  EasyLoading.showInfo(
    message,
    duration: const Duration(seconds: 2),
    dismissOnTap: true,
    maskType: EasyLoadingMaskType.black,
  );
}
