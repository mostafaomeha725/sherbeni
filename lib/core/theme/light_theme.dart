import 'package:flutter/material.dart';
import '/core/constants/strings.dart';
import '/core/theme/light_colors.dart';

final ColorScheme lightColorScheme = ColorScheme(
  primary: AppLightColors.primary,
  // primaryVariant: Colors.blueAccent,
  secondary: AppLightColors.secondary,
  // secondaryVariant: Colors.greenAccent,
  surface: Color(0xFFF6F6FE),
  onSurface: Colors.black,
  // surfaceContainerHighest: Colors.black,
  error: Colors.red,
  onPrimary: Colors.white,
  onSecondary: Colors.black,
  onError: Colors.red,
  brightness: Brightness.light,
  // More colors
);

final lightTheme = ThemeData(
  brightness: Brightness.light,
  visualDensity: VisualDensity.adaptivePlatformDensity,
  colorScheme: lightColorScheme,
  useMaterial3: true,
  fontFamily: AppStrings.fontFamily,
  // scaffoldBackgroundColor: Colors.white,
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    hintStyle: TextStyle(color: Color(0xFFA4ACAD)),
  ),
);
