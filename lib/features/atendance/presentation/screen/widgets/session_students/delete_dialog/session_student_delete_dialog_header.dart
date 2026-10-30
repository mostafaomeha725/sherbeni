import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qrattendance/core/theme/light_colors.dart';
import 'package:qrattendance/core/theme/styles.dart';
import 'package:qrattendance/core/widgets/custom_text.dart';

class SessionStudentDeleteDialogHeader extends StatelessWidget {
  const SessionStudentDeleteDialogHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // App Theme Colored Dual-Ring Icon Badge
        Container(
          width: 64.r,
          height: 64.r,
          decoration: BoxDecoration(
            color: AppLightColors.primaryLight,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppLightColors.primary.withValues(alpha: 0.25),
              width: 2.0,
            ),
          ),
          child: Center(
            child: Container(
              width: 44.r,
              height: 44.r,
              decoration: const BoxDecoration(
                color: AppLightColors.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.delete_sweep_rounded,
                color: Colors.white,
                size: 24.sp,
              ),
            ),
          ),
        ),
        SizedBox(height: 14.h),

        // Dialog Title
        AppText(
          ' حذف الحضور',
          style: font18w700.copyWith(color: const Color(0xFF1E293B)),
          alignment: AlignmentDirectional.center,
        ),
        SizedBox(height: 6.h),

        // Subtitle
        AppText(
          'هل أنت متأكد من إلغاء حضور هذا الطالب من الجلسة؟',
          style: font14w500.copyWith(color: const Color(0xFF64748B)),
          alignment: AlignmentDirectional.center,
          maxLines: 3,
          textAlign: TextAlign.right,
        ),
      ],
    );
  }
}
