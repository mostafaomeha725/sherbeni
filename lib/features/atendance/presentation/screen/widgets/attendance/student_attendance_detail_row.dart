import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qrattendance/core/theme/styles.dart';
import 'package:qrattendance/core/widgets/custom_text.dart';

class StudentAttendanceDetailRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? iconColor;
  final Widget? trailing;

  const StudentAttendanceDetailRow({
    super.key,
    required this.icon,
    required this.text,
    this.iconColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
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
          child: AppText(
            text,
            style: font12w500.copyWith(color: const Color(0xFF475569)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        ?trailing,
      ],
    );
  }
}
