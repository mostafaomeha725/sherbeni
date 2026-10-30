import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qrattendance/core/theme/styles.dart';
import 'package:qrattendance/core/widgets/custom_text.dart';

class StoredDataUtils {
  static String getValidSessionName(String? name) {
    if (name == null || name.isEmpty || name == 'بيانات غير متاحة') {
      return 'غير معروف';
    }
    return name;
  }

  static String getValidQuizName(String? name) {
    if (name == null || name.isEmpty) return 'غير معروف';
    return name;
  }

  static Widget buildStatusBadge(String status) {
    Color color;
    String text;

    switch (status) {
      case 'success':
      case 'synced': // Just in case any old data has this
        color = const Color(0xFF059669); // Emerald 600
        text = 'نجح';
        break;
      case 'failed':
        color = const Color(0xFFEF4444); // Red 500
        text = 'فشل';
        break;
      case 'pending':
      default:
        color = const Color(0xFFF59E0B); // Amber 500 (Yellow)
        text = 'قيد الانتظار';
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: AppText(text, style: font11w500.copyWith(color: color)),
    );
  }
}
