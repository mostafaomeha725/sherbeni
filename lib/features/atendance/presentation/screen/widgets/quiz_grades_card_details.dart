import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qrattendance/core/widgets/custom_text.dart';
import 'package:qrattendance/features/atendance/domain/entities/quiz_student_entity.dart';

class QuizGradesCardDetails extends StatelessWidget {
  final QuizStudentEntity student;

  const QuizGradesCardDetails({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          children: [
            Expanded(
              child: AppText(
                student.name,
                maxLines: 2,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        Row(
          children: [
            Icon(
              Icons.qr_code_rounded,
              size: 14.sp,
              color: const Color(0xFF64748B),
            ),
            SizedBox(width: 4.w),
            AppText(
              student.studentCode,
              style: TextStyle(
                fontSize: 13.sp,
                color: const Color(0xFF64748B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        if (student.phoneNumber != null && student.phoneNumber!.isNotEmpty)
          Row(
            children: [
              Icon(
                Icons.phone_rounded,
                size: 14.sp,
                color: const Color(0xFF64748B),
              ),
              SizedBox(width: 4.w),
              AppText(
                student.phoneNumber!,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: const Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
      ],
    );
  }
}
