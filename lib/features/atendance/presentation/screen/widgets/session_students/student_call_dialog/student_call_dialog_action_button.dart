import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qrattendance/core/widgets/custom_button.dart';

class StudentCallDialogActionButton extends StatelessWidget {
  const StudentCallDialogActionButton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppButton(
      text: 'إغلاق',
      color: const Color(0xFFF1F5F9),
      textColor: const Color(0xFF475569),
      borderColor: const Color(0xFFE2E8F0),
      radius: 14.r,
      height: 44.h,
      textWeight: FontWeight.w600,
      textSize: 14.sp,
      onPressed: () => Navigator.of(context).pop(),
    );
  }
}
