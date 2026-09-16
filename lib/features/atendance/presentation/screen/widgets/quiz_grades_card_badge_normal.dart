import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qrattendance/core/widgets/custom_text.dart';

class QuizGradesCardBadgeNormal extends StatelessWidget {
  final int? currentGrade;
  final VoidCallback onTap;

  const QuizGradesCardBadgeNormal({
    super.key,
    required this.currentGrade,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isGraded = currentGrade != null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        constraints: BoxConstraints(minWidth: 54.w, minHeight: 46.h),
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isGraded ? const Color(0xFFF0FDF4) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isGraded
                ? const Color(0xFF16A34A).withValues(alpha: 0.4)
                : const Color(0xFFE2E8F0),
            width: 1.2,
          ),
          boxShadow: isGraded
              ? [
                  BoxShadow(
                    color: const Color(0xFF16A34A).withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppText(
              isGraded ? currentGrade.toString() : 'Enter',
              style: TextStyle(
                fontSize: isGraded ? 16.sp : 10.sp,
                fontWeight: isGraded ? FontWeight.w900 : FontWeight.w700,
                color: isGraded
                    ? const Color(0xFF16A34A)
                    : const Color(0xFF64748B),
              ),
            ),
            SizedBox(height: 2.h),
            AppText(
              'Grade',
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: isGraded ? FontWeight.w600 : FontWeight.w700,
                color: isGraded
                    ? const Color(0xFF16A34A).withValues(alpha: 0.8)
                    : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
