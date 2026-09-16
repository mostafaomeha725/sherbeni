import 'package:flutter/material.dart';

extension BMTextTheme on BuildContext {
  /// DISPLAY
  TextStyle get displayL => Theme.of(this).textTheme.displayLarge!;
  TextStyle get displayM => Theme.of(this).textTheme.displayMedium!;
  TextStyle get displayS => Theme.of(this).textTheme.displaySmall!;

  /// HEADLINE
  TextStyle get headlineL => Theme.of(this).textTheme.headlineLarge!;
  TextStyle get headlineM => Theme.of(this).textTheme.headlineMedium!;
  TextStyle get headlineS => Theme.of(this).textTheme.headlineSmall!;

  /// TITLE
  TextStyle get titleL => Theme.of(this).textTheme.titleLarge!;
  TextStyle get titleM => Theme.of(this).textTheme.titleMedium!;
  TextStyle get titleS => Theme.of(this).textTheme.titleSmall!;

  /// BODY
  TextStyle get bodyL => Theme.of(this).textTheme.bodyLarge!;
  TextStyle get bodyM => Theme.of(this).textTheme.bodyMedium!;
  TextStyle get bodyS => Theme.of(this).textTheme.bodySmall!;

  /// LABEL
  TextStyle get labelL => Theme.of(this).textTheme.labelLarge!;
  TextStyle get labelM => Theme.of(this).textTheme.labelMedium!;
  TextStyle get labelS => Theme.of(this).textTheme.labelSmall!;
}
