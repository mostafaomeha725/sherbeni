import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qrattendance/core/constants/strings.dart';
import 'package:qrattendance/core/theme/light_colors.dart';
import 'package:qrattendance/core/theme/styles.dart';
import 'package:qrattendance/core/widgets/custom_text.dart';
import 'package:qrattendance/features/atendance/domain/entities/session_attendance_entity.dart';

class SessionStudentSheetHeader extends StatelessWidget {
  final SessionAttendanceEntity student;

  const SessionStudentSheetHeader({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 64.r,
          width: 64.r,
          decoration: const BoxDecoration(
            color: AppLightColors.primaryLight,
            shape: BoxShape.circle,
          ),
          clipBehavior: Clip.antiAlias,
          child: student.picture != null && student.picture!.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: student.picture!.startsWith('http')
                      ? student.picture!
                      : '${AppStrings.baseUrl}${student.picture}',
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Icon(
                    Icons.person,
                    color: AppLightColors.primary,
                    size: 32.r,
                  ),
                  errorWidget: (context, url, error) => Icon(
                    Icons.person,
                    color: AppLightColors.primary,
                    size: 32.r,
                  ),
                )
              : Icon(
                  Icons.person,
                  color: AppLightColors.primary,
                  size: 32.r,
                ),
        ),
        SizedBox(height: 12.h),
        AppText(
          student.name,
          style: font18w700.copyWith(color: const Color(0xFF1E293B)),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: student.isLate
                ? const Color(0xFFFEF2F2)
                : const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: student.isLate
                  ? const Color(0xFFFECACA)
                  : const Color(0xFFBBF7D0),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                student.isLate
                    ? Icons.timer_off_outlined
                    : Icons.check_circle_outline_rounded,
                size: 14.sp,
                color: student.isLate
                    ? const Color(0xFFDC2626)
                    : const Color(0xFF16A34A),
              ),
              SizedBox(width: 6.w),
              AppText(
                student.isLate ? 'متأخر (Late)' : 'في الموعد (On Time)',
                style: font12w700.copyWith(
                  color: student.isLate
                      ? const Color(0xFFDC2626)
                      : const Color(0xFF16A34A),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
