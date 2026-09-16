import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

extension ResponsiveSized on num {
  SizedBox get hSpace => SizedBox(height: h);
  SizedBox get wSpace => SizedBox(width: w);
}

extension ResponsiveRadiuse on num {
  BorderRadius get bRadius => BorderRadius.circular(r);
}

extension StringColor on String {
  Color toColor() {
    var hexString = this;
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}

extension StringToNumber on String? {
  int toInt() {
    return int.tryParse(this ?? '0') ?? 0;
  }

  int? toNullableInt() {
    return this == null ? null : int.tryParse(this!);
  }

  double toDouble() {
    return double.tryParse(this ?? '0.0') ?? 0.0;
  }

  num toNumber() {
    return num.tryParse(this ?? '0') ?? 0;
  }
}

extension ColorToMaterialStateProperty on Color {
  WidgetStateProperty<Color> toMaterialStateColor() =>
      WidgetStateColor.resolveWith((states) => this);
}

extension TimeConverter on int {
  //convert seconds
  String get formatDuration {
    final duration = Duration(seconds: this);
    final minutes = duration.inMinutes;
    final seconds = this % 60;

    final minutesString = '$minutes'.padLeft(2, '0');
    final secondsString = '$seconds'.padLeft(2, '0');
    return '$minutesString:$secondsString';
  }
}

extension BorderRadiusAnyWidget on Widget {
  ClipRRect borderRadius(int borderRadius, [Clip clip = Clip.antiAlias]) =>
      ClipRRect(
        clipBehavior: clip,
        borderRadius: borderRadius.bRadius,
        child: this,
      );
}
