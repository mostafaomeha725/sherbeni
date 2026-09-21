import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart' show Bidi;
import 'package:qrattendance/core/theme/light_colors.dart';
import 'package:qrattendance/core/theme/styles.dart';
import 'package:qrattendance/core/widgets/bouncing_widgets.dart';
import 'package:qrattendance/core/widgets/custom_text.dart';
import 'package:qrattendance/features/atendance/domain/entities/academic_class_entity.dart';

class AcademicClassCard extends StatelessWidget {
  final AcademicClassEntity academicClass;
  final VoidCallback onTap;

  const AcademicClassCard({
    super.key,
    required this.academicClass,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BounceIt(
      onPressed: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10.r,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        child: Row(
          children: [
            // Left Subject Icon
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppLightColors.primaryLight,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Icon(
                Icons.class_outlined,
                color: AppLightColors.primary,
                size: 28.sp,
              ),
            ),
            SizedBox(width: 16.w),
            // Middle Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    academicClass.name,
                    style: font14w700.copyWith(color: const Color(0xFF222222)),
                    maxLines: 3,
                    textDirection: Bidi.hasAnyRtl(academicClass.name)
                        ? TextDirection.rtl
                        : TextDirection.ltr,
                    textAlign: Bidi.hasAnyRtl(academicClass.name)
                        ? TextAlign.right
                        : TextAlign.left,
                  ),
                  SizedBox(height: 8.h),
                  if (academicClass.educationSystem.isNotEmpty) ...[
                    Row(
                      children: [
                        Icon(
                          Icons.account_balance_outlined,
                          size: 16.sp,
                          color: AppLightColors.primary,
                        ),
                        SizedBox(width: 6.w),
                        Expanded(
                          child: AppText(
                            academicClass.educationSystem,
                            style: font12w500.copyWith(
                              color: const Color(0xFF555555),
                            ),
                            maxLines: 2,
                            textDirection:
                                Bidi.hasAnyRtl(academicClass.educationSystem)
                                ? TextDirection.rtl
                                : TextDirection.ltr,
                            textAlign:
                                Bidi.hasAnyRtl(academicClass.educationSystem)
                                ? TextAlign.right
                                : TextAlign.left,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                  ],
                  Row(
                    children: [
                      Icon(
                        Icons.card_membership_outlined,
                        size: 16.sp,
                        color: AppLightColors.primary,
                      ),
                      SizedBox(width: 6.w),
                      AppText(
                        'Certificate',
                        style: font12w500.copyWith(
                          color: const Color(0xFF555555),
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Icon(
                        academicClass.certificate
                            ? Icons.check_circle_outline
                            : Icons.cancel_outlined,
                        size: 16.sp,
                        color: academicClass.certificate
                            ? Colors.green
                            : Colors.red,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            // Right Arrow
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: const BoxDecoration(
                color: AppLightColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16.sp,
                color: AppLightColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
