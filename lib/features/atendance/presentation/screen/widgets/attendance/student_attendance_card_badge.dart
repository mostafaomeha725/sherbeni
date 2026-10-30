import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qrattendance/core/theme/styles.dart';
import 'package:qrattendance/core/widgets/custom_text.dart';

class StudentAttendanceCardBadge extends StatelessWidget {
  final bool isLate;

  const StudentAttendanceCardBadge({super.key, required this.isLate});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 10.w,
        vertical: 6.h,
      ),
      decoration: BoxDecoration(
        color: isLate ? const Color(0xFFFEF2F2) : const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: isLate ? const Color(0xFFFECACA) : const Color(0xFFBBF7D0),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isLate
                ? Icons.timer_off_outlined
                : Icons.check_circle_outline_rounded,
            size: 14.sp,
            color: isLate ? const Color(0xFFDC2626) : const Color(0xFF16A34A),
          ),
          SizedBox(width: 4.w),
          AppText(
            isLate ? 'Late' : 'On Time',
            style: font12w700.copyWith(
              color: isLate ? const Color(0xFFDC2626) : const Color(0xFF16A34A),
            ),
          ),
        ],
      ),
    );
  }
}
