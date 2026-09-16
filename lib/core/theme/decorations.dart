import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Decorations {
  static topRoundedContainer() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.only(
      topRight: Radius.circular(20.sp),
      topLeft: Radius.circular(20.sp),
    ),
  );

  static const gradientContainer = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF048A1A), Color(0xFF02450D)],
    ),
  );
}
