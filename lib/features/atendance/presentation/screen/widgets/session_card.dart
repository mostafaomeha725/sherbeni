import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qrattendance/core/theme/light_colors.dart';
import 'package:qrattendance/core/theme/styles.dart';
import 'package:qrattendance/core/widgets/bouncing_widgets.dart';
import 'package:qrattendance/core/widgets/custom_text.dart';
import 'package:qrattendance/features/atendance/domain/entities/session_entity.dart';

class SessionCard extends StatelessWidget {
  final SessionEntity session;
  final VoidCallback onTap;

  const SessionCard({super.key, required this.session, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Dynamic data mapping
    final String teacherName = session.description.isNotEmpty
        ? session.description
        : "لا يوجد معلم";
    final String subjectName = session.courseTitle.isNotEmpty
        ? session.courseTitle
        : 'Subject Name';
    final String levelName = session.title.isNotEmpty
        ? session.title
        : 'Level Name';

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
                Icons.menu_book_outlined,
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
                    subjectName,
                    style: font14w700.copyWith(color: const Color(0xFF222222)),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 16.sp,
                        color: AppLightColors.primary,
                      ),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: AppText(
                          teacherName,
                          style: font12w500.copyWith(
                            color: const Color(0xFF555555),
                          ),
                          maxLines: 2,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(
                        Icons.school_outlined,
                        size: 16.sp,
                        color: AppLightColors.primary,
                      ),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: AppText(
                          levelName,
                          style: font12w500.copyWith(
                            color: const Color(0xFF555555),
                          ),
                          maxLines: 2,
                        ),
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
