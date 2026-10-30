import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qrattendance/core/theme/light_colors.dart';
import 'package:qrattendance/core/theme/styles.dart';

class CollapsibleAttendanceCardTitle extends StatelessWidget {
  final String uid;
  final Widget statusBadge;

  const CollapsibleAttendanceCardTitle({
    super.key,
    required this.uid,
    required this.statusBadge,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: AppLightColors.primaryLight,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(
            Icons.person_outline,
            color: AppLightColors.primary,
            size: 22.sp,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: SelectableText(
            'code: $uid',
            style: font13w600.copyWith(color: const Color(0xFF444444)),
            textAlign: TextAlign.left,
            textDirection: TextDirection.ltr,
          ),
        ),
        SizedBox(width: 8.w),
        statusBadge,
      ],
    );
  }
}
