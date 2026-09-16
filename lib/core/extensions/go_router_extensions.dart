import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

extension GoRouterExtensions on BuildContext {
  void pushAndRemoveUntil(String route, {Object? extra}) {
    while (canPop()) {
      pop();
    }
    pushReplacement(route);
  }
}
