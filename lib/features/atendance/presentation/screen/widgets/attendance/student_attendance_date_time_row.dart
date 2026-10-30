import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qrattendance/core/theme/styles.dart';
import 'package:qrattendance/core/widgets/custom_text.dart';

class StudentAttendanceDateTimeRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String date;
  final String? time;
  final Color? iconColor;

  const StudentAttendanceDateTimeRow({
    super.key,
    required this.icon,
    required this.label,
    required this.date,
    this.time,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(4.r),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Icon(
            icon,
            size: 14.sp,
            color: iconColor ?? const Color(0xFF64748B),
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              AppText(
                '$label: $date',
                style: font12w500.copyWith(
                  color: const Color(0xFF64748B),
                  height: 1.2,
                ),
              ),
              if (time != null && time!.isNotEmpty) ...[
                SizedBox(height: 2.h),
                AppText(
                  time!,
                  style: font12w500.copyWith(
                    color: const Color(0xFF94A3B8),
                    height: 1.2,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
