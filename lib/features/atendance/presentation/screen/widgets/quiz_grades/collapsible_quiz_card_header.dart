import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qrattendance/core/theme/light_colors.dart';
import 'package:qrattendance/core/theme/styles.dart';
import 'package:qrattendance/core/widgets/custom_text.dart';
import 'package:qrattendance/features/atendance/data/model/quiz_grade_history_model.dart';

class CollapsibleQuizCardHeader extends StatelessWidget {
  final QuizGradeHistoryModel item;
  final Widget statusBadge;
  final bool isExpanded;
  final VoidCallback onTap;

  const CollapsibleQuizCardHeader({
    super.key,
    required this.item,
    required this.statusBadge,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: AppLightColors.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                Icons.quiz_outlined,
                color: AppLightColors.secondary,
                size: 22.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    item.studentName.isNotEmpty
                        ? item.studentName
                        : 'اسم الطالب',
                    style: font14w700.copyWith(color: const Color(0xFF222222)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 3.h),
                  SelectableText(
                    'code: ${item.studentId}',
                    style: font12w500.copyWith(color: const Color(0xFF777777)),
                    textAlign: TextAlign.left,
                    textDirection: TextDirection.ltr,
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            statusBadge,
            SizedBox(width: 6.w),
            AnimatedRotation(
              turns: isExpanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: const Color(0xFF999999),
                size: 20.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
